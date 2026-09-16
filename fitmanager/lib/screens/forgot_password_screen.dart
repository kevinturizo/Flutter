import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/brand_logo.dart';

enum _Paso { correo, codigo, nuevaPassword, listo }

/// Flujo de "olvidé mi contraseña" en 3 pasos:
///   1) el usuario ingresa el correo ya registrado (con membresía comprada o no)
///   2) recibe un código por correo y lo valida
///   3) define y confirma la nueva contraseña
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _api = ApiService();
  final _emailCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  _Paso _paso = _Paso.correo;
  bool _loading = false;
  bool _showPass = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codigoCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _snack(String text, {required bool ok}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: ok ? kGreen : kRed,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _enviarCodigo() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _snack('Ingresa tu correo registrado.', ok: false);
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.forgotPasswordRequest(email: email);
      if (!mounted) return;
      _snack('Te enviamos un código de verificación a tu correo.', ok: true);
      setState(() => _paso = _Paso.codigo);
    } on ApiException catch (e) {
      if (mounted) _snack(e.message, ok: false);
    } catch (_) {
      if (mounted) {
        _snack('No se pudo conectar con el servidor.', ok: false);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _validarCodigo() async {
    final codigo = _codigoCtrl.text.trim();
    if (codigo.isEmpty) {
      _snack('Ingresa el código que recibiste.', ok: false);
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.forgotPasswordVerify(
        email: _emailCtrl.text.trim(),
        codigo: codigo,
      );
      if (!mounted) return;
      _snack('Código válido.', ok: true);
      setState(() => _paso = _Paso.nuevaPassword);
    } on ApiException catch (e) {
      if (mounted) _snack(e.message, ok: false);
    } catch (_) {
      if (mounted) {
        _snack('No se pudo conectar con el servidor.', ok: false);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _guardarNuevaPassword() async {
    if (_passCtrl.text.isEmpty || _confirmCtrl.text.isEmpty) {
      _snack('Completa la nueva contraseña y su confirmación.', ok: false);
      return;
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      _snack('Las contraseñas no coinciden.', ok: false);
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.forgotPasswordReset(
        email: _emailCtrl.text.trim(),
        codigo: _codigoCtrl.text.trim(),
        nuevaPassword: _passCtrl.text,
      );
      if (!mounted) return;
      setState(() => _paso = _Paso.listo);
    } on ApiException catch (e) {
      if (mounted) _snack(e.message, ok: false);
    } catch (_) {
      if (mounted) {
        _snack('No se pudo conectar con el servidor.', ok: false);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: kText),
        title: const Text('Recuperar contraseña'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Center(child: const BrandLogo(width: 80)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kBorder),
                    ),
                    child: _buildPaso(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaso() {
    switch (_paso) {
      case _Paso.correo:
        return _pasoCorreo();
      case _Paso.codigo:
        return _pasoCodigo();
      case _Paso.nuevaPassword:
        return _pasoNuevaPassword();
      case _Paso.listo:
        return _pasoListo();
    }
  }

  Widget _pasoCorreo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(color: kText, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Ingresa el correo con el que te registraste y te enviaremos '
          'un código de verificación.',
          style: TextStyle(color: kTextSub, fontSize: 13),
        ),
        const SizedBox(height: 22),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _loading ? null : _enviarCodigo(),
          style: TextStyle(color: kText),
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            prefixIcon: Icon(Icons.email_outlined, color: kTextSub),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _loading ? null : _enviarCodigo,
          style: ElevatedButton.styleFrom(backgroundColor: kAccent),
          child: _loading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Enviar código'),
        ),
      ],
    );
  }

  Widget _pasoCodigo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Verifica tu código',
          style: TextStyle(color: kText, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Ingresa el código que enviamos a ${_emailCtrl.text.trim()}.',
          style: TextStyle(color: kTextSub, fontSize: 13),
        ),
        const SizedBox(height: 22),
        TextField(
          controller: _codigoCtrl,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _loading ? null : _validarCodigo(),
          style: TextStyle(color: kText, letterSpacing: 4, fontSize: 18),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            labelText: 'Código de verificación',
            prefixIcon: Icon(Icons.pin_outlined, color: kTextSub),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _loading ? null : _validarCodigo,
          style: ElevatedButton.styleFrom(backgroundColor: kAccent),
          child: _loading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Validar código'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _loading ? null : _enviarCodigo,
          child: Text('Reenviar código', style: TextStyle(color: kTextSub, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _pasoNuevaPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Nueva contraseña',
          style: TextStyle(color: kText, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Crea una nueva contraseña para tu cuenta.',
          style: TextStyle(color: kTextSub, fontSize: 13),
        ),
        const SizedBox(height: 22),
        TextField(
          controller: _passCtrl,
          obscureText: !_showPass,
          textInputAction: TextInputAction.next,
          style: TextStyle(color: kText),
          decoration: InputDecoration(
            labelText: 'Nueva contraseña',
            prefixIcon: Icon(Icons.lock_outline, color: kTextSub),
            suffixIcon: IconButton(
              icon: Icon(
                _showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: kTextSub,
              ),
              onPressed: () => setState(() => _showPass = !_showPass),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _confirmCtrl,
          obscureText: !_showConfirm,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _loading ? null : _guardarNuevaPassword(),
          style: TextStyle(color: kText),
          decoration: InputDecoration(
            labelText: 'Confirmar nueva contraseña',
            prefixIcon: Icon(Icons.lock_outline, color: kTextSub),
            suffixIcon: IconButton(
              icon: Icon(
                _showConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: kTextSub,
              ),
              onPressed: () => setState(() => _showConfirm = !_showConfirm),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _loading ? null : _guardarNuevaPassword,
          style: ElevatedButton.styleFrom(backgroundColor: kAccent),
          child: _loading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Guardar contraseña'),
        ),
      ],
    );
  }

  Widget _pasoListo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.check_circle_outline, color: kGreen, size: 56),
        const SizedBox(height: 16),
        Text(
          '¡Contraseña actualizada!',
          textAlign: TextAlign.center,
          style: TextStyle(color: kText, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Ya puedes iniciar sesión con tu nueva contraseña.',
          textAlign: TextAlign.center,
          style: TextStyle(color: kTextSub, fontSize: 13),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(backgroundColor: kAccent),
          child: const Text('Volver a iniciar sesión'),
        ),
      ],
    );
  }
}


