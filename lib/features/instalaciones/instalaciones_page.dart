import 'package:flutter/material.dart';

import '../../core/services/instalacion_service.dart';
import '../../data/models/instalacion_model.dart';
import 'registrar_instalacion_page.dart';
import 'detalle_instalacion_page.dart';

class InstalacionesPage extends StatefulWidget {
  const InstalacionesPage({super.key});

  @override
  State<InstalacionesPage> createState() => _InstalacionesPageState();
}

class _InstalacionesPageState extends State<InstalacionesPage> {
  final InstalacionService _instalacionService = InstalacionService();

  bool cargando = false;
  String? error;

  int mesSeleccionado = DateTime.now().month;
  int anioSeleccionado = DateTime.now().year;

  List<InstalacionModel> instalaciones = [];

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

    // Por ahora lo dejamos en mayo 2026, igual que tu cronograma actual.
    mesSeleccionado = 5;
    anioSeleccionado = 2026;

    _cargarInstalaciones();
  }

  Future<void> _cargarInstalaciones() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final data = await _instalacionService.listarInstalaciones(
        mes: mesSeleccionado,
        anio: anioSeleccionado,
      );

      if (!mounted) return;

      setState(() {
        instalaciones = data;
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

  Color _estadoColor(String estado) {
    switch (estado.toUpperCase()) {
      case 'CONFORME':
        return const Color(0xFF16A34A);
      case 'OBSERVADO':
        return const Color(0xFFF97316);
      case 'NO_CONFORME':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Future<void> _abrirNuevaInstalacion() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const RegistrarInstalacionPage(),
      ),
    );

    if (resultado == true) {
      await _cargarInstalaciones();
    }
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

                    _cargarInstalaciones();
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

              _cargarInstalaciones();
            },
          ),
        ),
      ],
    );
  }

  Widget _resumenHeader() {
    final conformes =
        instalaciones.where((x) => x.estadoResultado == 'CONFORME').length;
    final observadas =
        instalaciones.where((x) => x.estadoResultado == 'OBSERVADO').length;
    final noConformes =
        instalaciones.where((x) => x.estadoResultado == 'NO_CONFORME').length;

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
            'Instalaciones de equipos',
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
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _miniResumen(
                  titulo: 'Total',
                  valor: instalaciones.length.toString(),
                  icono: Icons.ac_unit,
                  color: const Color(0xFFF97316),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniResumen(
                  titulo: 'Conformes',
                  valor: conformes.toString(),
                  icono: Icons.verified_outlined,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _miniResumen(
                  titulo: 'Observadas',
                  valor: observadas.toString(),
                  icono: Icons.visibility_outlined,
                  color: const Color(0xFFF97316),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniResumen(
                  titulo: 'No conformes',
                  valor: noConformes.toString(),
                  icono: Icons.error_outline,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniResumen({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.14),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              icono,
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valor,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
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

  Widget _instalacionCard(InstalacionModel item) {
    final estadoColor = _estadoColor(item.estadoResultado);

    final pruebasCompletadas = [
      item.pruebaEncendido,
      item.pruebaEnfriamiento,
      item.drenajeVerificado,
      item.conexionesElectricasVerificadas,
      item.fijacionEquipoVerificada,
      item.tuberiasAisladas,
      item.limpiezaArea,
    ].where((x) => x).length;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalleInstalacionPage(
              instalacion: item,
            ),
          ),
        );
      },
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: estadoColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.ac_unit,
                      color: estadoColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.codigoEquipo.isNotEmpty
                              ? '${item.codigoEquipo} · ${item.marca}'
                              : '${item.marca} · ${item.modelo}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${item.area} · ${item.ubicacion}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      item.estadoResultado,
                      style: TextStyle(
                        color: estadoColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: estadoColor.withOpacity(0.10),
                    side: BorderSide.none,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.event,
                    text: item.fechaInstalacion,
                  ),
                  _InfoChip(
                    icon: Icons.bolt_outlined,
                    text: item.voltaje.isNotEmpty ? item.voltaje : 'Voltaje N/R',
                  ),
                  _InfoChip(
                    icon: Icons.speed_outlined,
                    text: item.capacidadBtu.isNotEmpty
                        ? item.capacidadBtu
                        : 'BTU N/R',
                  ),
                  _InfoChip(
                    icon: Icons.fact_check_outlined,
                    text: '$pruebasCompletadas/7 pruebas',
                  ),
                ],
              ),
              if (item.observacionTecnica.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  item.observacionTecnica,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ],
          ),
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
                onPressed: _cargarInstalaciones,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarInstalaciones,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).padding.bottom + 100,
        ),
        children: [
          _selectorPeriodo(),
          const SizedBox(height: 14),
          _resumenHeader(),
          const SizedBox(height: 14),
          if (instalaciones.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.ac_unit,
                    size: 50,
                    color: Colors.black38,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No hay instalaciones registradas en este periodo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            )
          else
            ...instalaciones.map(_instalacionCard),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color sefPrimary = Color(0xFF1F2937);
    const Color sefAccent = Color(0xFFF97316);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Instalaciones'),
        backgroundColor: sefPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: cargando ? null : _cargarInstalaciones,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirNuevaInstalacion,
        backgroundColor: sefAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
      body: _contenido(),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      backgroundColor: const Color(0xFFF3F4F6),
      side: BorderSide.none,
    );
  }
}