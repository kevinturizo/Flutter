import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/api_service.dart';
import '../theme.dart';
import 'login_screen.dart';
import '../widgets/brand_logo.dart';


class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key, required this.session});
  final AuthResult session;

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _api         = ApiService();
  final _searchCtrl  = TextEditingController();
  List<AppUser> _users   = [];
  bool  _loading         = true;
  String _filter         = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final users = await _api.listUsers(widget.session.token);
      if (!mounted) return;
      setState(() => _users = users);
    } on ApiException catch (e) {
      _snack(e.message, ok: false);
    } catch (_) {
      _snack('No se pudo cargar la lista de usuarios.', ok: false);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteUser(AppUser user) async {
    if (user.esAdmin) {
      _snack('No se puede eliminar un administrador desde la app móvil.', ok: false);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        title: Text(
          'Eliminar ${user.nombreCompleto}',
          style: TextStyle(color: kText),
        ),
        content: Text(
          'Esta acción eliminará el usuario de la base de datos.\n¿Deseas continuar?',
          style: TextStyle(color: kTextSub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: kRed),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _api.deleteUser(token: widget.session.token, id: user.id);
      await _loadUsers();
      if (mounted) _snack('Usuario eliminado correctamente.', ok: true);
    } on ApiException catch (e) {
      if (mounted) _snack(e.message, ok: false);
    } catch (_) {
      if (mounted) _snack('No se pudo eliminar el usuario.', ok: false);
    }
  }

  void _snack(String text, {required bool ok}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: ok ? kGreen : kRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  List<AppUser> get _filtered {
    if (_filter.isEmpty) return _users;
    final q = _filter.toLowerCase();
    return _users.where((u) {
      return '${u.nombreCompleto} ${u.email} ${u.documento} ${u.rol}'
          .toLowerCase()
          .contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final adminName = widget.session.user.nombreCompleto;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: kAccentBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kAccent.withAlpha(80)),
              ),
              padding: const EdgeInsets.all(5),
              child: const BrandLogo(width: 24),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TAURUS GYM',
                  style: TextStyle(
                    color: kText,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Panel Admin',
                  style: TextStyle(
                    color: kAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Avatar + nombre del admin
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: kAccentBg,
                    child: Text(
                      adminName.isNotEmpty
                          ? adminName[0].toUpperCase()
                          : 'A',
                      style: TextStyle(
                        color: kAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    adminName.split(' ').first,
                    style: TextStyle(color: kText, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.logout_rounded, color: kTextSub),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),

      // ── Cuerpo ─────────────────────────────────────────────────────────────
      body: Column(
        children: [
          // ── Cabecera con stats y buscador ─────────────────────────────────
          Container(
            color: kSidebar,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats rápidos
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.people_alt_rounded,
                      label: 'Total usuarios',
                      value: _users.length.toString(),
                    ),
                    const SizedBox(width: 10),
                    _StatChip(
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'Admins',
                      value: _users.where((u) => u.esAdmin).length.toString(),
                    ),
                    const SizedBox(width: 10),
                    _StatChip(
                      icon: Icons.person_rounded,
                      label: 'Clientes',
                      value: _users.where((u) => !u.esAdmin).length.toString(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Buscador
                TextField(
                  controller: _searchCtrl,
                  style: TextStyle(color: kText),
                  onChanged: (v) => setState(() => _filter = v),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, correo o documento…',
                    hintStyle: TextStyle(color: kTextDim, fontSize: 13),
                    prefixIcon:
                        Icon(Icons.search, color: kTextSub, size: 20),
                    suffixIcon: _filter.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                color: kTextSub, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _filter = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Lista de usuarios ─────────────────────────────────────────────
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(color: kAccent),
                  )
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _filter.isEmpty
                                  ? Icons.people_outline
                                  : Icons.search_off_rounded,
                              color: kTextDim,
                              size: 56,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _filter.isEmpty
                                  ? 'Sin usuarios registrados'
                                  : 'Sin resultados para "$_filter"',
                              style: TextStyle(color: kTextSub),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: kAccent,
                        onRefresh: _loadUsers,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) =>
                              _UserCard(
                                user: filtered[i],
                                onDelete: () => _deleteUser(filtered[i]),
                              ),
                        ),
                      ),
          ),
        ],
      ),

      // ── FAB reload ─────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: _loading ? null : _loadUsers,
        backgroundColor: kAccent,
        child: const Icon(Icons.refresh_rounded, color: Colors.white),
      ),
    );
  }
}

// ── Chip de estadística ───────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: kAccent, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: kText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: kTextDim, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tarjeta de usuario ────────────────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.onDelete});
  final AppUser user;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.esAdmin;
    final inicial = user.nombreCompleto.isNotEmpty
        ? user.nombreCompleto[0].toUpperCase()
        : '?';

    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAdmin ? kAccent.withAlpha(80) : kBorder,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: isAdmin ? kAccentBg : kSurface,
          child: Text(
            inicial,
            style: TextStyle(
              color: isAdmin ? kAccent : kTextSub,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.nombreCompleto,
                style: TextStyle(
                  color: kText,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isAdmin ? kAccentBg : kGreenBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isAdmin ? 'Admin' : 'Cliente',
                style: TextStyle(
                  color: isAdmin ? kAccent : kGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.email_outlined,
                    size: 13, color: kTextDim),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    user.email,
                    style: TextStyle(color: kTextSub, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.badge_outlined, size: 13, color: kTextDim),
                const SizedBox(width: 4),
                Text(
                  user.documento,
                  style: TextStyle(color: kTextSub, fontSize: 12),
                ),
                if (user.membresia != null) ...[
                  const SizedBox(width: 10),
                  Icon(Icons.card_membership_outlined,
                      size: 13, color: kTextDim),
                  const SizedBox(width: 4),
                  Text(
                    user.membresia!,
                    style:
                        TextStyle(color: kTextSub, fontSize: 12),
                  ),
                ],
              ],
            ),
            if (user.vencimiento != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.event_outlined,
                      size: 13, color: kTextDim),
                  const SizedBox(width: 4),
                  Text(
                    'Vence: ${user.vencimiento}',
                    style: TextStyle(
                        color: kYellow, fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: isAdmin
            ? null
            : IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline_rounded,
                    color: kRed, size: 22),
                tooltip: 'Eliminar usuario',
              ),
      ),
    );
  }
}

// ── Color constante que falta en theme.dart ───────────────────────────────────


