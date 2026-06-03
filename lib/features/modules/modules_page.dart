import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/providers/auth_provider.dart';

import '../aires/aires_page.dart';
import '../informes/informes_page.dart';
import '../mantenimiento/mantenimientos_page.dart';
import '../users/usuarios_page.dart';
import '../auth/login_page.dart';
import '../dashboard/dashboard_mantenimiento_page.dart';
import '../instalaciones/instalaciones_page.dart';


class ModulesPage extends StatelessWidget {
  const ModulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

final allModules = [
  const ModuleOption(
    title: 'Dashboard',
    subtitle: 'Resumen de mantenimiento',
    icon: Icons.dashboard_outlined,
    color: Color(0xFFF97316),
    page: DashboardMantenimientoPage(),
    ruta: 'dashboard',
  ),
  const ModuleOption(
    title: 'Usuarios',
    subtitle: 'Gestión de accesos',
    icon: Icons.people_alt_outlined,
    color: Color(0xFF2563EB),
    page: UsuariosPage(),
    ruta: 'usuarios',
  ),
  const ModuleOption(
    title: 'Inventario AA',
    subtitle: 'Equipos registrados',
    icon: Icons.ac_unit,
    color: Color(0xFF0891B2),
    page: AiresPage(),
    ruta: 'aires',
  ),
  const ModuleOption(
    title: 'Cronograma',
    subtitle: 'Mantenimientos programados',
    icon: Icons.calendar_month_outlined,
    color: Color(0xFF16A34A),
    page: MantenimientosPage(),
    ruta: 'cronograma',
  ),
  const ModuleOption(
    title: 'Instalaciones',
    subtitle: 'Registro de equipos nuevos',
    icon: Icons.add_home_work_outlined,
    color: Color(0xFF9333EA),
    page: InstalacionesPage(),
    ruta: 'instalaciones',
  ),
  const ModuleOption(
    title: 'Informes PDF',
    subtitle: 'Reportes técnicos',
    icon: Icons.picture_as_pdf_outlined,
    color: Color(0xFFDC2626),
    page: InformesPage(),
    ruta: 'informes',
  ),
];

final modules = allModules.where((m) => auth.tieneModulo(m.ruta)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('SEFAB'),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Notificaciones',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
            decoration: const BoxDecoration(
              color: Color(0xFF1F2937),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(26),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panel principal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Gestión de servicios técnicos, inventario e informes.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
  child: modules.isEmpty
      ? const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No tiene módulos asignados.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      : GridView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: modules.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 260,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) {
            return _ModuleCard(item: modules[index]);
          },
        ),
),
        ],
      ),
    );
  }
}

class ModuleOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget page;
  final String ruta;

  const ModuleOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.page,
    required this.ruta,
  });
}

class _ModuleCard extends StatelessWidget {
  final ModuleOption item;

  const _ModuleCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => item.page,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 32,
                ),
              ),
              const Spacer(),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}