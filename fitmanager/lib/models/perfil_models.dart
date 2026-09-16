import 'package:flutter/material.dart';

/// Una opción de avatar del catálogo `avatares_perfil` (igual que en la web).
class AvatarOption {
  final String codigo;
  final String nombre;
  final String icono;
  final Color colorInicio;
  final Color colorFin;

  const AvatarOption({
    required this.codigo,
    required this.nombre,
    required this.icono,
    required this.colorInicio,
    required this.colorFin,
  });

  factory AvatarOption.fromJson(Map<String, dynamic> json) => AvatarOption(
        codigo: json['codigo']?.toString() ?? '',
        nombre: json['nombre']?.toString() ?? '',
        icono: json['icono']?.toString() ?? '',
        colorInicio: _hexToColor(json['colorInicio']?.toString()),
        colorFin: _hexToColor(json['colorFin']?.toString()),
      );

  /// Traduce el nombre de ícono de FontAwesome que usa la web (p. ej.
  /// "fa-dumbbell") a un IconData de Material, por coincidencia de texto,
  /// para no depender de una tabla fija de 4 avatares.
  IconData get materialIcon {
    final i = icono.toLowerCase();
    if (i.contains('dumbbell') || i.contains('fitness')) return Icons.fitness_center_rounded;
    if (i.contains('bolt') || i.contains('energy') || i.contains('rayo')) return Icons.bolt_rounded;
    if (i.contains('bullseye') || i.contains('target') || i.contains('focus')) return Icons.track_changes_rounded;
    if (i.contains('heart')) return Icons.favorite_rounded;
    if (i.contains('leaf') || i.contains('zen') || i.contains('spa')) return Icons.self_improvement_rounded;
    return Icons.person_rounded;
  }
}

Color _hexToColor(String? hex) {
  if (hex == null || hex.isEmpty) return const Color(0xFFC92F35);
  final limpio = hex.replaceAll('#', '');
  final valor = int.tryParse(limpio.length == 6 ? 'FF$limpio' : limpio, radix: 16);
  return valor != null ? Color(valor) : const Color(0xFFC92F35);
}

/// Todo lo que se muestra en "Mi perfil": datos de cuenta + estado del
/// avatar/foto + catálogo de avatares disponibles para elegir.
class PerfilInfo {
  final String email;
  final String genero;
  final String? avatarCodigo;
  final bool tieneFoto;
  final List<AvatarOption> avatares;

  const PerfilInfo({
    required this.email,
    required this.genero,
    required this.avatarCodigo,
    required this.tieneFoto,
    required this.avatares,
  });

  String get generoMostrado => genero.trim().isEmpty ? 'Sin registrar' : genero;

  AvatarOption? get avatarSeleccionado {
    if (avatarCodigo == null || avatarCodigo!.isEmpty) return null;
    for (final a in avatares) {
      if (a.codigo == avatarCodigo) return a;
    }
    return null;
  }

  factory PerfilInfo.fromJson(Map<String, dynamic> json) {
    final codigo = json['avatarCodigo']?.toString() ?? '';
    return PerfilInfo(
      email: json['email']?.toString() ?? '',
      genero: json['genero']?.toString() ?? '',
      avatarCodigo: codigo.isEmpty ? null : codigo,
      tieneFoto: json['tieneFoto'] == true,
      avatares: (json['avatares'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(AvatarOption.fromJson)
          .toList(),
    );
  }
}
