/// Modelo de usuario alineado con la tabla `usuarios` de fitmanager.
/// Campos: id_Usuarios, nombre, apellido, documento, email,
///         id_Roles, id_TipoDocumento, id_Membresias, vencimiento
class AppUser {
  final int id;
  final String nombre;
  final String apellido;
  final String documento;
  final String email;
  final String? telefono;
  final int idRol;
  final String rol;
  final String? tipoDocumento;
  final String? membresia;
  final String? vencimiento;

  const AppUser({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.documento,
    required this.email,
    this.telefono,
    required this.idRol,
    required this.rol,
    this.tipoDocumento,
    this.membresia,
    this.vencimiento,
  });

  String get nombreCompleto => '$nombre $apellido'.trim();

  /// id_Roles = 1 → Administrador  |  2 → Cliente  (igual que LoginServlet.java)
  bool get esAdmin => idRol == 1 || rol.toLowerCase().contains('admin');

  /// true si el cliente tiene una membresía asignada y su fecha de
  /// vencimiento (si existe) todavía no pasó.
  bool get tieneMembresiaActiva {
    if (membresia == null || membresia!.trim().isEmpty) return false;
    if (vencimiento == null || vencimiento!.trim().isEmpty) return true;
    final fecha = DateTime.tryParse(vencimiento!.trim());
    if (fecha == null) return true;
    final hoy = DateTime.now();
    final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);
    return !fecha.isBefore(hoySinHora);
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id:             _asInt(json['id']),
      nombre:         json['nombre']?.toString()        ?? '',
      apellido:       json['apellido']?.toString()      ?? '',
      documento:      json['documento']?.toString()     ?? '',
      email:          json['email']?.toString()         ?? '',
      telefono:       json['telefono']?.toString(),
      idRol:          _asInt(json['idRol']),
      rol:            json['rol']?.toString()           ?? 'Cliente',
      tipoDocumento:  json['tipoDocumento']?.toString(),
      membresia:      json['membresia']?.toString(),
      vencimiento:    json['vencimiento']?.toString(),
    );
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

