import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/brand_logo.dart';
import 'client_screen.dart';
import 'forgot_password_screen.dart';

/// Clave usada en SharedPreferences para el correo recordado.
const String _kRecordarUsuarioKey = 'recordar_usuario_email';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _api          = ApiService();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading       = false;
  bool _showPassword  = false;
  bool _recordarUsuario = false;

  @override
  void initState() {
    super.initState();
    _cargarUsuarioRecordado();
  }

  Future<void> _cargarUsuarioRecordado() async {
    final prefs = await SharedPreferences.getInstance();
    final guardado = prefs.getString(_kRecordarUsuarioKey);
    if (guardado != null && guardado.isNotEmpty && mounted) {
      setState(() {
        _emailCtrl.text = guardado;
        _recordarUsuario = true;
      });
    }
  }

  Future<void> _guardarOEliminarUsuarioRecordado(String email) async {
    final prefs = await SharedPreferences.getInstance();
    if (_recordarUsuario) {
      await prefs.setString(_kRecordarUsuarioKey, email);
    } else {
      await prefs.remove(_kRecordarUsuarioKey);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      _snack('Completa correo y contraseña.', ok: false);
      return;
    }

    setState(() => _loading = true);
    try {
      final result = await _api.login(email: email, password: password);
      if (!mounted) return;

      // Solo clientes (rol 2) pueden acceder a esta app
      if (result.user.esAdmin) {
        _snack('Este acceso es exclusivo para clientes.', ok: false);
        return;
      }

      // Solo clientes con membresía activa (comprada y no vencida) pueden entrar
      if (!result.user.tieneMembresiaActiva) {
        final tieneMembresia = result.user.membresia != null &&
            result.user.membresia!.trim().isNotEmpty;
        _snack(
          tieneMembresia
              ? 'Tu membresía venció. Renuévala para poder ingresar.'
              : 'Necesitas una membresía activa para ingresar. Adquiere una en recepción.',
          ok: false,
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ClientScreen(session: result),
        ),
      );
      await _guardarOEliminarUsuarioRecordado(email);
    } on ApiException catch (e) {
      if (mounted) _snack(e.message, ok: false);
    } catch (_) {
      if (mounted) {
        _snack(
          'No se pudo conectar con el servidor. Verifica tu conexión.',
          ok: false,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String text, {required bool ok}) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),

                  // ── Logo Taurus ──────────────────────────────────────────
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: const BrandLogo(width: 130),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ── Nombre del gym ────────────────────────────────────────
                  Text(
                    'TAURUS GYM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kText,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gym Software Solutions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kTextSub,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Contenedor del formulario ─────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            color: kText,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Accede con tu correo y contraseña registrados.',
                          style: TextStyle(color: kTextSub, fontSize: 13),
                        ),
                        const SizedBox(height: 22),

                        // ── Correo ─────────────────────────────────────────
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(color: kText),
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon:
                                Icon(Icons.email_outlined, color: kTextSub),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── Contraseña ─────────────────────────────────────
                        TextField(
                          controller: _passwordCtrl,
                          obscureText: !_showPassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _loading ? null : _submit(),
                          style: TextStyle(color: kText),
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: Icon(
                                Icons.lock_outline,
                                color: kTextSub),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: kTextSub,
                              ),
                              onPressed: () => setState(
                                  () => _showPassword = !_showPassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ── Recordar usuario ────────────────────────────────
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: _loading
                              ? null
                              : () => setState(
                                  () => _recordarUsuario = !_recordarUsuario),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Checkbox(
                                    value: _recordarUsuario,
                                    activeColor: kAccent,
                                    onChanged: _loading
                                        ? null
                                        : (v) => setState(
                                            () => _recordarUsuario = v ?? false),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Recordar usuario',
                                  style: TextStyle(color: kTextSub, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ── Botón Entrar ───────────────────────────────────
                        ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kAccent,
                            disabledBackgroundColor:
                                kAccent.withValues(alpha: 0.45),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Entrar'),
                        ),
                        const SizedBox(height: 6),

                        // ── ¿Olvidaste tu contraseña? ───────────────────────
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  ),
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(color: kAccent, fontSize: 13),
                          ),
                        ),

                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Nota informativa ──────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: kAccentBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: kAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: kAccent, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Solo clientes con membresía activa pueden acceder. '
                            'Comunícate con recepción si tienes problemas.',
                            style:
                                TextStyle(color: kTextSub, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


