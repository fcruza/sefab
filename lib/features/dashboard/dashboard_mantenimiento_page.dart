import 'package:flutter/material.dart';

import '../../core/services/dashboard_service.dart';
import '../../data/models/dashboard_mantenimiento_model.dart';

class DashboardMantenimientoPage extends StatefulWidget {
  const DashboardMantenimientoPage({super.key});

  @override
  State<DashboardMantenimientoPage> createState() =>
      _DashboardMantenimientoPageState();
}

class _DashboardMantenimientoPageState
    extends State<DashboardMantenimientoPage> {
  final DashboardService _dashboardService = DashboardService();

  int mesSeleccionado = DateTime.now().month;
  int anioSeleccionado = DateTime.now().year;

  bool cargando = false;
  String? error;
  DashboardMantenimientoModel? dashboard;

  final List<Map<String, dynamic>> meses = const [
    {'numero': 1, 'nombre': 'Enero'},
    {'numero': 2, 'nombre': 'Febrero'},
    {'numero': 3, 'nombre': 'Marzo'},
    {'numero': 4, 'nombre': 'Abril'},
    {'numero': 5, 'nombre': 'Mayo'},
    {'numero': 6, 'nombre': 'Junio'},
    {'numero': 7, 'nombre': 'Julio'},
    {'numero': 8, 'nombre': 'Agosto'},
    {'numero': 9, 'nombre': 'Septiembre'},
    {'numero': 10, 'nombre': 'Octubre'},
    {'numero': 11, 'nombre': 'Noviembre'},
    {'numero': 12, 'nombre': 'Diciembre'},
  ];

  @override
  void initState() {
    super.initState();

    // Si tu cronograma está en 2026, puedes dejarlo fijo por ahora:
    anioSeleccionado = 2026;
    mesSeleccionado = 5;

    _cargarDashboard();
  }

  Future<void> _cargarDashboard() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final data = await _dashboardService.obtenerDashboard(
        mes: mesSeleccionado,
        anio: anioSeleccionado,
      );

      if (!mounted) return;

      setState(() {
        dashboard = data;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  String get nombreMes {
    final item = meses.firstWhere(
      (m) => m['numero'] == mesSeleccionado,
      orElse: () => {'numero': 0, 'nombre': 'Mes'},
    );

    return item['nombre'].toString();
  }

  Widget _resumenPrincipal(DashboardMantenimientoModel d) {
    const colorPrincipal = Color(0xFF1F2937);
    const colorNaranja = Color(0xFFF97316);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1F2937),
            Color(0xFF374151),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard de mantenimiento',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$nombreMes $anioSeleccionado',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _miniDato(
                  titulo: 'Cumplimiento',
                  valor: '${d.porcentajeCumplimiento.toStringAsFixed(0)}%',
                  icono: Icons.trending_up,
                  color: colorNaranja,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniDato(
                  titulo: 'Programados',
                  valor: d.totalProgramados.toString(),
                  icono: Icons.calendar_month,
                  color: colorPrincipal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniDato({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              icono,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valor,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardIndicador({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color color,
    String? subtitulo,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icono,
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitulo != null && subtitulo.trim().isNotEmpty)
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      color: Colors.black38,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridIndicadores(DashboardMantenimientoModel d) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        _cardIndicador(
          titulo: 'Realizados',
          valor: d.realizados.toString(),
          icono: Icons.check_circle_outline,
          color: const Color(0xFF16A34A),
        ),
        _cardIndicador(
          titulo: 'Pendientes',
          valor: d.pendientes.toString(),
          icono: Icons.pending_actions,
          color: const Color(0xFF6B7280),
        ),
        _cardIndicador(
          titulo: 'Observados',
          valor: d.observados.toString(),
          icono: Icons.visibility_outlined,
          color: const Color(0xFFF97316),
        ),
        _cardIndicador(
          titulo: 'Vencidos',
          valor: d.vencidos.toString(),
          icono: Icons.error_outline,
          color: const Color(0xFFDC2626),
        ),
        _cardIndicador(
          titulo: 'Incidentes',
          valor: d.totalIncidentes.toString(),
          icono: Icons.report_problem_outlined,
          color: const Color(0xFFB91C1C),
        ),
        _cardIndicador(
          titulo: 'Evidencias',
          valor: d.totalEvidencias.toString(),
          icono: Icons.photo_camera_outlined,
          color: const Color(0xFF2563EB),
        ),
        _cardIndicador(
          titulo: 'PETS pendientes',
          valor: d.petsPendientes.toString(),
          icono: Icons.health_and_safety_outlined,
          color: const Color(0xFF9333EA),
        ),
        _cardIndicador(
          titulo: 'EPP pendientes',
          valor: d.eppPendientes.toString(),
          icono: Icons.construction_outlined,
          color: const Color(0xFFCA8A04),
        ),
      ],
    );
  }

  Widget _selectorPeriodo() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            value: mesSeleccionado,
            decoration: InputDecoration(
              labelText: 'Mes',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            items: meses.map((m) {
              return DropdownMenuItem<int>(
                value: int.parse(m['numero'].toString()),
                child: Text(m['nombre'].toString()),
              );
            }).toList(),
            onChanged: cargando
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() {
                      mesSeleccionado = value;
                    });
                    _cargarDashboard();
                  },
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 115,
          child: TextFormField(
            initialValue: anioSeleccionado.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Año',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onFieldSubmitted: (value) {
              final anio = int.tryParse(value);
              if (anio == null) return;

              setState(() {
                anioSeleccionado = anio;
              });

              _cargarDashboard();
            },
          ),
        ),
      ],
    );
  }

  Widget _listaObservados(DashboardMantenimientoModel d) {
    if (d.observadosLista.isEmpty) {
      return _emptyCard(
        titulo: 'Equipos observados',
        mensaje: 'No hay equipos observados en este periodo.',
        icono: Icons.check_circle_outline,
      );
    }

    return _seccionLista(
      titulo: 'Últimos observados',
      icono: Icons.visibility_outlined,
      children: d.observadosLista.map((item) {
        return _itemLista(
          titulo:
              '${item['equipo_codigo'] ?? ''} · ${item['equipo_marca'] ?? ''}',
          subtitulo:
              '${item['area'] ?? ''} · ${item['ubicacion'] ?? ''}',
          detalle: item['observacion']?.toString() ?? '',
          color: const Color(0xFFF97316),
          icono: Icons.visibility_outlined,
        );
      }).toList(),
    );
  }

  Widget _listaIncidentes(DashboardMantenimientoModel d) {
    if (d.incidentesLista.isEmpty) {
      return _emptyCard(
        titulo: 'Incidentes',
        mensaje: 'No hay incidentes registrados en este periodo.',
        icono: Icons.verified_outlined,
      );
    }

    return _seccionLista(
      titulo: 'Últimos incidentes',
      icono: Icons.report_problem_outlined,
      children: d.incidentesLista.map((item) {
        return _itemLista(
          titulo:
              '${item['tipo_incidente'] ?? ''} · ${item['equipo_codigo'] ?? ''}',
          subtitulo:
              '${item['area'] ?? ''} · ${item['ubicacion'] ?? ''}',
          detalle: item['descripcion']?.toString() ?? '',
          color: const Color(0xFFDC2626),
          icono: Icons.report_problem_outlined,
        );
      }).toList(),
    );
  }

  Widget _seccionLista({
    required String titulo,
    required IconData icono,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, color: const Color(0xFFF97316)),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _itemLista({
    required String titulo,
    required String subtitulo,
    required String detalle,
    required Color color,
    required IconData icono,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                if (detalle.trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    detalle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard({
    required String titulo,
    required String mensaje,
    required IconData icono,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              icono,
              color: const Color(0xFF16A34A),
              size: 30,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    mensaje,
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenido() {
    if (cargando) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF97316),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _cargarDashboard,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final d = dashboard;

    if (d == null) {
      return const Center(
        child: Text('No hay información disponible.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarDashboard,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).padding.bottom + 90,
        ),
        children: [
          _selectorPeriodo(),
          const SizedBox(height: 14),
          _resumenPrincipal(d),
          const SizedBox(height: 14),
          _gridIndicadores(d),
          const SizedBox(height: 14),
          _listaObservados(d),
          const SizedBox(height: 14),
          _listaIncidentes(d),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color sefPrimary = Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: sefPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: cargando ? null : _cargarDashboard,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _contenido(),
    );
  }
}