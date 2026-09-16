import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../models/client_models.dart';
import '../models/perfil_models.dart';
import '../theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/donut_chart.dart';
import '../widgets/profile_avatar.dart';
import 'login_screen.dart';
import 'perfil_editar_screen.dart';

enum _ClientSection {
  perfil,
  clases,
  productos,
  comprobantes,
  asistencia,
  rutinas,
  registros,
  metas,
  evaluaciones,
}

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key, required this.session});
  final AuthResult session;

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  _ClientSection _section = _ClientSection.perfil;
  final ApiService _api = ApiService();
  PerfilInfo? _perfilInfo;
  int _fotoVersion = 0;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    try {
      final perfil = await _api.fetchPerfilInfo(token: widget.session.token);
      if (!mounted) return;
      setState(() => _perfilInfo = perfil);
    } catch (_) {
      // Si falla, simplemente se muestra el ícono genérico de persona.
    }
  }

  void _onPerfilCambiado(PerfilInfo nuevo) {
    setState(() {
      _perfilInfo = nuevo;
      _fotoVersion++;
    });
  }

  void _abrirEditarPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PerfilEditarScreen(
          token: widget.session.token,
          perfilInicial: _perfilInfo,
          onCambiado: _onPerfilCambiado,
        ),
      ),
    );
  }

  static const List<Map<String, dynamic>> _items = [
    {'section': _ClientSection.perfil,       'icon': Icons.home_outlined,           'label': 'Inicio'},
    {'section': _ClientSection.clases,       'icon': Icons.calendar_month_outlined, 'label': 'Clases'},
    {'section': _ClientSection.productos,    'icon': Icons.shopping_bag_outlined,   'label': 'Productos'},
    {'section': _ClientSection.comprobantes, 'icon': Icons.receipt_long_outlined,   'label': 'Comprobante de pago'},
    {'section': _ClientSection.asistencia,   'icon': Icons.fact_check_outlined,     'label': 'Asistencia'},
    {'section': _ClientSection.rutinas,      'icon': Icons.fitness_center_rounded,  'label': 'Rutinas'},
    {'section': _ClientSection.registros,    'icon': Icons.checklist_rounded,       'label': 'Registro'},
    {'section': _ClientSection.metas,        'icon': Icons.flag_outlined,           'label': 'Metas'},
    {'section': _ClientSection.evaluaciones, 'icon': Icons.monitor_weight_outlined, 'label': 'Evaluaciones'},
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: FitManagerThemeController.mode,
      builder: (context, mode, _) => Scaffold(
        backgroundColor: kBg,
        appBar: AppBar(
          backgroundColor: kSidebar,
          title: Row(children: [
            BrandLogo(width: 32),
            SizedBox(width: 10),
            Text('TAURUS GYM',
                style: TextStyle(color: kText, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
          ]),
          actions: [
            IconButton(
              tooltip: 'Mi perfil',
              icon: Icon(Icons.manage_accounts_outlined, color: kTextSub),
              onPressed: _abrirEditarPerfil,
            ),
            IconButton(
              tooltip: mode == ThemeMode.light ? 'Modo oscuro' : 'Modo claro',
              icon: Icon(
                mode == ThemeMode.light
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                color: kTextSub,
              ),
              onPressed: FitManagerThemeController.toggle,
            ),
            IconButton(
              icon: Icon(Icons.logout_rounded, color: kTextSub),
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ),
        drawer: _ClientDrawer(
          user: widget.session.user,
          perfilInfo: _perfilInfo,
          fotoUrl: _api.urlFotoPerfil(widget.session.token, version: _fotoVersion),
          items: _items,
          selected: _section,
          onSelect: (s) { setState(() => _section = s); Navigator.pop(context); },
          onLogout: () => _confirmLogout(context),
          onEditarPerfil: () { Navigator.pop(context); _abrirEditarPerfil(); },
        ),
        body: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    final s = widget.session;
    switch (_section) {
      case _ClientSection.perfil:
        return _PerfilBody(
          session: s,
          perfilInfo: _perfilInfo,
          fotoUrl: _api.urlFotoPerfil(s.token, version: _fotoVersion),
          onEditarPerfil: _abrirEditarPerfil,
        );
      case _ClientSection.clases:       return _ClasesBody(session: s);
      case _ClientSection.productos:    return _ProductosBody(session: s);
      case _ClientSection.comprobantes: return _ComprobantesBody(session: s);
      case _ClientSection.asistencia:   return _AsistenciaBody(session: s);
      case _ClientSection.rutinas:      return _RutinasBody(session: s);
      case _ClientSection.registros:    return _RegistrosBody(session: s);
      case _ClientSection.metas:        return _MetasBody(session: s);
      case _ClientSection.evaluaciones: return _EvaluacionesBody(session: s);
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Cerrar sesión', style: TextStyle(color: kText)),
        content: Text('¿Seguro que quieres salir?', style: TextStyle(color: kTextSub)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                  context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: kRed),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}

// ── Drawer ─────────────────────────────────────────────────────────────────────
class _ClientDrawer extends StatelessWidget {
  const _ClientDrawer({
    required this.user,
    required this.perfilInfo,
    required this.fotoUrl,
    required this.items,
    required this.selected,
    required this.onSelect,
    required this.onLogout,
    required this.onEditarPerfil,
  });
  final dynamic user;
  final PerfilInfo? perfilInfo;
  final String fotoUrl;
  final List<Map<String, dynamic>> items;
  final _ClientSection selected;
  final ValueChanged<_ClientSection> onSelect;
  final VoidCallback onLogout;
  final VoidCallback onEditarPerfil;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: kSidebar,
      child: SafeArea(
        child: Column(children: [
          InkWell(
            onTap: onEditarPerfil,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: kBorder))),
              child: Row(children: [
                ProfileAvatar(perfil: perfilInfo, fotoUrl: fotoUrl, size: 44),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(user.nombreCompleto as String,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: kText, fontWeight: FontWeight.w800, fontSize: 15)),
                  Text(user.email as String,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: kTextSub, fontSize: 12)),
                ])),
                Icon(Icons.chevron_right_rounded, color: kTextDim),
              ]),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: items.map((item) {
                final section = item['section'] as _ClientSection;
                final icon = item['icon'] as IconData;
                final label = item['label'] as String;
                final isSel = section == selected;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: isSel ? kAccentBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: ListTile(
                      leading: Icon(icon, color: isSel ? kAccent : kTextSub, size: 22),
                      title: Text(label,
                          style: TextStyle(
                              color: isSel ? kText : kTextSub,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500)),
                      onTap: () => onSelect(section),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Divider(height: 1, color: kBorder),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              leading: Icon(Icons.logout_rounded, color: kRed, size: 22),
              title: Text('Salir',
                  style: TextStyle(color: kRed, fontWeight: FontWeight.w700, fontSize: 14)),
              onTap: onLogout,
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────
Widget _seccionTitulo(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(t, style: TextStyle(color: kText, fontSize: 20, fontWeight: FontWeight.w800)),
    );

Widget _card(Widget child, {EdgeInsets? padding}) => Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
      child: child,
    );

Widget _emptyState(String txt, IconData icon) => Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: kTextDim, size: 48),
        const SizedBox(height: 12),
        Text(txt, style: TextStyle(color: kTextSub, fontSize: 14), textAlign: TextAlign.center),
      ]),
    );

void _snack(BuildContext ctx, String msg, {bool ok = true}) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: ok ? kGreen : kRed,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ));
}

void _confirmarEliminar(BuildContext ctx, String que, VoidCallback onConfirm) {
  showDialog(
    context: ctx,
    builder: (d) => AlertDialog(
      backgroundColor: kCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Confirmar', style: TextStyle(color: kText)),
      content: Text('¿Eliminar $que?', style: TextStyle(color: kTextSub)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () { Navigator.pop(d); onConfirm(); },
          style: ElevatedButton.styleFrom(backgroundColor: kRed),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
}

void _mostrarMetaCumplida(BuildContext context, String nombreMeta) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: kCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(children: [
        Icon(Icons.emoji_events_rounded, color: kGold, size: 28),
        SizedBox(width: 10),
        Text('¡Felicidades!', style: TextStyle(color: kText, fontWeight: FontWeight.w800)),
      ]),
      content: Text('Cumpliste la meta "$nombreMeta"',
          style: TextStyle(color: kTextSub, fontSize: 15)),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx),
          style: ElevatedButton.styleFrom(backgroundColor: kAccent),
          child: const Text('¡Genial!'),
        ),
      ],
    ),
  );
}

class _Field extends StatelessWidget {
  const _Field({required this.ctrl, required this.label, this.keyboard, this.icon});
  final TextEditingController ctrl;
  final String label;
  final TextInputType? keyboard;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => TextField(
        controller: ctrl,
        keyboardType: keyboard,
        style: TextStyle(color: kText),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: kTextSub, size: 20) : null,
        ),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// PERFIL
// ══════════════════════════════════════════════════════════════════════════════
class _PerfilBody extends StatelessWidget {
  const _PerfilBody({
    required this.session,
    required this.perfilInfo,
    required this.fotoUrl,
    required this.onEditarPerfil,
  });
  final AuthResult session;
  final PerfilInfo? perfilInfo;
  final String fotoUrl;
  final VoidCallback onEditarPerfil;

  @override
  Widget build(BuildContext context) {
    final user = session.user;
    final vence = (user.vencimiento?.isNotEmpty ?? false) ? user.vencimiento! : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _card(InkWell(
          onTap: onEditarPerfil,
          child: Row(children: [
            ProfileAvatar(perfil: perfilInfo, fotoUrl: fotoUrl, size: 56),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hola, ${user.nombre}!',
                  style: TextStyle(color: kText, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(user.email, style: TextStyle(color: kTextSub, fontSize: 13)),
            ])),
            Icon(Icons.chevron_right_rounded, color: kTextDim),
          ]),
        )),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: kAccentBg, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kAccent.withValues(alpha: 0.35))),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                  color: kAccent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.card_membership_rounded, color: kAccent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Mi membresía', style: TextStyle(color: kTextSub, fontSize: 12)),
              const SizedBox(height: 2),
              Text(user.membresia ?? 'Sin membresía activa',
                  style: TextStyle(color: kText, fontSize: 16, fontWeight: FontWeight.w700)),
              if (vence != null) ...[
                const SizedBox(height: 2),
                Text('Vence: $vence', style: TextStyle(color: kGold, fontSize: 12)),
              ],
            ])),
          ]),
        ),
        const SizedBox(height: 24),
        Text('Mi perfil',
            style: TextStyle(color: kText, fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _InfoTile(icon: Icons.badge_outlined, label: 'Nombre completo', value: user.nombreCompleto),
        const SizedBox(height: 10),
        _InfoTile(
            icon: Icons.credit_card_outlined,
            label: 'Documento',
            value: '${user.tipoDocumento ?? "Doc."}: ${user.documento}'),
        const SizedBox(height: 10),
        _InfoTile(icon: Icons.email_outlined, label: 'Correo electrónico', value: user.email),
        const SizedBox(height: 10),
        _InfoTile(
            icon: Icons.wc_rounded,
            label: 'Sexo',
            value: perfilInfo?.generoMostrado ?? 'Sin registrar'),
        const SizedBox(height: 32),
        _card(Row(children: [
          Icon(Icons.location_on_outlined, color: kAccent, size: 20),
          SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Taurus GYM',
                style: TextStyle(color: kText, fontWeight: FontWeight.w700, fontSize: 14)),
            SizedBox(height: 2),
            Text('Cra. 45a #74-38 Sur', style: TextStyle(color: kTextSub, fontSize: 12)),
          ])),
        ])),
        const SizedBox(height: 24),
      ]),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => _card(Row(children: [
        Icon(icon, color: kTextSub, size: 20),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: kTextSub, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(color: kText, fontSize: 14, fontWeight: FontWeight.w600)),
        ])),
      ]));
}

// ══════════════════════════════════════════════════════════════════════════════
// CLASES
// ══════════════════════════════════════════════════════════════════════════════

class _ClasesBody extends StatefulWidget {
  const _ClasesBody({required this.session});
  final AuthResult session;
  @override
  State<_ClasesBody> createState() => _ClasesBodyState();
}

class _ClasesBodyState extends State<_ClasesBody> {
  List<ClaseModel> _clases = [];
  bool _loading = true;
  bool _soloMisClases = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService().fetchClases(token: widget.session.token);
      if (!mounted) return;
      setState(() {
        _clases = data;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _snack(context, 'Error al cargar clases: $e', ok: false);
      }
    }
  }

  Future<void> _toggleInscripcion(ClaseModel clase) async {
    if (clase.inscrito) {
      final confirmado = await _confirmarSalidaClase(clase);
      if (!confirmado) return;
    }

    try {
      if (clase.inscrito) {
        await ApiService().desinscribirClase(token: widget.session.token, id: clase.id);
        if (mounted) _snack(context, 'Saliste de ${clase.nombre}');
      } else {
        await ApiService().inscribirClase(token: widget.session.token, id: clase.id);
        if (mounted) _snack(context, 'Inscrito en ${clase.nombre}');
      }
      setState(() {
        _clases = _clases.map((c) =>
            c.id == clase.id ? c.copyWith(inscrito: !clase.inscrito) : c).toList();
      });
    } catch (e) {
      if (mounted) _snack(context, 'Error: $e', ok: false);
    }
  }

  Future<bool> _confirmarSalidaClase(ClaseModel clase) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Salir de la clase', style: TextStyle(color: kText)),
        content: Text('Seguro que quieres salir de ${clase.nombre}?', style: TextStyle(color: kTextSub)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Confirmar salida'),
            style: ElevatedButton.styleFrom(backgroundColor: kRed),
          ),
        ],
      ),
    );
    return result == true;
  }
  List<ClaseModel> get _clasesFiltradas =>
      _soloMisClases ? _clases.where((c) => c.inscrito).toList() : _clases;

  @override
  Widget build(BuildContext context) {
    if (_loading) return Center(child: CircularProgressIndicator(color: kAccent));

    final clases = _clasesFiltradas;

    return Column(children: [
      // Cabecera con toggle mis clases
      Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        color: kSidebar,
        child: Row(children: [
          Text('Clases',
              style: TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.w800)),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => setState(() => _soloMisClases = !_soloMisClases),
            icon: Icon(_soloMisClases ? Icons.star_rounded : Icons.star_border_rounded, size: 18),
            label: Text(_soloMisClases ? 'Ver todas' : 'Mis clases'),
            style: FilledButton.styleFrom(
              backgroundColor: _soloMisClases ? kAccent : kButton,
              foregroundColor: _soloMisClases ? Colors.white : kButtonText,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ]),
      ),

      // Lista de clases
      Expanded(
        child: clases.isEmpty
            ? _emptyState(
                _soloMisClases
                    ? 'No estás inscrito en ninguna clase.'
                    : 'No hay clases registradas.',
                Icons.calendar_month_outlined,
              )
            : RefreshIndicator(
                onRefresh: _load,
                color: kAccent,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: clases.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _ClaseCard(
                    clase: clases[i],
                    onToggle: () => _toggleInscripcion(clases[i]),
                  ),
                ),
              ),
      ),
    ]);
  }
}

class _ClaseCard extends StatelessWidget {
  const _ClaseCard({required this.clase, required this.onToggle});
  final ClaseModel clase;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: clase.inscrito ? kAccent.withValues(alpha: 0.5) : kBorder,
          width: clase.inscrito ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Fila superior: nombre + badge inscrito
          Row(children: [
            Expanded(
              child: Text(
                clase.nombre,
                style: TextStyle(
                    color: kText, fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            if (clase.inscrito)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kAccentBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kAccent.withValues(alpha: 0.4)),
                ),
                child: Text('Inscrito',
                    style: TextStyle(
                        color: kAccent, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
          ]),
          const SizedBox(height: 12),

          // Horario
          Row(children: [
            Icon(Icons.access_time_rounded, color: kAccent, size: 16),
            const SizedBox(width: 6),
            Text(clase.hora,
                style: TextStyle(color: kText, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(width: 16),
            Icon(Icons.calendar_today_outlined, color: kTextSub, size: 14),
            const SizedBox(width: 6),
            Text(clase.dia, style: TextStyle(color: kTextSub, fontSize: 13)),
          ]),
          const SizedBox(height: 10),

          // Instructor
          Row(children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: kAccentBg,
                shape: BoxShape.circle,
                border: Border.all(color: kAccent.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.person_rounded, color: kAccent, size: 18),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Instructor',
                  style: TextStyle(color: kTextSub, fontSize: 11)),
              Text(clase.instructor,
                  style: TextStyle(
                      color: kText, fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
          ]),

          const SizedBox(height: 14),
          Divider(color: kBorder, height: 1),
          const SizedBox(height: 12),

          // Botón inscribir / salir
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onToggle,
              style: ElevatedButton.styleFrom(
                backgroundColor: clase.inscrito ? kSurface : kAccent,
                foregroundColor: clase.inscrito ? kRed : Colors.black,
                side: clase.inscrito ? BorderSide(color: kRed, width: 1) : BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                clase.inscrito ? 'Salir de la clase' : 'Inscribirme',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PRODUCTOS
// ══════════════════════════════════════════════════════════════════════════════
class _ProductosBody extends StatefulWidget {
  const _ProductosBody({required this.session});
  final AuthResult session;
  @override
  State<_ProductosBody> createState() => _ProductosBodyState();
}

class _ProductosBodyState extends State<_ProductosBody> {
  late Future<List<ProductoModel>> _future;
  final Set<int> _comprando = {};

  @override
  void initState() { super.initState(); _future = ApiService().fetchProductos(token: widget.session.token); }

  Future<void> _comprar(ProductoModel p) async {
    setState(() => _comprando.add(p.id));
    try {
      final datos = await ApiService().iniciarCompraProducto(
        token: widget.session.token,
        idProducto: p.id,
      );
      final uri = datos.buildCheckoutUri();
      final abierto = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!abierto && mounted) {
        _snack(context, 'No se pudo abrir el navegador para pagar.', ok: false);
      }
    } on ApiException catch (e) {
      if (mounted) _snack(context, e.message, ok: false);
    } catch (_) {
      if (mounted) _snack(context, 'No se pudo iniciar el pago.', ok: false);
    } finally {
      if (mounted) setState(() => _comprando.remove(p.id));
    }
  }

  void _confirmarCompra(ProductoModel p) {
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirmar compra', style: TextStyle(color: kText)),
        content: Text(
          '¿Comprar "${p.nombre}" por \$${p.precio.toStringAsFixed(2)}?\n\n'
          'Se abrirá el navegador para pagar de forma segura con Wompi.',
          style: TextStyle(color: kTextSub),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () { Navigator.pop(d); _comprar(p); },
            child: const Text('Pagar con Wompi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductoModel>>(
      future: _future,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: kAccent));
        }
        if (snap.hasError) return _emptyState('Error: ${snap.error}', Icons.error_outline);
        final items = snap.data ?? [];
        if (items.isEmpty) return _emptyState('No hay productos disponibles.', Icons.shopping_bag_outlined);
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final p = items[i];
            final comprando = _comprando.contains(p.id);
            return _card(Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: kAccentBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.shopping_bag_outlined, color: kAccent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(p.nombre,
                  style: TextStyle(color: kText, fontSize: 14, fontWeight: FontWeight.w600))),
              Text('\$${p.precio.toStringAsFixed(2)}',
                  style: TextStyle(color: kGold, fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(width: 12),
              SizedBox(
                height: 34,
                child: ElevatedButton(
                  onPressed: comprando ? null : () => _confirmarCompra(p),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    minimumSize: Size.zero,
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  child: comprando
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Comprar'),
                ),
              ),
            ]));
          },
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// COMPROBANTES DE PAGO
// ══════════════════════════════════════════════════════════════════════════════
class _ComprobantesBody extends StatefulWidget {
  const _ComprobantesBody({required this.session});
  final AuthResult session;
  @override
  State<_ComprobantesBody> createState() => _ComprobantesBodyState();
}

class _ComprobantesBodyState extends State<_ComprobantesBody> {
  late Future<List<ComprobanteModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService().fetchComprobantes(token: widget.session.token, userId: widget.session.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ComprobanteModel>>(
      future: _future,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: kAccent));
        }
        if (snap.hasError) return _emptyState('Error: ${snap.error}', Icons.error_outline);
        final items = snap.data ?? [];
        if (items.isEmpty) return _emptyState('No tienes comprobantes de pago registrados.', Icons.receipt_long_outlined);
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final f = items[i];
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => _ComprobanteDetallePage(session: widget.session, idComprobante: f.id))),
              child: _card(Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: kAccentBg, borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.receipt_long_outlined, color: kAccent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Comprobante #${f.numero}',
                      style: TextStyle(color: kText, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    f.concepto.isNotEmpty ? f.concepto : 'Membresía FitManager',
                    style: TextStyle(color: kAccent, fontSize: 12, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(f.fecha, style: TextStyle(color: kTextSub, fontSize: 12)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('\$${f.total}',
                      style: TextStyle(color: kGold, fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('Ver detalle →', style: TextStyle(color: kAccent, fontSize: 11)),
                ]),
              ])),
            );
          },
        );
      },
    );
  }
}

// ── Detalle del comprobante de pago ─────────────────────────────────────────────
class _ComprobanteDetallePage extends StatefulWidget {
  const _ComprobanteDetallePage({required this.session, required this.idComprobante});
  final AuthResult session;
  final int idComprobante;
  @override
  State<_ComprobanteDetallePage> createState() => _ComprobanteDetallePageState();
}

class _ComprobanteDetallePageState extends State<_ComprobanteDetallePage> {
  late Future<ComprobanteDetalleModel> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService().fetchComprobanteDetalle(
        token: widget.session.token, idComprobante: widget.idComprobante);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kSidebar,
        title: Text('Detalle del comprobante',
            style: TextStyle(color: kText, fontWeight: FontWeight.w700)),
        iconTheme: IconThemeData(color: kTextSub),
      ),
      body: FutureBuilder<ComprobanteDetalleModel>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: kAccent));
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}',
                style: TextStyle(color: kRed)));
          }
          final f = snap.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // Encabezado
              _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('FITMANAGER',
                    style: TextStyle(color: kText, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2)),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: 4,
                  children: [
                    Text('N. ${f.numero}',
                        style: TextStyle(color: kAccent, fontSize: 13, fontWeight: FontWeight.w700)),
                    Text(f.fecha, style: TextStyle(color: kTextSub, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: kBorder),
                const SizedBox(height: 8),
                Text('Comprobante de pago', style: TextStyle(color: kTextSub, fontSize: 13)),
              ]), padding: const EdgeInsets.all(20)),

              const SizedBox(height: 12),

              // Comprado (lo más relevante primero: qué se compró)
              _card(Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: kAccentBg, borderRadius: BorderRadius.circular(10)),
                  child: Icon(
                    f.tipoCompra == 'Producto' ? Icons.shopping_bag_outlined : Icons.card_membership_rounded,
                    color: kAccent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(f.tipoCompra.isNotEmpty ? f.tipoCompra : 'Comprado',
                      style: TextStyle(color: kTextSub, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(f.concepto.isNotEmpty ? f.concepto : 'Membresía FitManager',
                      style: TextStyle(color: kText, fontSize: 15, fontWeight: FontWeight.w800)),
                  if (f.tipoCompra == 'Membresía' && f.duracionDias > 0) ...[
                    const SizedBox(height: 2),
                    Text('Duración: ${f.duracionDias} días',
                        style: TextStyle(color: kGold, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ])),
                Text('\$${f.total}',
                    style: TextStyle(color: kGold, fontSize: 16, fontWeight: FontWeight.w800)),
              ])),

              const SizedBox(height: 12),

              // Cliente y método de pago
              Row(children: [
                Expanded(child: _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Cliente',
                      style: TextStyle(color: kTextSub, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(f.cliente,
                      style: TextStyle(color: kText, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(f.correo, style: TextStyle(color: kTextSub, fontSize: 12)),
                  if (f.telefono.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(f.telefono, style: TextStyle(color: kTextSub, fontSize: 12)),
                  ],
                ]))),
                const SizedBox(width: 10),
                Expanded(child: _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Pago',
                      style: TextStyle(color: kTextSub, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(f.metodo.isNotEmpty ? f.metodo : 'N/A',
                      style: TextStyle(color: kText, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('Estado: Confirmado', style: TextStyle(color: kGreen, fontSize: 12)),
                ]))),
              ]),

              if (f.idTransaccion.isNotEmpty || f.referenciaPago.isNotEmpty) ...[
                const SizedBox(height: 12),
                _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Datos de la transacción Wompi',
                      style: TextStyle(color: kTextSub, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  if (f.idTransaccion.isNotEmpty)
                    Text('ID transacción: ${f.idTransaccion}',
                        style: TextStyle(color: kText, fontSize: 12)),
                  if (f.referenciaPago.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text('Referencia: ${f.referenciaPago}',
                        style: TextStyle(color: kTextSub, fontSize: 12)),
                  ],
                ])),
              ],

              const SizedBox(height: 12),

              // Tabla detalle
              _card(Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    Expanded(flex: 3, child: Text('Concepto', style: TextStyle(color: kTextSub, fontSize: 12, fontWeight: FontWeight.w600))),
                    Expanded(child: Text('Cant.', style: TextStyle(color: kTextSub, fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                    Expanded(flex: 2, child: Text('V. Unit.', style: TextStyle(color: kTextSub, fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                    Expanded(flex: 2, child: Text('Total', style: TextStyle(color: kTextSub, fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                  ]),
                ),
                const SizedBox(height: 8),
                Divider(color: kBorder, height: 1),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(flex: 3, child: Text(f.concepto, style: TextStyle(color: kText, fontSize: 13))),
                  Expanded(child: Text(f.cantidad, style: TextStyle(color: kText, fontSize: 13), textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text('\$${f.precioUnit}', style: TextStyle(color: kText, fontSize: 13), textAlign: TextAlign.right)),
                  Expanded(flex: 2, child: Text('\$${f.total}',
                      style: TextStyle(color: kGold, fontSize: 13, fontWeight: FontWeight.w700), textAlign: TextAlign.right)),
                ]),
                const SizedBox(height: 16),
                Divider(color: kBorder, height: 1),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('TOTAL: ',
                      style: TextStyle(color: kTextSub, fontSize: 15, fontWeight: FontWeight.w600)),
                  Text('\$${f.total}',
                      style: TextStyle(color: kAccent, fontSize: 22, fontWeight: FontWeight.w900)),
                ]),
              ]), padding: const EdgeInsets.all(16)),

              const SizedBox(height: 24),
            ]),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ASISTENCIA
// ══════════════════════════════════════════════════════════════════════════════
class _AsistenciaBody extends StatefulWidget {
  const _AsistenciaBody({required this.session});
  final AuthResult session;
  @override
  State<_AsistenciaBody> createState() => _AsistenciaBodyState();
}

class _AsistenciaBodyState extends State<_AsistenciaBody> {
  static const int _metaSemanal = 4;

  int _totalSemana = 0;
  int _racha = 0;
  bool _loading = true;
  bool _registrando = false;

  @override
  void initState() { super.initState(); _cargarTotal(); }

  Future<void> _cargarTotal() async {
    setState(() => _loading = true);
    try {
      final resumen = await ApiService().fetchAsistenciaMes(token: widget.session.token);
      if (mounted) setState(() { _totalSemana = resumen.totalMes; _racha = resumen.racha; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _asistir() async {
    setState(() => _registrando = true);
    try {
      final resumen = await ApiService().registrarAsistencia(token: widget.session.token);
      if (mounted) {
        setState(() { _totalSemana = resumen.totalMes; _racha = resumen.racha; _registrando = false; });
        _snack(context, 'Asistencia registrada');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _registrando = false);
        _snack(context, '$e', ok: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final porcentaje = (_totalSemana / _metaSemanal * 100).clamp(0, 100).toDouble();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _seccionTitulo('Asistencia'),
        _card(
          Column(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Racha actual',
                style: TextStyle(color: kText, fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 12),
            _RachaBadge(racha: _racha),
            const SizedBox(height: 18),
            if (_loading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: CircularProgressIndicator(color: kAccent),
              )
            else
              Column(children: [
                DonutChart(
                  percent: porcentaje,
                  progressColor: kGreen,
                  remainingColor: kBorder,
                  size: 170,
                  centerText: '$_totalSemana/$_metaSemanal',
                  centerSubText: 'dias',
                ),
              ]),
            const SizedBox(height: 14),
            Text('Constancia semanal: $_totalSemana/$_metaSemanal dias esta semana',
                style: TextStyle(color: kTextSub, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _registrando ? null : _asistir,
                icon: _registrando
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.fitness_center_rounded),
                label: Text(_registrando ? 'Registrando...' : 'Asisti hoy'),
                style: ElevatedButton.styleFrom(backgroundColor: kAccent),
              ),
            ),
          ]),
          padding: const EdgeInsets.all(20),
        ),
      ],
    );
  }
}

class _RachaBadge extends StatelessWidget {
  const _RachaBadge({required this.racha});
  final int racha;

  @override
  Widget build(BuildContext context) {
    final activa = racha >= 3;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: activa ? kAccentBg : kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: activa ? kAccent : kBorder, width: activa ? 1.4 : 1),
        boxShadow: activa
            ? [BoxShadow(color: kAccent.withValues(alpha: 0.24), blurRadius: 16, spreadRadius: 1)]
            : const [],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.local_fire_department_rounded, color: activa ? kAccent : kTextDim, size: 22),
        const SizedBox(width: 8),
        Text('$racha', style: TextStyle(color: activa ? kAccent : kText, fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(width: 6),
        Text('dias seguidos', style: TextStyle(color: activa ? kText : kTextSub, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _RutinasBody extends StatefulWidget {
  const _RutinasBody({required this.session});
  final AuthResult session;
  @override
  State<_RutinasBody> createState() => _RutinasBodyState();
}

class _RutinasBodyState extends State<_RutinasBody> {
  List<RutinaModel> _items = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService().fetchRutinas(
          token: widget.session.token, userId: widget.session.user.id);
      if (mounted) setState(() { _items = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _abrirDrive(String enlace) async {
    if (enlace.isEmpty) return;
    final uri = Uri.tryParse(enlace);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) _snack(context, 'No se pudo abrir el enlace', ok: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      color: kAccent,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _seccionTitulo('Rutinas'),
          Text(
            'Tu entrenador te asigna un programa después de cada evaluación física. '
            'Aquí puedes ver el material y abrirlo en Drive.',
            style: TextStyle(color: kTextSub, fontSize: 12.5, height: 1.4),
          ),
          const SizedBox(height: 16),
          if (_loading)
            Center(child: CircularProgressIndicator(color: kAccent))
          else if (_items.isEmpty)
            _emptyState(
              'Todavía no tienes una rutina asignada.\nSe activa después de tu próxima evaluación física.',
              Icons.fitness_center_rounded,
            )
          else
            ..._items.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _card(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(color: kAccentBg, borderRadius: BorderRadius.circular(10)),
                          child: Icon(Icons.fitness_center_rounded, color: kAccent, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(r.nombre,
                              style: TextStyle(color: kText, fontSize: 14, fontWeight: FontWeight.w700)),
                          if (r.programa.isNotEmpty || r.objetivo.isNotEmpty)
                            Text(
                              [if (r.programa.isNotEmpty) r.programa, if (r.objetivo.isNotEmpty) 'Objetivo: ${r.objetivo}']
                                  .join(' · '),
                              style: TextStyle(color: kTextSub, fontSize: 12),
                            ),
                        ])),
                      ]),
                      if (r.descripcion.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(r.descripcion, style: TextStyle(color: kTextSub, fontSize: 12.5, height: 1.4)),
                      ],
                      if (r.enlaceDrive.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _abrirDrive(r.enlaceDrive),
                            icon: const Icon(Icons.open_in_new_rounded, size: 18),
                            label: const Text('Ver programa en Drive'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kAccent,
                              side: BorderSide(color: kAccent),
                            ),
                          ),
                        ),
                      ],
                    ],
                  )),
                )),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// REGISTROS
// ══════════════════════════════════════════════════════════════════════════════
class _RegistrosBody extends StatefulWidget {
  const _RegistrosBody({required this.session});
  final AuthResult session;
  @override
  State<_RegistrosBody> createState() => _RegistrosBodyState();
}

class _RegistrosBodyState extends State<_RegistrosBody> {
  List<RegistroModel> _items = [];
  bool _loading = true;
  final _ejCtrl = TextEditingController();
  final _repsCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _ejCtrl.dispose(); _repsCtrl.dispose(); _pesoCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService().fetchRegistros(
          token: widget.session.token, userId: widget.session.user.id);
      if (mounted) setState(() { _items = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _crear() async {
    final ej = _ejCtrl.text.trim();
    final reps = int.tryParse(_repsCtrl.text.trim()) ?? 0;
    final peso = double.tryParse(_pesoCtrl.text.trim()) ?? 0;
    if (ej.isEmpty || reps <= 0 || peso <= 0) {
      _snack(context, 'Completa todos los campos correctamente', ok: false);
      return;
    }
    try {
      await ApiService().crearRegistro(
          token: widget.session.token, ejercicio: ej, repeticiones: reps, peso: peso);
      _ejCtrl.clear(); _repsCtrl.clear(); _pesoCtrl.clear();
      if (mounted) _snack(context, 'Registro guardado');
      _load();
      _revisarMetaRecienCumplida(ej);
    } catch (e) {
      if (mounted) _snack(context, 'Error: $e', ok: false);
    }
  }

  /// Revisa si el ejercicio que se acaba de registrar hizo que alguna meta
  /// se cumpliera justo ahora, y si es asi muestra la ventana de felicitación.
  Future<void> _revisarMetaRecienCumplida(String ejercicio) async {
    try {
      final metas = await ApiService().fetchMetas(
          token: widget.session.token, userId: widget.session.user.id);
      final coincidencias = metas.where((m) =>
          m.cumplida && m.ejercicio.toLowerCase() == ejercicio.toLowerCase());
      for (final m in coincidencias) {
        if (_metasYaCelebradas.add(m.id) && mounted) {
          _mostrarMetaCumplida(context, m.ejercicio);
        }
      }
    } catch (_) {
      // Si falla la verificación, simplemente no se muestra la felicitación.
    }
  }

  final Set<int> _metasYaCelebradas = {};

  Future<void> _eliminar(int id) async {
    try {
      await ApiService().eliminarRegistro(token: widget.session.token, id: id);
      if (mounted) _snack(context, 'Registro eliminado');
      _load();
    } catch (e) {
      if (mounted) _snack(context, 'Error: $e', ok: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _seccionTitulo('Registro de entrenamiento'),
        _card(Column(children: [
          _Field(ctrl: _ejCtrl, label: 'Ejercicio', icon: Icons.sports_gymnastics),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _Field(
                ctrl: _repsCtrl, label: 'Repeticiones',
                keyboard: TextInputType.number, icon: Icons.repeat)),
            const SizedBox(width: 10),
            Expanded(child: _Field(
                ctrl: _pesoCtrl, label: 'Peso (kg)',
                keyboard: const TextInputType.numberWithOptions(decimal: true),
                icon: Icons.monitor_weight_outlined)),
          ]),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _crear,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Guardar registro'),
              style: ElevatedButton.styleFrom(backgroundColor: kAccent),
            ),
          ),
        ])),
        const SizedBox(height: 20),
        if (_items.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Expanded(flex: 3, child: Text('Ejercicio',
                  style: TextStyle(color: kTextSub, fontSize: 11, fontWeight: FontWeight.w600))),
              Expanded(child: Text('Reps',
                  style: TextStyle(color: kTextSub, fontSize: 11, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center)),
              Expanded(child: Text('Kg',
                  style: TextStyle(color: kTextSub, fontSize: 11, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text('Fecha',
                  style: TextStyle(color: kTextSub, fontSize: 11, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.right)),
              SizedBox(width: 36),
            ]),
          ),
        const SizedBox(height: 8),
        if (_loading)
          Center(child: CircularProgressIndicator(color: kAccent))
        else if (_items.isEmpty)
          _emptyState('No tienes registros de entrenamiento.', Icons.checklist_rounded)
        else
          ..._items.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _card(Row(children: [
                  Expanded(flex: 3, child: Text(r.ejercicio,
                      style: TextStyle(color: kText, fontSize: 13, fontWeight: FontWeight.w600))),
                  Expanded(child: Text('${r.repeticiones}',
                      style: TextStyle(color: kText, fontSize: 13),
                      textAlign: TextAlign.center)),
                  Expanded(child: Text('${r.peso}',
                      style: TextStyle(color: kText, fontSize: 13),
                      textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text(r.fecha,
                      style: TextStyle(color: kTextSub, fontSize: 11),
                      textAlign: TextAlign.right)),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: kRed, size: 18),
                    onPressed: () => _confirmarEliminar(context, 'este registro', () => _eliminar(r.id)),
                  ),
                ]),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
              )),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// METAS
// ══════════════════════════════════════════════════════════════════════════════
class _MetasBody extends StatefulWidget {
  const _MetasBody({required this.session});
  final AuthResult session;
  @override
  State<_MetasBody> createState() => _MetasBodyState();
}

class _MetasBodyState extends State<_MetasBody> {
  List<MetaModel> _items = [];
  bool _loading = true;
  bool _primeraCarga = true;
  final _ejCtrl = TextEditingController();
  final _metaCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _ejCtrl.dispose(); _metaCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService().fetchMetas(
          token: widget.session.token, userId: widget.session.user.id);
      if (mounted) {
        _detectarMetasCumplidas(anteriores: _items, nuevas: data);
        setState(() { _items = data; _loading = false; _primeraCarga = false; });
      }
    } catch (_) {
      if (mounted) setState(() { _loading = false; _primeraCarga = false; });
    }
  }

  /// Compara el estado anterior de las metas contra el nuevo y muestra la
  /// ventana de "¡Felicidades!" para cualquier meta que acabe de cumplirse.
  /// En la primera carga de la pantalla no se compara nada, para no celebrar
  /// metas que ya estaban cumplidas desde antes.
  void _detectarMetasCumplidas({required List<MetaModel> anteriores, required List<MetaModel> nuevas}) {
    if (_primeraCarga) return;
    for (final nueva in nuevas) {
      if (!nueva.cumplida) continue;
      final antes = anteriores.where((m) => m.id == nueva.id);
      final yaEstabaCumplida = antes.isNotEmpty && antes.first.cumplida;
      if (!yaEstabaCumplida) {
        _mostrarMetaCumplida(context, nueva.ejercicio);
      }
    }
  }

  Future<void> _crear() async {
    final ej = _ejCtrl.text.trim();
    final met = int.tryParse(_metaCtrl.text.trim()) ?? 0;
    if (ej.isEmpty || met <= 0) { _snack(context, 'Completa todos los campos', ok: false); return; }
    try {
      await ApiService().crearMeta(token: widget.session.token, ejercicio: ej, meta: met);
      _ejCtrl.clear(); _metaCtrl.clear();
      if (mounted) _snack(context, 'Meta creada');
      _load();
    } catch (e) {
      if (mounted) _snack(context, 'Error: $e', ok: false);
    }
  }

  Future<void> _eliminar(int id) async {
    try {
      await ApiService().eliminarMeta(token: widget.session.token, id: id);
      if (mounted) _snack(context, 'Meta eliminada');
      _load();
    } catch (e) {
      if (mounted) _snack(context, 'Error: $e', ok: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _items.length;
    final cumplidas = _items.where((m) => m.cumplida).length;
    final porcentaje = total == 0 ? 0.0 : (cumplidas / total * 100);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _seccionTitulo('Metas'),
        if (!_loading && total > 0) ...[
          _card(
            Column(children: [
              DonutChart(
                percent: porcentaje,
                progressColor: kGreen,
                remainingColor: kBorder,
                size: 150,
                centerText: '$cumplidas/$total',
                centerSubText: 'metas',
              ),
              const SizedBox(height: 12),
              Text('Metas completadas: $cumplidas/$total (${porcentaje.round()}%)',
                  style: TextStyle(color: kTextSub, fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
            padding: const EdgeInsets.all(20),
          ),
          const SizedBox(height: 16),
        ],
        _card(Column(children: [
          _Field(ctrl: _ejCtrl, label: 'Ejercicio', icon: Icons.sports_score),
          const SizedBox(height: 10),
          _Field(ctrl: _metaCtrl, label: 'Meta (reps / kg)',
              keyboard: TextInputType.number, icon: Icons.flag_outlined),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _crear,
              icon: const Icon(Icons.add),
              label: const Text('Guardar meta'),
              style: ElevatedButton.styleFrom(backgroundColor: kAccent),
            ),
          ),
        ])),
        const SizedBox(height: 20),
        if (_loading)
          Center(child: CircularProgressIndicator(color: kAccent))
        else if (_items.isEmpty)
          _emptyState('No tienes metas registradas.', Icons.flag_outlined)
        else
          ..._items.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _card(Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: kAccentBg, borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                        m.cumplida ? Icons.check_circle_rounded : Icons.flag_outlined,
                        color: m.cumplida ? kGreen : kAccent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(m.ejercicio,
                        style: TextStyle(color: kText, fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('Progreso: ${m.progreso}/${m.meta}',
                        style: TextStyle(color: m.cumplida ? kGreen : kTextSub, fontSize: 12)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: kAccentBg, borderRadius: BorderRadius.circular(20)),
                    child: Text('Meta: ${m.meta}',
                        style: TextStyle(color: kAccent, fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: kRed, size: 20),
                    onPressed: () => _confirmarEliminar(context, 'esta meta', () => _eliminar(m.id)),
                  ),
                ])),
              )),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// EVALUACIONES
// ══════════════════════════════════════════════════════════════════════════════
class _EvaluacionesBody extends StatefulWidget {
  const _EvaluacionesBody({required this.session});
  final AuthResult session;
  @override
  State<_EvaluacionesBody> createState() => _EvaluacionesBodyState();
}

class _EvaluacionesBodyState extends State<_EvaluacionesBody> {
  List<EvaluacionModel> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService().fetchEvaluaciones(
          token: widget.session.token, userId: widget.session.user.id);
      if (mounted) setState(() { _items = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _seccionTitulo('Evaluaciones físicas'),
        if (_items.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Expanded(flex: 2, child: Text('Fecha',
                  style: TextStyle(color: kTextSub, fontSize: 11, fontWeight: FontWeight.w600))),
              Expanded(child: Text('Peso',
                  style: TextStyle(color: kTextSub, fontSize: 11, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center)),
              Expanded(child: Text('Edad',
                  style: TextStyle(color: kTextSub, fontSize: 11, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text('Condición',
                  style: TextStyle(color: kTextSub, fontSize: 11, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text('Pruebas',
                  style: TextStyle(color: kTextSub, fontSize: 11, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.right)),
            ]),
          ),
        const SizedBox(height: 8),
        if (_loading)
          Center(child: CircularProgressIndicator(color: kAccent))
        else if (_error != null)
          _emptyState('No se pudieron cargar tus evaluaciones:\n$_error', Icons.error_outline_rounded)
        else if (_items.isEmpty)
          _emptyState(
              'No tienes evaluaciones físicas.\nContacta a tu entrenador.',
              Icons.monitor_weight_outlined)
        else
          ..._items.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _card(Row(children: [
                  Expanded(flex: 2, child: Text(e.fecha,
                      style: TextStyle(color: kText, fontSize: 12))),
                  Expanded(child: Text('${e.peso} kg',
                      style: TextStyle(color: kText, fontSize: 12),
                      textAlign: TextAlign.center)),
                  Expanded(child: Text('${e.edad}',
                      style: TextStyle(color: kText, fontSize: 12),
                      textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text(e.condicion,
                      style: TextStyle(color: kAccent, fontSize: 12),
                      textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text(e.pruebas,
                      style: TextStyle(color: kTextSub, fontSize: 12),
                      textAlign: TextAlign.right)),
                ]),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
              )),
      ],
    );
  }
}



