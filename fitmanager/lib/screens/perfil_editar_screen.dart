import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/perfil_models.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/profile_avatar.dart';

/// Pantalla "Mi perfil": equivalente móvil del panel Cliente.jsp con
/// "Datos de la cuenta" + "Seguridad: Actualizar contraseña".
class PerfilEditarScreen extends StatefulWidget {
  const PerfilEditarScreen({
    super.key,
    required this.token,
    this.perfilInicial,
    this.onCambiado,
  });

  final String token;
  final PerfilInfo? perfilInicial;

  /// Se llama cada vez que el perfil cambia (avatar/foto), para que la
  /// pantalla anterior (Inicio, Drawer) refresque su propio avatar.
  final ValueChanged<PerfilInfo>? onCambiado;

  @override
  State<PerfilEditarScreen> createState() => _PerfilEditarScreenState();
}

class _PerfilEditarScreenState extends State<PerfilEditarScreen> {
  final ApiService _api = ApiService();

  PerfilInfo? _perfil;
  bool _cargando = true;
  bool _guardandoAvatar = false;
  bool _subiendoFoto = false;
  int _fotoVersion = 0;

  // Cambio de contraseña.
  bool _codigoEnviado = false;
  bool _enviandoCodigo = false;
  bool _actualizandoPassword = false;
  final _codigoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _perfil = widget.perfilInicial;
    _cargando = _perfil == null;
    _cargar();
  }

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final perfil = await _api.fetchPerfilInfo(token: widget.token);
      if (!mounted) return;
      setState(() {
        _perfil = perfil;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      _snack(e.toString(), ok: false);
    }
  }

  void _snack(String msg, {bool ok = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: ok ? kGreen : kRed,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _elegirAvatar() async {
    if (_perfil == null || _perfil!.avatares.isEmpty) return;
    final elegido = await showModalBottomSheet<AvatarOption>(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SelectorAvatares(avatares: _perfil!.avatares),
    );
    if (elegido == null) return;

    setState(() => _guardandoAvatar = true);
    try {
      await _api.actualizarAvatar(token: widget.token, codigoAvatar: elegido.codigo);
      final actualizado = PerfilInfo(
        email: _perfil!.email,
        genero: _perfil!.genero,
        avatarCodigo: elegido.codigo,
        tieneFoto: false,
        avatares: _perfil!.avatares,
      );
      setState(() => _perfil = actualizado);
      widget.onCambiado?.call(actualizado);
      _snack('Tu avatar fue actualizado.');
    } catch (e) {
      _snack(e.toString(), ok: false);
    } finally {
      if (mounted) setState(() => _guardandoAvatar = false);
    }
  }

  Future<void> _subirFoto() async {
    final picker = ImagePicker();
    final XFile? archivo = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (archivo == null) return;

    setState(() => _subiendoFoto = true);
    try {
      final bytes = await archivo.readAsBytes();
      await _api.subirFotoPerfil(
        token: widget.token,
        bytes: bytes,
        filename: archivo.name,
        mimeType: archivo.mimeType,
      );
      final actualizado = PerfilInfo(
        email: _perfil!.email,
        genero: _perfil!.genero,
        avatarCodigo: null,
        tieneFoto: true,
        avatares: _perfil!.avatares,
      );
      setState(() {
        _perfil = actualizado;
        _fotoVersion++;
      });
      widget.onCambiado?.call(actualizado);
      _snack('Tu foto de perfil fue actualizada.');
    } catch (e) {
      _snack(e.toString(), ok: false);
    } finally {
      if (mounted) setState(() => _subiendoFoto = false);
    }
  }

  Future<void> _solicitarCodigo() async {
    setState(() => _enviandoCodigo = true);
    try {
      await _api.solicitarCodigoPerfil(token: widget.token);
      if (!mounted) return;
      setState(() => _codigoEnviado = true);
      _snack('Enviamos un código de verificación a tu correo. Vence en 10 minutos.');
    } catch (e) {
      _snack(e.toString(), ok: false);
    } finally {
      if (mounted) setState(() => _enviandoCodigo = false);
    }
  }

  Future<void> _actualizarPassword() async {
    final codigo = _codigoCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirmar = _confirmarCtrl.text;

    if (!RegExp(r'^[0-9]{6}$').hasMatch(codigo)) {
      _snack('Ingresa el código de seis dígitos enviado a tu correo.', ok: false);
      return;
    }
    if (password.length < 8) {
      _snack('La nueva contraseña debe tener mínimo 8 caracteres.', ok: false);
      return;
    }
    if (password != confirmar) {
      _snack('Las contraseñas no coinciden.', ok: false);
      return;
    }

    setState(() => _actualizandoPassword = true);
    try {
      await _api.cambiarPasswordPerfil(
        token: widget.token,
        codigo: codigo,
        password: password,
        confirmPassword: confirmar,
      );
      if (!mounted) return;
      _snack('Tu contraseña fue actualizada correctamente.');
      setState(() {
        _codigoEnviado = false;
        _codigoCtrl.clear();
        _passwordCtrl.clear();
        _confirmarCtrl.clear();
      });
    } catch (e) {
      _snack(e.toString(), ok: false);
    } finally {
      if (mounted) setState(() => _actualizandoPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kSidebar,
        title: Text('Mi perfil', style: TextStyle(color: kText, fontWeight: FontWeight.w800)),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _perfil == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('No se pudo cargar tu perfil.', style: TextStyle(color: kTextSub)),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    _seccionAvatar(),
                    const SizedBox(height: 24),
                    _seccionDatosCuenta(),
                    const SizedBox(height: 24),
                    _seccionSeguridad(),
                    const SizedBox(height: 24),
                  ]),
                ),
    );
  }

  Widget _seccionAvatar() {
    final cargando = _guardandoAvatar || _subiendoFoto;
    return Center(
      child: Column(children: [
        Stack(clipBehavior: Clip.none, children: [
          Opacity(
            opacity: cargando ? 0.5 : 1,
            child: ProfileAvatar(
              perfil: _perfil,
              fotoUrl: _api.urlFotoPerfil(widget.token, version: _fotoVersion),
              size: 96,
            ),
          ),
          if (cargando)
            const Positioned.fill(child: Center(child: CircularProgressIndicator())),
          Positioned(
            bottom: -2,
            right: -2,
            child: Material(
              color: kAccent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: cargando ? null : _mostrarOpcionesFoto,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: cargando ? null : _mostrarOpcionesFoto,
          icon: Icon(Icons.photo_camera_outlined, size: 18, color: kAccent),
          label: Text('Cambiar foto o avatar', style: TextStyle(color: kAccent)),
        ),
      ]),
    );
  }

  void _mostrarOpcionesFoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: Icon(Icons.face_retouching_natural_rounded, color: kAccent),
            title: Text('Elegir un avatar', style: TextStyle(color: kText)),
            onTap: () {
              Navigator.pop(ctx);
              _elegirAvatar();
            },
          ),
          ListTile(
            leading: Icon(Icons.image_outlined, color: kAccent),
            title: Text('Subir una foto', style: TextStyle(color: kText)),
            subtitle: Text('PNG o JPG, máximo 3 MB', style: TextStyle(color: kTextSub, fontSize: 12)),
            onTap: () {
              Navigator.pop(ctx);
              _subirFoto();
            },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _seccionDatosCuenta() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.badge_outlined, color: kAccent, size: 18),
        const SizedBox(width: 8),
        Text('Datos de la cuenta',
            style: TextStyle(color: kText, fontSize: 16, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 12),
      _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.email_outlined, color: kTextSub, size: 18),
          const SizedBox(width: 10),
          Text('Correo electrónico', style: TextStyle(color: kTextSub, fontSize: 12)),
        ]),
        const SizedBox(height: 4),
        Text(_perfil!.email, style: TextStyle(color: kText, fontSize: 15, fontWeight: FontWeight.w600)),
        const Divider(height: 24),
        Row(children: [
          Icon(Icons.wc_rounded, color: kTextSub, size: 18),
          const SizedBox(width: 10),
          Text('Sexo', style: TextStyle(color: kTextSub, fontSize: 12)),
        ]),
        const SizedBox(height: 4),
        Text(_perfil!.generoMostrado,
            style: TextStyle(color: kText, fontSize: 15, fontWeight: FontWeight.w600)),
      ])),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kAccentBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kAccent.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          Icon(Icons.info_outline_rounded, color: kAccent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Estos datos se muestran como información de tu cuenta.',
                style: TextStyle(color: kTextSub, fontSize: 12)),
          ),
        ]),
      ),
    ]);
  }

  Widget _seccionSeguridad() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.shield_outlined, color: kAccent, size: 18),
        const SizedBox(width: 8),
        Text('Seguridad', style: TextStyle(color: kText, fontSize: 16, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 4),
      Text('Actualizar contraseña', style: TextStyle(color: kTextSub, fontSize: 13)),
      const SizedBox(height: 4),
      Text(
        'Para cambiar la contraseña debes confirmar un código de seis dígitos '
        'enviado a tu correo. El código vence en 10 minutos.',
        style: TextStyle(color: kTextSub, fontSize: 12),
      ),
      const SizedBox(height: 14),
      ElevatedButton.icon(
        onPressed: _enviandoCodigo ? null : _solicitarCodigo,
        icon: _enviandoCodigo
            ? const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.send_rounded, size: 18),
        label: Text(_codigoEnviado ? 'Reenviar código' : 'Enviar código a mi correo'),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _codigoCtrl,
        keyboardType: TextInputType.number,
        maxLength: 6,
        style: TextStyle(color: kText),
        decoration: const InputDecoration(
          labelText: 'Código de verificación',
          counterText: '',
          prefixIcon: Icon(Icons.pin_outlined),
        ),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _passwordCtrl,
        obscureText: true,
        style: TextStyle(color: kText),
        decoration: const InputDecoration(
          labelText: 'Nueva contraseña',
          helperText: 'Mínimo 8 caracteres',
          prefixIcon: Icon(Icons.lock_outline_rounded),
        ),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _confirmarCtrl,
        obscureText: true,
        style: TextStyle(color: kText),
        decoration: const InputDecoration(
          labelText: 'Confirmar nueva contraseña',
          prefixIcon: Icon(Icons.lock_outline_rounded),
        ),
      ),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: _actualizandoPassword ? null : _actualizarPassword,
        child: _actualizandoPassword
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Actualizar contraseña'),
      ),
    ]);
  }

  Widget _card(Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: child,
      );
}

/// Grilla de avatares del catálogo, para elegir uno.
class _SelectorAvatares extends StatelessWidget {
  const _SelectorAvatares({required this.avatares});
  final List<AvatarOption> avatares;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Elige un avatar', style: TextStyle(color: kText, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: avatares.map((a) {
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.pop(context, a),
                child: Column(children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [a.colorInicio, a.colorFin],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(a.materialIcon, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 6),
                  Text(a.nombre, style: TextStyle(color: kTextSub, fontSize: 12)),
                ]),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}
