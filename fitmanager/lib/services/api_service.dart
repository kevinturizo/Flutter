import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config.dart';
import '../models/app_user.dart';
import '../models/client_models.dart';
import '../models/perfil_models.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => message;
}

class AuthResult {
  final AppUser user;
  final String token;
  const AuthResult({required this.user, required this.token});
}

class WompiCheckoutData {
  final String nombreItem;
  final double precio;
  final String publicKey;
  final String moneda;
  final int montoCentavos;
  final String referencia;
  final String firma;
  final String redirectUrl;
  final String checkoutUrl;

  const WompiCheckoutData({
    required this.nombreItem,
    required this.precio,
    required this.publicKey,
    required this.moneda,
    required this.montoCentavos,
    required this.referencia,
    required this.firma,
    required this.redirectUrl,
    required this.checkoutUrl,
  });

  /// Arma la URL completa del Web Checkout de Wompi con todos los
  /// parametros necesarios (igual que el formulario GET de Comprar.jsp).
  Uri buildCheckoutUri() {
    return Uri.parse(checkoutUrl).replace(queryParameters: {
      'public-key': publicKey,
      'currency': moneda,
      'amount-in-cents': montoCentavos.toString(),
      'reference': referencia,
      'signature:integrity': firma,
      'redirect-url': redirectUrl,
    });
  }

  factory WompiCheckoutData.fromJson(Map<String, dynamic> json) {
    return WompiCheckoutData(
      nombreItem: json['nombreItem']?.toString() ?? '',
      precio: (json['precio'] as num?)?.toDouble() ??
          double.tryParse(json['precio']?.toString() ?? '') ?? 0.0,
      publicKey: json['wompiPublicKey']?.toString() ?? '',
      moneda: json['wompiMoneda']?.toString() ?? '',
      montoCentavos: json['wompiMontoCentavos'] is int
          ? json['wompiMontoCentavos'] as int
          : int.tryParse(json['wompiMontoCentavos']?.toString() ?? '') ?? 0,
      referencia: json['wompiReferencia']?.toString() ?? '',
      firma: json['wompiFirma']?.toString() ?? '',
      redirectUrl: json['wompiRedirectUrl']?.toString() ?? '',
      checkoutUrl: json['wompiCheckoutUrl']?.toString() ?? '',
    );
  }
}

class AsistenciaResumen {
  final int totalMes;
  final int racha;

  const AsistenciaResumen({required this.totalMes, required this.racha});

  factory AsistenciaResumen.fromJson(Map<String, dynamic> json) {
    int readInt(String key) {
      return json[key] is int
          ? json[key] as int
          : int.tryParse(json[key]?.toString() ?? '') ?? 0;
    }

    return AsistenciaResumen(
      totalMes: readInt('totalMes'),
      racha: readInt('racha'),
    );
  }
}

class ApiService {
  final Uri _base = Uri.parse(AppConfig.apiBaseUrl);

  // ── LOGIN ──────────────────────────────────────────────────────────────────
  Future<AuthResult> login({required String email, required String password}) async {
    final json = await _post('login', {'email': email, 'password': password});
    return AuthResult(
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token']?.toString() ?? '',
    );
  }

  // ── OLVIDÉ MI CONTRASEÑA ──────────────────────────────────────────────────
  /// Paso 1: solicita el envío del código de recuperación al correo.
  Future<void> forgotPasswordRequest({required String email}) async {
    await _post('forgot_password_request', {'email': email});
  }

  /// Paso 2: valida el código ingresado (sin consumirlo todavía).
  Future<void> forgotPasswordVerify({
    required String email,
    required String codigo,
  }) async {
    await _post('forgot_password_verify', {'email': email, 'codigo': codigo});
  }

  /// Paso 3: guarda la nueva contraseña, reutilizando el mismo código
  /// validado en el paso anterior.
  Future<void> forgotPasswordReset({
    required String email,
    required String codigo,
    required String nuevaPassword,
  }) async {
    await _post('forgot_password_reset', {
      'email': email,
      'codigo': codigo,
      'password': nuevaPassword,
    });
  }

  // ── USUARIOS ───────────────────────────────────────────────────────────────
  Future<List<AppUser>> listUsers(String token) async {
    final json = await _post('users', {'token': token});
    return (json['users'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(AppUser.fromJson)
        .toList();
  }

  Future<void> deleteUser({required String token, required int id}) async {
    await _post('deleteUser', {'token': token, 'id': id.toString()});
  }

  // ── COMPROBANTES DE PAGO ──────────────────────────────────────────────────
  Future<List<ComprobanteModel>> fetchComprobantes({
    required String token,
    required int userId,
  }) async {
    final json = await _post('facturas', {
      'token': token,
      'userId': userId.toString(),
    });
    return (json['facturas'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ComprobanteModel.fromJson)
        .toList();
  }

  Future<ComprobanteDetalleModel> fetchComprobanteDetalle({
    required String token,
    required int idComprobante,
  }) async {
    final json = await _post('factura_detalle', {
      'token': token,
      'id_factura': idComprobante.toString(),
    });
    return ComprobanteDetalleModel.fromJson(json['factura'] as Map<String, dynamic>);
  }

  // ── RUTINAS ────────────────────────────────────────────────────────────────
  // Las rutinas solo las asigna el administrador/entrenador después de una
  // evaluación física (igual que en el proyecto NetBeans: GestionRutinasServlet
  // rechaza "crear" y "eliminar" desde la cuenta del cliente). Por eso aquí solo
  // hay lectura.
  Future<List<RutinaModel>> fetchRutinas({
    required String token,
    required int userId,
  }) async {
    final json = await _post('rutinas', {
      'token': token,
      'userId': userId.toString(),
    });
    return (json['rutinas'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(RutinaModel.fromJson)
        .toList();
  }

  // ── REGISTROS ──────────────────────────────────────────────────────────────
  Future<List<RegistroModel>> fetchRegistros({
    required String token,
    required int userId,
  }) async {
    final json = await _post('registros', {
      'token': token,
      'userId': userId.toString(),
    });
    return (json['registros'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(RegistroModel.fromJson)
        .toList();
  }

  Future<void> crearRegistro({
    required String token,
    required String ejercicio,
    required int repeticiones,
    required double peso,
  }) async {
    await _post('crear_registro', {
      'token': token,
      'ejercicio': ejercicio,
      'repeticiones': repeticiones.toString(),
      'peso': peso.toString(),
    });
  }

  Future<void> eliminarRegistro({required String token, required int id}) async {
    await _post('eliminar_registro', {'token': token, 'id': id.toString()});
  }

  // ── METAS ──────────────────────────────────────────────────────────────────
  Future<List<MetaModel>> fetchMetas({
    required String token,
    required int userId,
  }) async {
    final json = await _post('metas', {
      'token': token,
      'userId': userId.toString(),
    });
    return (json['metas'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(MetaModel.fromJson)
        .toList();
  }

  Future<void> crearMeta({
    required String token,
    required String ejercicio,
    required int meta,
  }) async {
    await _post('crear_meta', {
      'token': token,
      'ejercicio': ejercicio,
      'meta': meta.toString(),
    });
  }

  Future<void> eliminarMeta({required String token, required int id}) async {
    await _post('eliminar_meta', {'token': token, 'id': id.toString()});
  }

  // ── ASISTENCIA ─────────────────────────────────────────────────────────────
  /// Total de días asistidos esta semana.
  Future<AsistenciaResumen> fetchAsistenciaMes({required String token}) async {
    final json = await _post('asistencia_mes', {'token': token});
    return AsistenciaResumen.fromJson(json);
  }

  /// Registra la asistencia de hoy. Devuelve el nuevo total de la semana.
  Future<AsistenciaResumen> registrarAsistencia({required String token}) async {
    final json = await _post('registrar_asistencia', {'token': token});
    return AsistenciaResumen.fromJson(json);
  }

  // ── EVALUACIONES ───────────────────────────────────────────────────────────
  Future<List<EvaluacionModel>> fetchEvaluaciones({
    required String token,
    required int userId,
  }) async {
    final json = await _post('evaluaciones', {
      'token': token,
      'userId': userId.toString(),
    });
    return (json['evaluaciones'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(EvaluacionModel.fromJson)
        .toList();
  }

  // ── CLASES ─────────────────────────────────────────────────────────────────
  Future<List<ClaseModel>> fetchClases({required String token}) async {
    final json = await _post('clases', {'token': token});
    return (json['clases'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ClaseModel.fromJson)
        .toList();
  }

  Future<List<ClaseModel>> fetchMisClases({required String token}) async {
    final json = await _post('mis_clases', {'token': token});
    return (json['clases'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ClaseModel.fromJson)
        .toList();
  }

  Future<void> inscribirClase({required String token, required int id}) async {
    await _post('inscribir_clase', {'token': token, 'id': id.toString()});
  }

  Future<void> desinscribirClase({required String token, required int id}) async {
    await _post('desinscribir_clase', {'token': token, 'id': id.toString()});
  }

  // ── PRODUCTOS ──────────────────────────────────────────────────────────────
  Future<List<ProductoModel>> fetchProductos({required String token}) async {
    final json = await _post('productos', {'token': token});
    return (json['productos'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ProductoModel.fromJson)
        .toList();
  }

  /// Pide al servidor los datos firmados para abrir el Web Checkout de
  /// Wompi para un producto. El pago en si se completa en el navegador.
  Future<WompiCheckoutData> iniciarCompraProducto({
    required String token,
    required int idProducto,
  }) async {
    final json = await _post('iniciar_compra_producto', {
      'token': token,
      'idProducto': idProducto.toString(),
    });
    return WompiCheckoutData.fromJson(json);
  }

  // ── PERFIL (avatar, foto, sexo, seguridad) ────────────────────────────────
  Future<PerfilInfo> fetchPerfilInfo({required String token}) async {
    final json = await _post('perfil_info', {'token': token});
    return PerfilInfo.fromJson(json);
  }

  Future<void> actualizarAvatar({
    required String token,
    required String codigoAvatar,
  }) async {
    await _post('perfil_avatar', {'token': token, 'avatar': codigoAvatar});
  }

  /// Sube la foto de perfil (multipart/form-data, no puede ir por el _post
  /// normal porque ese usa application/x-www-form-urlencoded).
  /// Sube la foto de perfil como bytes en vez de por ruta de archivo, porque
  /// MultipartFile.fromPath necesita dart:io (no existe en Flutter Web).
  /// También fijamos el contentType a mano: si no se especifica, el paquete
  /// http lo manda como application/octet-stream y el backend lo rechaza
  /// aunque el archivo sí sea PNG/JPG.
  Future<void> subirFotoPerfil({
    required String token,
    required Uint8List bytes,
    required String filename,
    String? mimeType,
  }) async {
    final request = http.MultipartRequest('POST', _base)
      ..fields['action'] = 'perfil_foto'
      ..fields['token'] = token
      ..files.add(http.MultipartFile.fromBytes(
        'foto',
        bytes,
        filename: filename,
        contentType: _tipoImagen(filename, mimeType),
      ));

    http.StreamedResponse enviado;
    try {
      enviado = await request.send().timeout(const Duration(seconds: 20));
    } catch (_) {
      throw const ApiException('No se pudo conectar con el servidor.');
    }
    final response = await http.Response.fromStream(enviado);
    _decodificarOLanzar(response);
  }

  MediaType _tipoImagen(String filename, String? mimeHint) {
    final mime = (mimeHint ?? '').toLowerCase();
    if (mime == 'image/png') return MediaType('image', 'png');
    if (mime == 'image/jpeg' || mime == 'image/jpg') return MediaType('image', 'jpeg');
    return filename.toLowerCase().endsWith('.png')
        ? MediaType('image', 'png')
        : MediaType('image', 'jpeg');
  }

  /// URL de imagen para mostrar la foto de perfil con Image.network.
  /// [version] sirve para forzar que se vuelva a pedir después de subir una
  /// foto nueva (Image.network cachea por URL).
  String urlFotoPerfil(String token, {int version = 0}) {
    return '${AppConfig.apiBaseUrl}?action=perfil_foto_ver&token=${Uri.encodeQueryComponent(token)}&v=$version';
  }

  Future<void> solicitarCodigoPerfil({required String token}) async {
    await _post('perfil_solicitar_codigo', {'token': token});
  }

  Future<void> cambiarPasswordPerfil({
    required String token,
    required String codigo,
    required String password,
    required String confirmPassword,
  }) async {
    await _post('perfil_cambiar_password', {
      'token': token,
      'codigo': codigo,
      'password': password,
      'confirmPassword': confirmPassword,
    });
  }

  // ── HTTP ───────────────────────────────────────────────────────────────────
  Map<String, dynamic> _decodificarOLanzar(http.Response response) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Respuesta inválida del servidor:\n${response.body}');
    }
    if (response.statusCode >= 400 || json['ok'] != true) {
      throw ApiException(
        json['message']?.toString() ?? 'Error ${response.statusCode}',
      );
    }
    return json;
  }

  Future<Map<String, dynamic>> _post(
    String action,
    Map<String, String> body,
  ) async {
    late http.Response response;
    try {
      response = await http
          .post(
            _base,
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
            },
            body: {'action': action, ...body},
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw const ApiException('No se pudo conectar con el servidor.');
    }
    return _decodificarOLanzar(response);
  }
}

