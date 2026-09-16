import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/brand_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.next});
  final Widget next;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<double> _logoFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();

    _scale    = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _fade     = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    Future.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => widget.next,
          transitionDuration: const Duration(milliseconds: 450),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.65, end: 1.0).animate(_scale),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo Taurus ───────────────────────────────────────────
                FadeTransition(
                  opacity: _logoFade,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: const BrandLogo(width: 150),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'TAURUS GYM',
                  style: TextStyle(
                    color: kText,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Gym Software Solutions',
                  style: TextStyle(
                    color: kTextSub,
                    fontSize: 13,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 44),
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    color: kAccent,
                    strokeWidth: 2.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


