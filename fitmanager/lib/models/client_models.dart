// Modelos alineados exactamente con MobileApiServlet.java

int _i(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

class ClaseModel {
  final int id;
  final String nombre;
  final String dia;
  final String hora;
  final String instructor;
  final bool inscrito;

  ClaseModel({
    required this.id,
    required this.nombre,
    required this.dia,
    required this.hora,
    required this.instructor,
    required this.inscrito,
  });

  factory ClaseModel.fromJson(Map<String, dynamic> json) => ClaseModel(
        id: _i(json['id_Clases']),
        nombre: json['nombre']?.toString() ?? '',
        dia: json['dia']?.toString() ?? '',
        hora: json['hora']?.toString() ?? '',
        instructor: json['instructor']?.toString() ?? '',
        inscrito: json['inscrito'] == true,
      );

  ClaseModel copyWith({bool? inscrito}) => ClaseModel(
        id: id,
        nombre: nombre,
        dia: dia,
        hora: hora,
        instructor: instructor,
        inscrito: inscrito ?? this.inscrito,
      );
}

class ComprobanteModel {
  final int id;
  final String fecha;
  final String numero;
  final String total;
  final String concepto;

  ComprobanteModel({
    required this.id,
    required this.fecha,
    required this.numero,
    required this.total,
    this.concepto = '',
  });

  factory ComprobanteModel.fromJson(Map<String, dynamic> json) => ComprobanteModel(
        id: _i(json['id']),
        fecha: json['fecha']?.toString() ?? '',
        numero: json['numero']?.toString() ?? '',
        total: json['total']?.toString() ?? '',
        concepto: json['concepto']?.toString() ?? '',
      );
}

class ComprobanteDetalleModel {
  final String numero;
  final String fecha;
  final String total;
  final String metodo;
  final String cliente;
  final String correo;
  final String telefono;
  final String concepto;
  final String cantidad;
  final String precioUnit;
  final String tipoCompra;
  final String nombreMembresia;
  final int duracionDias;
  final String idTransaccion;
  final String referenciaPago;

  ComprobanteDetalleModel({
    required this.numero,
    required this.fecha,
    required this.total,
    required this.metodo,
    required this.cliente,
    required this.correo,
    this.telefono = '',
    required this.concepto,
    required this.cantidad,
    required this.precioUnit,
    this.tipoCompra = '',
    this.nombreMembresia = '',
    this.duracionDias = 0,
    this.idTransaccion = '',
    this.referenciaPago = '',
  });

  factory ComprobanteDetalleModel.fromJson(Map<String, dynamic> json) => ComprobanteDetalleModel(
        numero: json['numero']?.toString() ?? '',
        fecha: json['fecha']?.toString() ?? '',
        total: json['total']?.toString() ?? '',
        metodo: json['metodo']?.toString() ?? '',
        cliente: json['cliente']?.toString() ?? '',
        correo: json['correo']?.toString() ?? '',
        telefono: json['telefono']?.toString() ?? '',
        concepto: json['concepto']?.toString() ?? '',
        cantidad: json['cantidad']?.toString() ?? '',
        precioUnit: json['precioUnit']?.toString() ?? '',
        tipoCompra: json['tipoCompra']?.toString() ?? '',
        nombreMembresia: json['nombreMembresia']?.toString() ?? '',
        duracionDias: _i(json['duracionDias']),
        idTransaccion: json['idTransaccion']?.toString() ?? '',
        referenciaPago: json['referenciaPago']?.toString() ?? '',
      );
}

class RutinaModel {
  final int id;
  final String nombre;
  final String descripcion;
  final String objetivo;
  final String programa;
  final String enlaceDrive;

  RutinaModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.objetivo,
    required this.programa,
    required this.enlaceDrive,
  });

  factory RutinaModel.fromJson(Map<String, dynamic> json) => RutinaModel(
        id: _i(json['id_Rutinas']),
        nombre: json['nombre']?.toString() ?? '',
        descripcion: json['descripcion']?.toString() ?? '',
        objetivo: json['objetivo']?.toString() ?? '',
        programa: json['programa']?.toString() ?? '',
        enlaceDrive: json['enlaceDrive']?.toString() ?? '',
      );
}

class RegistroModel {
  final int id;
  final String ejercicio;
  final int repeticiones;
  final double peso;
  final String fecha;

  RegistroModel({
    required this.id,
    required this.ejercicio,
    required this.repeticiones,
    required this.peso,
    required this.fecha,
  });

  factory RegistroModel.fromJson(Map<String, dynamic> json) => RegistroModel(
        id: _i(json['id_Registros']),
        ejercicio: json['ejercicio']?.toString() ?? '',
        repeticiones: _i(json['repeticiones']),
        peso: (json['peso'] as num?)?.toDouble() ??
            double.tryParse(json['peso']?.toString() ?? '') ?? 0.0,
        fecha: json['fecha']?.toString() ?? '',
      );
}

class MetaModel {
  final int id;
  final String ejercicio;
  final int meta;
  final int progreso;
  final bool cumplida;

  MetaModel({
    required this.id,
    required this.ejercicio,
    required this.meta,
    this.progreso = 0,
    this.cumplida = false,
  });

  factory MetaModel.fromJson(Map<String, dynamic> json) => MetaModel(
        id: _i(json['id_Metas']),
        ejercicio: json['ejercicio']?.toString() ?? '',
        meta: _i(json['meta']),
        progreso: _i(json['progreso']),
        cumplida: json['cumplida'] == true,
      );
}

class EvaluacionModel {
  final int id;
  final String fecha;
  final double peso;
  final int edad;
  final String condicion;
  final String pruebas;

  EvaluacionModel({
    required this.id,
    required this.fecha,
    required this.peso,
    required this.edad,
    required this.condicion,
    required this.pruebas,
  });

  factory EvaluacionModel.fromJson(Map<String, dynamic> json) => EvaluacionModel(
        id: _i(json['id']),
        fecha: json['fecha']?.toString() ?? '',
        peso: json['peso'] is num
            ? (json['peso'] as num).toDouble()
            : double.tryParse(
                  (json['peso']?.toString() ?? '').replaceAll(RegExp(r'[^0-9.]'), ''),
                ) ??
                0.0,
        edad: _i(json['edad']),
        condicion: json['condicion']?.toString() ?? '',
        pruebas: json['pruebas']?.toString() ?? '',
      );
}

class ProductoModel {
  final int id;
  final String nombre;
  final double precio;

  ProductoModel({required this.id, required this.nombre, required this.precio});

  factory ProductoModel.fromJson(Map<String, dynamic> json) => ProductoModel(
        id: _i(json['id']),
        nombre: json['nombre']?.toString() ?? '',
        precio: (json['precio'] as num?)?.toDouble() ??
            double.tryParse(json['precio']?.toString() ?? '') ?? 0.0,
      );
}
