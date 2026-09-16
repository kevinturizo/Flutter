import 'package:flutter/material.dart';
import 'login_screen.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  Constantes globales de diseño y configuración
// ══════════════════════════════════════════════════════════════════════════════

const Color kBg       = Color(0xFF0D0D0D);
const Color kSurface  = Color(0xFF1C1C1C);
const Color kCard     = Color(0xFF252525);
const Color kBorder   = Color(0xFF2E2E2E);
const Color kAccent   = Color(0xFFE85D04);
const Color kAccentBg = Color(0xFF2A1500);
const Color kText     = Colors.white;
const Color kTextSub  = Color(0xFF9CA3AF);
const Color kTextDim  = Color(0xFF6B7280);
const Color kGreen    = Color(0xFF22C55E);
const Color kGreenBg  = Color(0xFF1A3A1A);
const Color kRed      = Color(0xFFEF4444);
const Color kYellow   = Color(0xFFFBBF24);
const Color kSidebar  = Color(0xFF161616);

// ══════════════════════════════════════════════════════════════════════════════
//  AdminScreen — pantalla principal del panel
// ══════════════════════════════════════════════════════════════════════════════

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _seccionActual = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(Icons.people_outline,          Icons.people,            'Usuarios'),
    _NavItem(Icons.sports_outlined,         Icons.sports,            'Clases'),
    _NavItem(Icons.person_add_outlined,     Icons.person_add,        'Registrar'),
    _NavItem(Icons.event_note_outlined,     Icons.event_note,        'Vencimientos'),
    _NavItem(Icons.flag_outlined,           Icons.flag,              'Metas'),
    _NavItem(Icons.receipt_outlined,        Icons.receipt,           'Facturas'),
    _NavItem(Icons.location_on_outlined,    Icons.location_on,       'Sedes'),
    _NavItem(Icons.local_shipping_outlined, Icons.local_shipping,    'Proveedores'),
    _NavItem(Icons.inventory_2_outlined,    Icons.inventory_2,       'Productos'),
    _NavItem(Icons.badge_outlined,          Icons.badge,             'Roles'),
    _NavItem(Icons.description_outlined,    Icons.description,       'Tipo doc'),
    _NavItem(Icons.payment_outlined,        Icons.payment,           'Pagos'),
    _NavItem(Icons.card_membership_outlined,Icons.card_membership,   'Membresías'),
    _NavItem(Icons.monitor_weight_outlined, Icons.monitor_weight,    'Evaluaciones'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: Row(
        children: [
          _buildSidebar(),
          const VerticalDivider(width: 1, thickness: 1, color: Color(0xFF1E1E1E)),
          Expanded(child: _buildSeccion(_seccionActual)),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: kSidebar,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.fitness_center, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FitManager', style: TextStyle(color: kText, fontSize: 16, fontWeight: FontWeight.w700)),
              Text('Panel Admin', style: TextStyle(color: kAccent, fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: kCard,
            child: Text('AD', style: TextStyle(color: kAccent, fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ),
        IconButton(
          icon: Icon(Icons.logout, color: kTextSub, size: 20),
          onPressed: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const LoginScreen())),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return SizedBox(
      width: 64,
      child: Container(
        color: kSidebar,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              ...List.generate(_navItems.length, (i) {
                final item = _navItems[i];
                final selected = _seccionActual == i;
                return Tooltip(
                  message: item.label,
                  preferBelow: false,
                  child: InkWell(
                    onTap: () => setState(() => _seccionActual = i),
                    child: Container(
                      width: 64, height: 56,
                      decoration: BoxDecoration(
                        color: selected ? kAccentBg : Colors.transparent,
                        border: selected
                            ? Border(left: BorderSide(color: kAccent, width: 3))
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(selected ? item.iconOn : item.iconOff,
                              color: selected ? kAccent : kTextDim, size: 22),
                          const SizedBox(height: 2),
                          Text(item.label,
                              style: TextStyle(fontSize: 8, color: selected ? kAccent : kTextDim),
                              overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeccion(int i) {
    switch (i) {
      case 0:  return const _SeccionUsuarios();
      case 1:  return const _SeccionClases();
      case 2:  return const _SeccionRegistrarUsuario();
      case 3:  return const _SeccionVencimientos();
      case 4:  return const _SeccionMetasAdmin();
      case 5:  return const _SeccionFacturasAdmin();
      case 6:  return const _SeccionSedes();
      case 7:  return const _SeccionProveedores();
      case 8:  return const _SeccionProductosAdmin();
      case 9:  return const _SeccionCatalogo(titulo: 'Roles',              icono: Icons.badge_outlined,       tipo: 'rol',          campos: ['Descripción del rol']);
      case 10: return const _SeccionCatalogo(titulo: 'Tipos de Documento', icono: Icons.description_outlined, tipo: 'tipoDocumento', campos: ['Descripción']);
      case 11: return const _SeccionCatalogo(titulo: 'Métodos de Pago',    icono: Icons.payment_outlined,     tipo: 'metodoPago',   campos: ['Descripción']);
      case 12: return const _SeccionMembresias();
      case 13: return const _SeccionEvaluacionesAdmin();
      default: return const _SeccionUsuarios();
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Sección: Usuarios
// ══════════════════════════════════════════════════════════════════════════════

class _SeccionUsuarios extends StatefulWidget {
  const _SeccionUsuarios();
  @override
  State<_SeccionUsuarios> createState() => _SeccionUsuariosState();
}

class _SeccionUsuariosState extends State<_SeccionUsuarios> {
  final _busCtrl = TextEditingController();
  String _filtro = '';
  bool _cargando = true;
  String? _error;

  List<Map<String, dynamic>> _usuarios = [];

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      _cargando = false;
      _usuarios = [
        {'id': 1,  'nombre': 'Alan Cruz',    'correo': 'AlanCru@gmail.com',      'rol': 'Cliente',       'membresia': 'Diaria',    'vencimiento': '2026-06-15', 'documento': '1012508006', 'tipoDoc': 'C.C'},
        {'id': 2,  'nombre': 'Dylan Vera',   'correo': 'dverapenuela@gmail.com', 'rol': 'Administrador', 'membresia': 'Anual',     'vencimiento': null,         'documento': '1013609004', 'tipoDoc': 'C.C'},
        {'id': 5,  'nombre': 'Maria Pilar',  'correo': 'Mariapilar@gmail.com',   'rol': 'Cliente',       'membresia': 'Trimestral','vencimiento': '2026-07-01', 'documento': '53099689',   'tipoDoc': 'C.C'},
        {'id': 6,  'nombre': 'Kevin Turizo', 'correo': 'ke2812007@gmail.com',    'rol': 'Administrador', 'membresia': 'Anual',     'vencimiento': null,         'documento': '1028885474', 'tipoDoc': 'C.C'},
        {'id': 11, 'nombre': 'Pedro Narvaez','correo': 'pedronar@gmail.com',     'rol': 'Cliente',       'membresia': 'Bimestral', 'vencimiento': '2026-08-20', 'documento': '1039687994', 'tipoDoc': 'C.C'},
      ];
    });
  }

  Future<void> _eliminarUsuario(Map<String, dynamic> u) async {
    final confirm = await _confirmarDialog(context, '¿Eliminar a ${u['nombre']}?',
        'Esta acción no se puede deshacer. El usuario debe no tener membresía activa ni facturas registradas.');
    if (!confirm) return;
    setState(() => _usuarios.remove(u));
    if (mounted) _snack(context, 'Usuario eliminado', ok: true);
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const _Cargando();
    if (_error != null) return _ErrorWidget(mensaje: _error!);

    final filtrados = _usuarios.where((u) =>
        u['nombre'].toString().toLowerCase().contains(_filtro.toLowerCase()) ||
        u['correo'].toString().toLowerCase().contains(_filtro.toLowerCase())).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TituloSeccion('Usuarios registrados (${filtrados.length})', Icons.people),
          const SizedBox(height: 14),
          _Buscador(ctrl: _busCtrl, hint: 'Buscar por nombre o correo…', onChanged: (v) => setState(() => _filtro = v)),
          const SizedBox(height: 14),
          if (filtrados.isEmpty)
            const _EmptyState(mensaje: 'No hay usuarios que coincidan con la búsqueda.')
          else
            ...filtrados.map((u) => _UsuarioTile(usuario: u, onDelete: () => _eliminarUsuario(u))),
        ],
      ),
    );
  }
}

class _UsuarioTile extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final VoidCallback onDelete;
  const _UsuarioTile({required this.usuario, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final esAdmin = usuario['rol'] == 'Administrador';
    final vencimiento = usuario['vencimiento'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: kCard,
            child: Text(usuario['nombre'].toString().substring(0, 1),
                style: TextStyle(color: kAccent, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(usuario['nombre'].toString(),
                    style: TextStyle(color: kText, fontWeight: FontWeight.w600, fontSize: 13)),
                Text(usuario['correo'].toString(),
                    style: TextStyle(color: kTextSub, fontSize: 11)),
                const SizedBox(height: 2),
                Text('${usuario['tipoDoc']}: ${usuario['documento']}',
                    style: TextStyle(color: kTextDim, fontSize: 10)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Badge(label: usuario['rol'].toString(),
                  bgColor: esAdmin ? kAccentBg : kGreenBg,
                  textColor: esAdmin ? kAccent : kGreen),
              const SizedBox(height: 4),
              _Badge(label: usuario['membresia'].toString(),
                  bgColor: kCard, textColor: kTextSub),
              const SizedBox(height: 2),
              if (vencimiento != null)
                Text('Vence: $vencimiento',
                    style: TextStyle(color: kYellow, fontSize: 9, fontWeight: FontWeight.w600))
              else
                Text('Sin vencimiento', style: TextStyle(color: kTextDim, fontSize: 9)),
            ],
          ),
          const SizedBox(width: 8),
          if (!esAdmin)
            IconButton(
              icon: Icon(Icons.delete_outline, color: kRed, size: 18),
              onPressed: onDelete,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Sección: Clases
// ══════════════════════════════════════════════════════════════════════════════

class _SeccionClases extends StatefulWidget {
  const _SeccionClases();
  @override
  State<_SeccionClases> createState() => _SeccionClasesState();
}

class _SeccionClasesState extends State<_SeccionClases> {
  final _nombreCtrl     = TextEditingController();
  final _horaCtrl       = TextEditingController();
  final _instructorCtrl = TextEditingController();
  String _dia = 'Lunes';
  bool _guardando = false;

  final List<String> _dias = ['Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo'];

  // ignore: prefer_final_fields
  List<Map<String, dynamic>> _clases = [
    {'id': 1, 'nombre': 'Spinning',  'dia': 'Lunes',     'hora': '6:00 AM',  'instructor': 'Instructor'},
    {'id': 2, 'nombre': 'Funcional', 'dia': 'Martes',    'hora': '7:00 AM',  'instructor': 'Instructor'},
    {'id': 3, 'nombre': 'Yoga',      'dia': 'Miércoles', 'hora': '8:00 AM',  'instructor': 'Instructor'},
    {'id': 4, 'nombre': 'Crossfit',  'dia': 'Jueves',    'hora': '5:00 PM',  'instructor': 'Instructor'},
    {'id': 5, 'nombre': 'Pilates',   'dia': 'Viernes',   'hora': '9:00 AM',  'instructor': 'Instructor'},
    {'id': 6, 'nombre': 'Zumba',     'dia': 'Sábado',    'hora': '10:00 AM', 'instructor': 'Instructor'},
  ];

  Future<void> _agregarClase() async {
    if (_nombreCtrl.text.trim().isEmpty || _instructorCtrl.text.trim().isEmpty) {
      _snack(context, 'Nombre e instructor son obligatorios', ok: false);
      return;
    }
    setState(() => _guardando = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _clases.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch,
        'nombre': _nombreCtrl.text.trim(),
        'dia': _dia,
        'hora': _horaCtrl.text.trim(),
        'instructor': _instructorCtrl.text.trim(),
      });
      _nombreCtrl.clear(); _horaCtrl.clear(); _instructorCtrl.clear();
      _guardando = false;
    });
    if (mounted) _snack(context, 'Clase agregada correctamente', ok: true);
  }

  Future<void> _eliminarClase(Map<String, dynamic> c) async {
    final ok = await _confirmarDialog(context, '¿Eliminar "${c['nombre']}"?', 'Los usuarios inscritos perderán la inscripción.');
    if (!ok) return;
    setState(() => _clases.remove(c));
    if (mounted) _snack(context, 'Clase eliminada', ok: true);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TituloSeccion('Gestionar Clases', Icons.sports),
          const SizedBox(height: 16),
          _FormCard(
            titulo: 'Nueva clase',
            child: Column(
              children: [
                _Field(ctrl: _nombreCtrl, label: 'Nombre de la clase', icon: Icons.sports),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _Dropdown(value: _dia, items: _dias, onChanged: (v) => setState(() => _dia = v!))),
                    const SizedBox(width: 10),
                    Expanded(child: _Field(ctrl: _horaCtrl, label: 'Hora (ej: 6:00 AM)', icon: Icons.access_time_outlined)),
                  ],
                ),
                const SizedBox(height: 10),
                _Field(ctrl: _instructorCtrl, label: 'Instructor', icon: Icons.person_outline),
                const SizedBox(height: 14),
                _BtnPrimary(label: _guardando ? 'Guardando…' : 'Agregar clase', onTap: _guardando ? null : _agregarClase),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SubTitulo('Clases activas (${_clases.length})'),
          const SizedBox(height: 10),
          ..._clases.map((c) => _ClaseTile(clase: c, onDelete: () => _eliminarClase(c))),
        ],
      ),
    );
  }
}

class _ClaseTile extends StatelessWidget {
  final Map<String, dynamic> clase;
  final VoidCallback onDelete;
  const _ClaseTile({required this.clase, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: kAccentBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.sports, color: kAccent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(clase['nombre'].toString(), style: TextStyle(color: kText, fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text('${clase['dia']} · ${clase['hora']} · ${clase['instructor']}',
                    style: TextStyle(color: kTextSub, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: kRed, size: 18),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Sección: Registrar Usuario
// ══════════════════════════════════════════════════════════════════════════════

class _SeccionRegistrarUsuario extends StatefulWidget {
  const _SeccionRegistrarUsuario();
  @override
  State<_SeccionRegistrarUsuario> createState() => _SeccionRegistrarUsuarioState();
}

class _SeccionRegistrarUsuarioState extends State<_SeccionRegistrarUsuario> {
  final _nombresCtrl = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _docCtrl     = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String _tipoDoc   = '2';
  String _membresia = '2';
  String _rol       = '2';
  bool _guardando  = false;
  bool _verPass    = false;
  bool _verConfirm = false;

  final List<Map<String, String>> _tiposDoc = [
    {'id': '1', 'desc': 'T.I — Tarjeta de Identidad'},
    {'id': '2', 'desc': 'C.C — Cédula de Ciudadanía'},
    {'id': '3', 'desc': 'C.E — Cédula de Extranjería'},
    {'id': '4', 'desc': 'P.E.P — Permiso de Permanencia'},
    {'id': '5', 'desc': 'P.A — Pasaporte'},
  ];

  final List<Map<String, String>> _membresias = [
    {'id': '1', 'desc': 'Diaria — \$5.000'},
    {'id': '2', 'desc': 'Mensual — \$50.000'},
    {'id': '3', 'desc': 'Bimestral — \$90.000'},
    {'id': '4', 'desc': 'Trimestral — \$130.000'},
    {'id': '5', 'desc': 'Semestral — \$245.000'},
    {'id': '6', 'desc': 'Anual — \$450.000'},
  ];

  final List<Map<String, String>> _roles = [
    {'id': '1', 'desc': 'Administrador'},
    {'id': '2', 'desc': 'Cliente'},
  ];

  Future<void> _registrar() async {
    if (_nombresCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty ||
        _docCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      _snack(context, 'Completa todos los campos', ok: false);
      return;
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      _snack(context, 'Las contraseñas no coinciden', ok: false);
      return;
    }
    setState(() => _guardando = true);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _guardando = false);
    if (mounted) {
      _snack(context, 'Usuario registrado correctamente', ok: true);
      _nombresCtrl.clear(); _emailCtrl.clear();
      _docCtrl.clear(); _passCtrl.clear(); _confirmCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TituloSeccion('Registrar Usuario', Icons.person_add),
          const SizedBox(height: 16),
          _FormCard(
            titulo: 'Nuevo usuario',
            child: Column(
              children: [
                _Field(ctrl: _nombresCtrl, label: 'Nombre completo (nombre y apellido)', icon: Icons.person_outline),
                const SizedBox(height: 10),
                _Field(ctrl: _emailCtrl, label: 'Correo electrónico', icon: Icons.email_outlined, keyboard: TextInputType.emailAddress),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _DropdownMap(value: _tipoDoc, items: _tiposDoc, onChanged: (v) => setState(() => _tipoDoc = v!))),
                    const SizedBox(width: 10),
                    Expanded(child: _Field(ctrl: _docCtrl, label: 'Número de documento', icon: Icons.badge_outlined, keyboard: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _DropdownMap(value: _membresia, items: _membresias, onChanged: (v) => setState(() => _membresia = v!))),
                    const SizedBox(width: 10),
                    Expanded(child: _DropdownMap(value: _rol, items: _roles, onChanged: (v) => setState(() => _rol = v!))),
                  ],
                ),
                const SizedBox(height: 10),
                _Field(ctrl: _passCtrl, label: 'Contraseña', icon: Icons.lock_outline,
                    obscure: !_verPass,
                    suffix: IconButton(
                        icon: Icon(_verPass ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: kTextDim, size: 18),
                        onPressed: () => setState(() => _verPass = !_verPass))),
                const SizedBox(height: 10),
                _Field(ctrl: _confirmCtrl, label: 'Confirmar contraseña', icon: Icons.lock_outline,
                    obscure: !_verConfirm,
                    suffix: IconButton(
                        icon: Icon(_verConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: kTextDim, size: 18),
                        onPressed: () => setState(() => _verConfirm = !_verConfirm))),
                const SizedBox(height: 16),
                _BtnPrimary(label: _guardando ? 'Registrando…' : 'Registrar usuario', onTap: _guardando ? null : _registrar),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Sección: Vencimientos
// ══════════════════════════════════════════════════════════════════════════════

class _SeccionVencimientos extends StatefulWidget {
  const _SeccionVencimientos();
  @override
  State<_SeccionVencimientos> createState() => _SeccionVencimientosState();
}

class _SeccionVencimientosState extends State<_SeccionVencimientos> {
  final _correoCtrl = TextEditingController();
  DateTime? _fecha;
  bool _guardando = false;

  final List<Map<String, dynamic>> _vencimientos = [
    {'nombre': 'Alan Cruz',    'correo': 'AlanCru@gmail.com',    'membresia': 'Diaria',    'vence': '2026-06-15'},
    {'nombre': 'Maria Pilar',  'correo': 'Mariapilar@gmail.com', 'membresia': 'Trimestral','vence': '2026-07-01'},
    {'nombre': 'Pedro Narvaez','correo': 'pedronar@gmail.com',   'membresia': 'Bimestral', 'vence': '2026-08-20'},
  ];

  Future<void> _asignarVencimiento() async {
    if (_correoCtrl.text.trim().isEmpty || _fecha == null) {
      _snack(context, 'Correo y fecha son obligatorios', ok: false);
      return;
    }
    setState(() => _guardando = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _guardando = false);
    if (mounted) {
      _snack(context, 'Vencimiento actualizado correctamente', ok: true);
      _correoCtrl.clear();
      setState(() => _fecha = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TituloSeccion('Asignar Vencimiento', Icons.event_note),
          const SizedBox(height: 16),
          _FormCard(
            titulo: 'Actualizar vencimiento',
            child: Column(
              children: [
                _Field(ctrl: _correoCtrl, label: 'Correo del usuario', icon: Icons.email_outlined, keyboard: TextInputType.emailAddress),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      builder: (ctx, child) => Theme(
                        data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: kAccent)),
                        child: child!,
                      ),
                    );
                    if (d != null) setState(() => _fecha = d);
                  },
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        color: kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: kBorder)),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, color: kTextSub, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _fecha == null
                              ? 'Seleccionar nueva fecha de vencimiento'
                              : '${_fecha!.day.toString().padLeft(2, '0')}/${_fecha!.month.toString().padLeft(2, '0')}/${_fecha!.year}',
                          style: TextStyle(color: _fecha == null ? kTextDim : kText, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _BtnPrimary(label: _guardando ? 'Guardando…' : 'Asignar vencimiento', onTap: _guardando ? null : _asignarVencimiento),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SubTitulo('Vencimientos activos'),
          const SizedBox(height: 10),
          ..._vencimientos.map((v) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
                child: Row(
                  children: [
                    Icon(Icons.event, color: kAccent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v['nombre'].toString(), style: TextStyle(color: kText, fontWeight: FontWeight.w600, fontSize: 13)),
                          Text('${v['correo']} · ${v['membresia']}', style: TextStyle(color: kTextSub, fontSize: 11)),
                        ],
                      ),
                    ),
                    Text('Vence: ${v['vence']}', style: TextStyle(color: kYellow, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Sección: Metas
// ══════════════════════════════════════════════════════════════════════════════

class _SeccionMetasAdmin extends StatefulWidget {
  const _SeccionMetasAdmin();
  @override
  State<_SeccionMetasAdmin> createState() => _SeccionMetasAdminState();
}

class _SeccionMetasAdminState extends State<_SeccionMetasAdmin> {
  final _correoCtrl    = TextEditingController();
  final _ejercicioCtrl = TextEditingController();
  final _metaCtrl      = TextEditingController();
  bool _guardando = false;

  // ignore: prefer_final_fields
  List<Map<String, dynamic>> _metas = [
    {'id': 1, 'usuario': 'Alan Cruz',   'correo': 'AlanCru@gmail.com',    'ejercicio': 'Press banca', 'meta': 20},
    {'id': 2, 'usuario': 'Maria Pilar', 'correo': 'Mariapilar@gmail.com', 'ejercicio': 'Sentadilla',  'meta': 30},
  ];

  Future<void> _asignarMeta() async {
    if (_correoCtrl.text.trim().isEmpty || _ejercicioCtrl.text.trim().isEmpty || _metaCtrl.text.trim().isEmpty) {
      _snack(context, 'Todos los campos son obligatorios', ok: false);
      return;
    }
    final valor = int.tryParse(_metaCtrl.text.trim());
    if (valor == null || valor <= 0) {
      _snack(context, 'La meta debe ser un número entero mayor a 0', ok: false);
      return;
    }
    setState(() => _guardando = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _metas.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch,
        'usuario': _correoCtrl.text.trim(),
        'correo': _correoCtrl.text.trim(),
        'ejercicio': _ejercicioCtrl.text.trim(),
        'meta': valor,
      });
      _correoCtrl.clear(); _ejercicioCtrl.clear(); _metaCtrl.clear();
      _guardando = false;
    });
    if (mounted) _snack(context, 'Meta asignada correctamente', ok: true);
  }

  Future<void> _eliminarMeta(Map<String, dynamic> m) async {
    setState(() => _metas.remove(m));
    _snack(context, 'Meta eliminada', ok: true);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TituloSeccion('Asignar Metas', Icons.flag),
          const SizedBox(height: 16),
          _FormCard(
            titulo: 'Nueva meta',
            child: Column(
              children: [
                _Field(ctrl: _correoCtrl, label: 'Correo del usuario', icon: Icons.email_outlined, keyboard: TextInputType.emailAddress),
                const SizedBox(height: 10),
                _Field(ctrl: _ejercicioCtrl, label: 'Ejercicio (ej: Sentadilla)', icon: Icons.fitness_center_outlined),
                const SizedBox(height: 10),
                _Field(ctrl: _metaCtrl, label: 'Meta en repeticiones (número entero)', icon: Icons.flag_outlined, keyboard: TextInputType.number),
                const SizedBox(height: 14),
                _BtnPrimary(label: _guardando ? 'Guardando…' : 'Asignar meta', onTap: _guardando ? null : _asignarMeta),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SubTitulo('Metas asignadas (${_metas.length})'),
          const SizedBox(height: 10),
          ..._metas.map((m) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
                child: Row(
                  children: [
                    Icon(Icons.flag, color: kAccent, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m['usuario'].toString(), style: TextStyle(color: kText, fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(m['ejercicio'].toString(), style: TextStyle(color: kTextSub, fontSize: 11)),
                        ],
                      ),
                    ),
                    Text('${m['meta']} reps', style: TextStyle(color: kAccent, fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: kRed, size: 16),
                      onPressed: () => _eliminarMeta(m),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Sección: Facturas
// ══════════════════════════════════════════════════════════════════════════════

class _SeccionFacturasAdmin extends StatelessWidget {
  const _SeccionFacturasAdmin();

  static const _cabeceras = [
    {'id': 1, 'numero': 'FAC-001', 'usuario': 'Alan Cruz',    'correo': 'AlanCru@gmail.com',    'metodoPago': 'Efectivo',     'valorTotal': '5.000',   'fecha': '2026-06-10'},
    {'id': 2, 'numero': 'FAC-002', 'usuario': 'Maria Pilar',  'correo': 'Mariapilar@gmail.com', 'metodoPago': 'Tarjeta',      'valorTotal': '130.000', 'fecha': '2026-06-08'},
    {'id': 3, 'numero': 'FAC-003', 'usuario': 'Pedro Narvaez','correo': 'pedronar@gmail.com',   'metodoPago': 'Transferencia','valorTotal': '90.000',  'fecha': '2026-06-05'},
  ];

  static const _detalle = [
    {'numeroFactura': 'FAC-001', 'producto': 'Botella De Agua', 'precio': '5.000',   'cantidad': 1, 'usuario': 'Alan Cruz'},
    {'numeroFactura': 'FAC-002', 'producto': 'Creatina',        'precio': '120.000', 'cantidad': 1, 'usuario': 'Maria Pilar'},
    {'numeroFactura': 'FAC-003', 'producto': 'Proteina',        'precio': '90.000',  'cantidad': 1, 'usuario': 'Pedro Narvaez'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TituloSeccion('Facturas', Icons.receipt),
          const SizedBox(height: 16),
          _SubTitulo('Cabeceras de factura'),
          const SizedBox(height: 10),
          ..._cabeceras.map((f) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: kAccentBg, borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.receipt, color: kAccent, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${f['numero']} · ${f['usuario']}',
                              style: TextStyle(color: kText, fontWeight: FontWeight.w600, fontSize: 13)),
                          Text('${f['metodoPago']} · ${f['fecha']}',
                              style: TextStyle(color: kTextSub, fontSize: 11)),
                        ],
                      ),
                    ),
                    Text('\$${f['valorTotal']}',
                        style: TextStyle(color: kAccent, fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          _SubTitulo('Detalle de productos por factura'),
          const SizedBox(height: 10),
          ..._detalle.map((d) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(10), border: Border.all(color: kBorder)),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2, color: kAccent, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${d['numeroFactura']} — ${d['producto']}', style: TextStyle(color: kText, fontSize: 12, fontWeight: FontWeight.w600)),
                          Text('${d['usuario']} · Cant: ${d['cantidad']}', style: TextStyle(color: kTextSub, fontSize: 11)),
                        ],
                      ),
                    ),
                    Text('\$${d['precio']}', style: TextStyle(color: kAccent, fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Sección: Sedes
// ══════════════════════════════════════════════════════════════════════════════

class _SeccionSedes extends StatefulWidget {
  const _SeccionSedes();
  @override
  State<_SeccionSedes> createState() => _SeccionSedesState();
}

class _SeccionSedesState extends State<_SeccionSedes> {
  final _nombreCtrl    = TextEditingController();
  final _direccionCtrl = TextEditingController();
  bool _guardando = false;

  // ignore: prefer_final_fields
  List<Map<String, dynamic>> _sedes = [
    {'id': 1, 'nombre': 'Taurus GYM',   'direccion': 'Cra. 45a #74-38 Sur'},
    {'id': 2, 'nombre': 'Generico GYM', 'direccion': 'Cll 80c sur #68b-39'},
    {'id': 3, 'nombre': 'Bodytech GYM', 'direccion': 'Cl. 12 Sur #31 - 33'},
    {'id': 4, 'nombre': 'SmartFit GYM', 'direccion': 'Cl. 34 Sur #A Sur 34D - 50'},
  ];

  Future<void> _agregar() async {
    if (_nombreCtrl.text.trim().isEmpty || _direccionCtrl.text.trim().isEmpty) {
      _snack(context, 'Nombre y dirección son obligatorios', ok: false);
      return;
    }
    setState(() => _guardando = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _sedes.insert(0, {'id': DateTime.now().millisecondsSinceEpoch, 'nombre': _nombreCtrl.text.trim(), 'direccion': _direccionCtrl.text.trim()});
      _nombreCtrl.clear(); _direccionCtrl.clear(); _guardando = false;
    });
    if (mounted) _snack(context, 'Sede agregada', ok: true);
  }

  Future<void> _eliminar(Map<String, dynamic> s) async {
    final ok = await _confirmarDialog(context, '¿Eliminar "${s['nombre']}"?', '');
    if (!ok) return;
    setState(() => _sedes.remove(s));
    if (mounted) _snack(context, 'Sede eliminada', ok: true);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TituloSeccion('Sedes', Icons.location_on),
          const SizedBox(height: 16),
          _FormCard(
            titulo: 'Nueva sede',
            child: Column(
              children: [
                _Field(ctrl: _nombreCtrl, label: 'Nombre de la sede', icon: Icons.location_on_outlined),
                const SizedBox(height: 10),
                _Field(ctrl: _direccionCtrl, label: 'Dirección', icon: Icons.map_outlined),
                const SizedBox(height: 14),
                _BtnPrimary(label: _guardando ? 'Guardando…' : 'Agregar sede', onTap: _guardando ? null : _agregar),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SubTitulo('Sedes registradas (${_sedes.length})'),
          const SizedBox(height: 10),
          ..._sedes.map((s) => _ItemTile(icon: Icons.location_on, titulo: s['nombre'].toString(), subtitulo: s['direccion'].toString(), onDelete: () => _eliminar(s))),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Sección: Proveedores
// ══════════════════════════════════════════════════════════════════════════════

class _SeccionProveedores extends StatefulWidget {
  const _SeccionProveedores();
  @override
  State<_SeccionProveedores> createState() => _SeccionProveedoresState();
}

class _SeccionProveedoresState extends State<_SeccionProveedores> {
  final _nombreCtrl = TextEditingController();
  final _tipoCtrl   = TextEditingController();
  bool _guardando = false;

  // ignore: prefer_final_fields
  List<Map<String, dynamic>> _proveedores = [
    {'id': 1, 'nombre': 'Pablo Recojedor', 'tipoProducto': 'Proteina'},
    {'id': 2, 'nombre': 'Pedro Carrascal', 'tipoProducto': 'Creatina'},
    {'id': 3, 'nombre': 'Pepe Garcia',     'tipoProducto': 'Pre-entreno'},
    {'id': 4, 'nombre': 'Patricio Fugaz',  'tipoProducto': 'Botilo De Agua'},
    {'id': 5, 'nombre': 'Kristian Rangel', 'tipoProducto': 'Botella De Agua'},
  ];

  Future<void> _agregar() async {
    if (_nombreCtrl.text.trim().isEmpty || _tipoCtrl.text.trim().isEmpty) {
      _snack(context, 'Nombre y tipo de producto son obligatorios', ok: false);
      return;
    }
    setState(() => _guardando = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _proveedores.insert(0, {'id': DateTime.now().millisecondsSinceEpoch, 'nombre': _nombreCtrl.text.trim(), 'tipoProducto': _tipoCtrl.text.trim()});
      _nombreCtrl.clear(); _tipoCtrl.clear(); _guardando = false;
    });
    if (mounted) _snack(context, 'Proveedor agregado', ok: true);
  }

  Future<void> _eliminar(Map<String, dynamic> p) async {
    final ok = await _confirmarDialog(context, '¿Eliminar "${p['nombre']}"?', '');
    if (!ok) return;
    setState(() => _proveedores.remove(p));
    if (mounted) _snack(context, 'Proveedor eliminado', ok: true);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TituloSeccion('Proveedores', Icons.local_shipping),
          const SizedBox(height: 16),
          _FormCard(
            titulo: 'Nuevo proveedor',
            child: Column(
              children: [
                _Field(ctrl: _nombreCtrl, label: 'Nombre del proveedor', icon: Icons.local_shipping_outlined),
                const SizedBox(height: 10),
                _Field(ctrl: _tipoCtrl, label: 'Tipo de producto', icon: Icons.inventory_2_outlined),
                const SizedBox(height: 14),
                _BtnPrimary(label: _guardando ? 'Guardando…' : 'Agregar proveedor', onTap: _guardando ? null : _agregar),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SubTitulo('Proveedores registrados (${_proveedores.length})'),
          const SizedBox(height: 10),
          ..._proveedores.map((p) => _ItemTile(icon: Icons.local_shipping, titulo: p['nombre'].toString(), subtitulo: p['tipoProducto'].toString(), onDelete: () => _eliminar(p))),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Sección: Productos
// ══════════════════════════════════════════════════════════════════════════════

class _SeccionProductosAdmin extends StatefulWidget {
  const _SeccionProductosAdmin();
  @override
  State<_SeccionProductosAdmin> createState() => _SeccionProductosAdminState();
}

class _SeccionProductosAdminState extends State<_SeccionProductosAdmin> {
  final _nombreCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  bool _guardando = false;

  // ignore: prefer_final_fields
  List<Map<String, dynamic>> _productos = [
    {'id': 1, 'nombre': 'Creatina',       'precio': 120000.0},
    {'id': 2, 'nombre': 'Proteina',        'precio': 90000.0},
    {'id': 3, 'nombre': 'Pre-entreno',     'precio': 50000.0},
    {'id': 4, 'nombre': 'Botilo De Agua',  'precio': 25000.0},
    {'id': 5, 'nombre': 'Botella De Agua', 'precio': 5000.0},
  ];

  Future<void> _agregar() async {
    if (_nombreCtrl.text.trim().isEmpty || _precioCtrl.text.trim().isEmpty) {
      _snack(context, 'Nombre y precio son obligatorios', ok: false);
      return;
    }
    final precio = double.tryParse(_precioCtrl.text.trim());
    if (precio == null || precio <= 0) {
      _snack(context, 'Precio inválido', ok: false);
      return;
    }
    setState(() => _guardando = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _productos.insert(0, {'id': DateTime.now().millisecondsSinceEpoch, 'nombre': _nombreCtrl.text.trim(), 'precio': precio});
      _nombreCtrl.clear(); _precioCtrl.clear(); _guardando = false;
    });
    if (mounted) _snack(context, 'Producto agregado', ok: true);
  }

  Future<void> _eliminar(Map<String, dynamic> p) async {
    final ok = await _confirmarDialog(context, '¿Eliminar "${p['nombre']}"?',
        'No es posible si el producto ya tiene facturas registradas.');
    if (!ok) return;
    setState(() => _productos.remove(p));
    if (mounted) _snack(context, 'Producto eliminado', ok: true);
  }

  // ✅ CORREGIDO: (match) en lugar de (_)
  String _formatPrecio(double p) =>
      '\$${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TituloSeccion('Productos', Icons.inventory_2),
          const SizedBox(height: 16),
          _FormCard(
            titulo: 'Nuevo producto',
            child: Column(
              children: [
                _Field(ctrl: _nombreCtrl, label: 'Nombre del producto', icon: Icons.inventory_2_outlined),
                const SizedBox(height: 10),
                _Field(ctrl: _precioCtrl, label: 'Precio (ej: 120000)', icon: Icons.attach_money, keyboard: TextInputType.number),
                const SizedBox(height: 14),
                _BtnPrimary(label: _guardando ? 'Guardando…' : 'Agregar producto', onTap: _guardando ? null : _agregar),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SubTitulo('Productos en tienda (${_productos.length})'),
          const SizedBox(height: 10),
          ..._productos.map((p) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2, color: kAccent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(p['nombre'].toString(),
                        style: TextStyle(color: kText, fontWeight: FontWeight.w600, fontSize: 13))),
                    Text(_formatPrecio(p['precio'] as double),
                        style: TextStyle(color: kAccent, fontWeight: FontWeight.w700, fontSize: 12)),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: kRed, size: 16),
                      onPressed: () => _eliminar(p),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Sección: Catálogo genérico (Roles, Tipo Documento, Método de Pago)
// ══════════════════════════════════════════════════════════════════════════════

class _SeccionCatalogo extends StatefulWidget {
  final String titulo;
  final IconData icono;
  final String tipo;
  final List<String> campos;
  const _SeccionCatalogo({required this.titulo, required this.icono, required this.tipo, required this.campos});
  @override
  State<_SeccionCatalogo> createState() => _SeccionCatalogoState();
}

class _SeccionCatalogoState extends State<_SeccionCatalogo> {
  late final List<TextEditingController> _ctrls;
  bool _guardando = false;
  late List<Map<String, dynamic>> _registros;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(widget.campos.length, (index) => TextEditingController());
    _registros = _datosIniciales();
  }

  List<Map<String, dynamic>> _datosIniciales() {
    switch (widget.tipo) {
      case 'rol':
        return [{'id': 1, 'campos': ['Administrador']}, {'id': 2, 'campos': ['Cliente']}];
      case 'tipoDocumento':
        return [
          {'id': 1, 'campos': ['Tarjeta De Identidad (T.I)']},
          {'id': 2, 'campos': ['Cedula De Ciudadania (C.C)']},
          {'id': 3, 'campos': ['Cedula De Extranjeria (C.E)']},
          {'id': 4, 'campos': ['Permiso Especial de Permanencia (P.E.P)']},
          {'id': 5, 'campos': ['Pasaporte (P.A)']},
        ];
      case 'metodoPago':
        return [
          {'id': 1, 'campos': ['Efectivo']},
          {'id': 2, 'campos': ['Tarjeta']},
          {'id': 3, 'campos': ['Transferencia']},
        ];
      default:
        return [];
    }
  }

  @override
  void dispose() {
    for (var c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_ctrls[0].text.trim().isEmpty) {
      _snack(context, 'Completa el campo obligatorio', ok: false);
      return;
    }
    setState(() => _guardando = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _registros.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch,
        'campos': _ctrls.map((c) => c.text.trim()).toList(),
      });
      for (var c in _ctrls) {
        c.clear();
      }
      _guardando = false;
    });
    if (mounted) _snack(context, 'Registro guardado', ok: true);
  }

  Future<void> _eliminar(Map<String, dynamic> r) async {
    final ok = await _confirmarDialog(context, '¿Eliminar "${r['campos'][0]}"?', '');
    if (!ok) return;
    setState(() => _registros.remove(r));
    if (mounted) _snack(context, 'Eliminado correctamente', ok: true);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TituloSeccion(widget.titulo, widget.icono),
          const SizedBox(height: 16),
          _FormCard(
            titulo: 'Nuevo registro',
            child: Column(
              children: [
                ...List.generate(widget.campos.length, (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _Field(ctrl: _ctrls[i], label: widget.campos[i], icon: widget.icono),
                    )),
                _BtnPrimary(label: _guardando ? 'Guardando…' : 'Guardar', onTap: _guardando ? null : _guardar),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SubTitulo('Registros (${_registros.length})'),
          const SizedBox(height: 10),
          ..._registros.map((r) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
                child: Row(
                  children: [
                    Icon(widget.icono, color: kAccent, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (r['campos'] as List<String>).asMap().entries.map((e) => Text(
                          e.key == 0 ? e.value : '${widget.campos[e.key]}: ${e.value}',
                          style: TextStyle(
                              color: e.key == 0 ? kText : kTextSub,
                              fontSize: e.key == 0 ? 13 : 11,
                              fontWeight: e.key == 0 ? FontWeight.w600 : FontWeight.normal),
                        )).toList(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: kRed, size: 16),
                      onPressed: () => _eliminar(r),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Sección: Membresías
// ══════════════════════════════════════════════════════════════════════════════

class _SeccionMembresias extends StatefulWidget {
  const _SeccionMembresias();
  @override
  State<_SeccionMembresias> createState() => _SeccionMembresiasState();
}

class _SeccionMembresiasState extends State<_SeccionMembresias> {
  final _nombreCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _diasCtrl   = TextEditingController();
  bool _guardando = false;

  // ignore: prefer_final_fields
  List<Map<String, dynamic>> _membresias = [
    {'id': 1, 'tipo': 'Diaria',     'precio': 5000.0,   'dias': 1},
    {'id': 2, 'tipo': 'Mensual',    'precio': 50000.0,  'dias': 30},
    {'id': 3, 'tipo': 'Bimestral',  'precio': 90000.0,  'dias': 60},
    {'id': 4, 'tipo': 'Trimestral', 'precio': 130000.0, 'dias': 90},
    {'id': 5, 'tipo': 'Semestral',  'precio': 245000.0, 'dias': 180},
    {'id': 6, 'tipo': 'Anual',      'precio': 450000.0, 'dias': 365},
  ];

  Future<void> _agregar() async {
    if (_nombreCtrl.text.trim().isEmpty || _precioCtrl.text.trim().isEmpty || _diasCtrl.text.trim().isEmpty) {
      _snack(context, 'Todos los campos son obligatorios', ok: false);
      return;
    }
    final precio = double.tryParse(_precioCtrl.text.trim());
    final dias   = int.tryParse(_diasCtrl.text.trim());
    if (precio == null || precio <= 0 || dias == null || dias <= 0) {
      _snack(context, 'Precio y días deben ser números positivos', ok: false);
      return;
    }
    setState(() => _guardando = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _membresias.insert(0, {'id': DateTime.now().millisecondsSinceEpoch, 'tipo': _nombreCtrl.text.trim(), 'precio': precio, 'dias': dias});
      _nombreCtrl.clear(); _precioCtrl.clear(); _diasCtrl.clear(); _guardando = false;
    });
    if (mounted) _snack(context, 'Membresía agregada', ok: true);
  }

  Future<void> _eliminar(Map<String, dynamic> m) async {
    final ok = await _confirmarDialog(context, '¿Eliminar membresía "${m['tipo']}"?',
        'No se puede eliminar si hay usuarios activos con esta membresía.');
    if (!ok) return;
    setState(() => _membresias.remove(m));
    if (mounted) _snack(context, 'Membresía eliminada', ok: true);
  }

  // ✅ CORREGIDO: (match) en lugar de (_)
  String _formatPrecio(double p) =>
      '\$${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TituloSeccion('Membresías', Icons.card_membership),
          const SizedBox(height: 16),
          _FormCard(
            titulo: 'Nueva membresía',
            child: Column(
              children: [
                _Field(ctrl: _nombreCtrl, label: 'Tipo (ej: Mensual)', icon: Icons.card_membership_outlined),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _Field(ctrl: _precioCtrl, label: 'Precio en COP', icon: Icons.attach_money, keyboard: TextInputType.number)),
                    const SizedBox(width: 10),
                    Expanded(child: _Field(ctrl: _diasCtrl, label: 'Duración (días)', icon: Icons.calendar_today_outlined, keyboard: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 14),
                _BtnPrimary(label: _guardando ? 'Guardando…' : 'Agregar membresía', onTap: _guardando ? null : _agregar),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 1.4, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: _membresias.length,
            itemBuilder: (ctx, i) {
              final m = _membresias[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.card_membership, color: kAccent, size: 20),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: kRed, size: 14),
                          onPressed: () => _eliminar(m),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(m['tipo'].toString(), style: TextStyle(color: kText, fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(_formatPrecio(m['precio'] as double), style: TextStyle(color: kAccent, fontWeight: FontWeight.w700, fontSize: 13)),
                    Text('${m['dias']} días', style: TextStyle(color: kTextSub, fontSize: 11)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Sección: Evaluaciones Físicas
// ══════════════════════════════════════════════════════════════════════════════

class _SeccionEvaluacionesAdmin extends StatefulWidget {
  const _SeccionEvaluacionesAdmin();
  @override
  State<_SeccionEvaluacionesAdmin> createState() => _SeccionEvaluacionesAdminState();
}

class _SeccionEvaluacionesAdminState extends State<_SeccionEvaluacionesAdmin> {
  final _correoCtrl    = TextEditingController();
  final _fechaCtrl     = TextEditingController();
  final _pesoCtrl      = TextEditingController();
  final _edadCtrl      = TextEditingController();
  final _condicionCtrl = TextEditingController();
  final _pruebasCtrl   = TextEditingController();
  bool _guardando = false;

  // ignore: prefer_final_fields
  List<Map<String, dynamic>> _evaluaciones = [
    {'id': 1, 'usuario': 'Alan Cruz',   'correo': 'AlanCru@gmail.com',    'fecha': '2026-06-01', 'peso': '70.5', 'edad': '22', 'condicion': 'Buena',   'pruebas': 'Press banca 40kg x 20'},
    {'id': 2, 'usuario': 'Maria Pilar', 'correo': 'Mariapilar@gmail.com', 'fecha': '2026-06-03', 'peso': '58.0', 'edad': '35', 'condicion': 'Regular',  'pruebas': 'Sentadilla 30kg x 15'},
  ];

  Future<void> _registrar() async {
    if ([_correoCtrl, _fechaCtrl, _pesoCtrl, _edadCtrl, _condicionCtrl, _pruebasCtrl]
        .any((c) => c.text.trim().isEmpty)) {
      _snack(context, 'Todos los campos son obligatorios', ok: false);
      return;
    }
    setState(() => _guardando = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _evaluaciones.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch,
        'usuario': _correoCtrl.text.trim(),
        'correo': _correoCtrl.text.trim(),
        'fecha': _fechaCtrl.text.trim(),
        'peso': _pesoCtrl.text.trim(),
        'edad': _edadCtrl.text.trim(),
        'condicion': _condicionCtrl.text.trim(),
        'pruebas': _pruebasCtrl.text.trim(),
      });
      for (var c in [_correoCtrl, _fechaCtrl, _pesoCtrl, _edadCtrl, _condicionCtrl, _pruebasCtrl]) {
        c.clear();
      }
      _guardando = false;
    });
    if (mounted) _snack(context, 'Evaluación registrada', ok: true);
  }

  Future<void> _eliminar(Map<String, dynamic> e) async {
    final ok = await _confirmarDialog(context, '¿Eliminar evaluación de "${e['usuario']}"?', '');
    if (!ok) return;
    setState(() => _evaluaciones.remove(e));
    if (mounted) _snack(context, 'Evaluación eliminada', ok: true);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TituloSeccion('Evaluaciones Físicas', Icons.monitor_weight),
          const SizedBox(height: 16),
          _FormCard(
            titulo: 'Nueva evaluación',
            child: Column(
              children: [
                _Field(ctrl: _correoCtrl, label: 'Correo del usuario', icon: Icons.email_outlined, keyboard: TextInputType.emailAddress),
                const SizedBox(height: 10),
                _Field(ctrl: _fechaCtrl, label: 'Fecha (yyyy-MM-dd)', icon: Icons.calendar_today_outlined),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _Field(ctrl: _pesoCtrl, label: 'Peso (kg)', icon: Icons.monitor_weight_outlined, keyboard: TextInputType.number)),
                    const SizedBox(width: 10),
                    Expanded(child: _Field(ctrl: _edadCtrl, label: 'Edad', icon: Icons.cake_outlined, keyboard: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 10),
                _Field(ctrl: _condicionCtrl, label: 'Condición física (ej: Buena)', icon: Icons.health_and_safety_outlined),
                const SizedBox(height: 10),
                _Field(ctrl: _pruebasCtrl, label: 'Pruebas realizadas', icon: Icons.assignment_outlined),
                const SizedBox(height: 14),
                _BtnPrimary(label: _guardando ? 'Guardando…' : 'Registrar evaluación', onTap: _guardando ? null : _registrar),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SubTitulo('Evaluaciones registradas (${_evaluaciones.length})'),
          const SizedBox(height: 10),
          ..._evaluaciones.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e['usuario'].toString(), style: TextStyle(color: kText, fontWeight: FontWeight.w700, fontSize: 13)),
                              Text('${e['correo']} · ${e['fecha']}', style: TextStyle(color: kTextSub, fontSize: 11)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: kRed, size: 16),
                          onPressed: () => _eliminar(e),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6, runSpacing: 4,
                      children: [
                        _Chip('Peso: ${e['peso']} kg'),
                        _Chip('Edad: ${e['edad']} años'),
                        _Chip('Condición: ${e['condicion']}'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Pruebas: ${e['pruebas']}', style: TextStyle(color: kTextSub, fontSize: 11)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Widgets reutilizables
// ══════════════════════════════════════════════════════════════════════════════

class _NavItem {
  final IconData iconOff;
  final IconData iconOn;
  final String label;
  const _NavItem(this.iconOff, this.iconOn, this.label);
}

class _TituloSeccion extends StatelessWidget {
  final String titulo;
  final IconData icono;
  const _TituloSeccion(this.titulo, this.icono);
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icono, color: kAccent, size: 22),
          const SizedBox(width: 10),
          Text(titulo, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kText)),
        ],
      );
}

class _SubTitulo extends StatelessWidget {
  final String text;
  const _SubTitulo(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(color: kText, fontSize: 16, fontWeight: FontWeight.w700));
}

class _FormCard extends StatelessWidget {
  final String titulo;
  final Widget child;
  const _FormCard({required this.titulo, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: kSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: TextStyle(color: kText, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            child,
          ],
        ),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final TextInputType keyboard;
  final bool obscure;
  final Widget? suffix;
  const _Field({
    required this.ctrl, required this.label, required this.icon,
    this.keyboard = TextInputType.text, this.obscure = false, this.suffix,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: ctrl,
        keyboardType: keyboard,
        obscureText: obscure,
        style: TextStyle(color: kText, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: kTextSub, fontSize: 12),
          prefixIcon: Icon(icon, color: kTextSub, size: 18),
          suffixIcon: suffix,
          filled: true,
          fillColor: kCard,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kAccent, width: 1.5)),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
      );
}

class _Dropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _Dropdown({required this.value, required this.items, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: kBorder)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            dropdownColor: kCard,
            style: TextStyle(color: kText, fontSize: 13),
            isExpanded: true,
            items: items.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: onChanged,
          ),
        ),
      );
}

class _DropdownMap extends StatelessWidget {
  final String value;
  final List<Map<String, String>> items;
  final ValueChanged<String?> onChanged;
  const _DropdownMap({required this.value, required this.items, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: kBorder)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            dropdownColor: kCard,
            style: TextStyle(color: kText, fontSize: 13),
            isExpanded: true,
            items: items.map((m) => DropdownMenuItem(value: m['id'], child: Text(m['desc']!))).toList(),
            onChanged: onChanged,
          ),
        ),
      );
}

// ✅ CORREGIDO: coma añadida después de withValues y withOpacity reemplazado
class _BtnPrimary extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _BtnPrimary({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: kAccent,
            disabledBackgroundColor: kAccent.withValues(alpha: 0.5),
            foregroundColor: kText,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          child: Text(label),
        ),
      );
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  const _Badge({required this.label, required this.bgColor, required this.textColor});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
        child: Text(label, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w600)),
      );
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip(this.text);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: TextStyle(color: kTextSub, fontSize: 10)),
      );
}

class _ItemTile extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final VoidCallback onDelete;
  const _ItemTile({required this.icon, required this.titulo, required this.subtitulo, required this.onDelete});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
        child: Row(
          children: [
            Icon(icon, color: kAccent, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: TextStyle(color: kText, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(subtitulo, style: TextStyle(color: kTextSub, fontSize: 11)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: kRed, size: 16),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ),
      );
}

class _Buscador extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final ValueChanged<String> onChanged;
  const _Buscador({required this.ctrl, required this.hint, required this.onChanged});
  @override
  Widget build(BuildContext context) => TextField(
        controller: ctrl,
        style: TextStyle(color: kText, fontSize: 14),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: kTextDim),
          prefixIcon: Icon(Icons.search, color: kTextDim, size: 20),
          filled: true,
          fillColor: kSurface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: kBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: kBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: kAccent, width: 1.5)),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  final String mensaje;
  const _EmptyState({required this.mensaje});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, color: kTextDim, size: 40),
              const SizedBox(height: 8),
              Text(mensaje, style: TextStyle(color: kTextDim, fontSize: 13), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

class _Cargando extends StatelessWidget {
  const _Cargando();
  @override
  Widget build(BuildContext context) => Center(
        child: CircularProgressIndicator(color: kAccent),
      );
}

class _ErrorWidget extends StatelessWidget {
  final String mensaje;
  const _ErrorWidget({required this.mensaje});
  @override
  Widget build(BuildContext context) => Center(
        child: Text(mensaje, style: TextStyle(color: kRed)),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
//  Utilidades globales
// ══════════════════════════════════════════════════════════════════════════════

void _snack(BuildContext context, String msg, {required bool ok}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: ok ? kGreen : kRed,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    duration: const Duration(seconds: 3),
  ));
}

Future<bool> _confirmarDialog(BuildContext context, String titulo, String subtitulo) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: kSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(titulo, style: TextStyle(color: kText, fontWeight: FontWeight.w700)),
      content: subtitulo.isNotEmpty
          ? Text(subtitulo, style: TextStyle(color: kTextSub, fontSize: 13))
          : null,
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancelar', style: TextStyle(color: kTextSub))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kRed),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
  return result ?? false;
}

