import 'package:flutter/material.dart';
import 'admin_screen.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  LoginScreen — pantalla de inicio de sesión
//  Servlet: LoginServlet / InicioSesionServlet
// ══════════════════════════════════════════════════════════════════════════════

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _verPass = false;
  bool _cargando = false;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final correo = _correoCtrl.text.trim();
    final pass = _passCtrl.text;

    if (correo.isEmpty || pass.isEmpty) {
      _snack('Completa correo y contraseña', ok: false);
      return;
    }

    setState(() => _cargando = true);

    // POST a LoginServlet / InicioSesionServlet:
    // correo, password
    // -> si rol == Administrador, navegar a AdminScreen
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() => _cargando = false);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminScreen()),
    );
  }

  void _snack(String msg, {required bool ok}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: ok ? kGreen : kRed,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: kAccent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.fitness_center,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'FitManager',
                    style: TextStyle(
                      color: kText,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Inicia sesión para continuar',
                    style: TextStyle(color: kTextSub, fontSize: 13),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kBorder),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _correoCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: kText, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            labelStyle:
                                TextStyle(color: kTextSub, fontSize: 12),
                            prefixIcon: Icon(Icons.email_outlined,
                                color: kTextSub, size: 18),
                            filled: true,
                            fillColor: kCard,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: kBorder)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: kBorder)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: kAccent, width: 1.5)),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passCtrl,
                          obscureText: !_verPass,
                          style: TextStyle(color: kText, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            labelStyle:
                                TextStyle(color: kTextSub, fontSize: 12),
                            prefixIcon: Icon(Icons.lock_outline,
                                color: kTextSub, size: 18),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _verPass
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: kTextDim,
                                size: 18,
                              ),
                              onPressed: () =>
                                  setState(() => _verPass = !_verPass),
                            ),
                            filled: true,
                            fillColor: kCard,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: kBorder)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: kBorder)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: kAccent, width: 1.5)),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 12),
                          ),
                          onSubmitted: (_) => _cargando ? null : _iniciarSesion(),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _cargando ? null : _iniciarSesion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kAccent,
                              disabledBackgroundColor:
                                  kAccent.withValues(alpha: 0.5),
                              foregroundColor: kText,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              textStyle: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            child: _cargando
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Iniciar sesión'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


