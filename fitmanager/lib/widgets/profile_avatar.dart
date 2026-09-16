import 'package:flutter/material.dart';
import '../models/perfil_models.dart';
import '../theme.dart';

/// Círculo de perfil: muestra la foto subida si existe, si no el avatar
/// elegido (ícono + degradado de color), y si no hay nada, el ícono
/// genérico de persona. Igual jerarquía que PerfilDAO.obtenerEstado en la web.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.perfil,
    required this.fotoUrl,
    this.size = 56,
    this.iconSize,
  });

  final PerfilInfo? perfil;
  final String? fotoUrl;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final radio = size / 2;

    if (perfil?.tieneFoto == true && fotoUrl != null) {
      return ClipOval(
        child: Image.network(
          fotoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : _fallback(),
          errorBuilder: (context, error, stack) => _fallback(),
        ),
      );
    }

    final avatar = perfil?.avatarSeleccionado;
    if (avatar != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [avatar.colorInicio, avatar.colorFin],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Icon(avatar.materialIcon, color: Colors.white, size: iconSize ?? size * 0.5),
      );
    }

    return _fallback(radio: radio);
  }

  Widget _fallback({double? radio}) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: kAccentBg,
          shape: BoxShape.circle,
          border: Border.all(color: kAccent.withValues(alpha: 0.4)),
        ),
        child: Icon(Icons.person_rounded, color: kAccent, size: iconSize ?? size * 0.5),
      );
}
