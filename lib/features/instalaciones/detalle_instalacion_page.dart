import 'package:flutter/material.dart';

import '../../core/services/instalacion_service.dart';
import '../../data/models/instalacion_model.dart';

class DetalleInstalacionPage extends StatefulWidget {
  final InstalacionModel instalacion;

  const DetalleInstalacionPage({
    super.key,
    required this.instalacion,
  });

  @override
  State<DetalleInstalacionPage> createState() =>
      _DetalleInstalacionPageState();
}

class _DetalleInstalacionPageState extends State<DetalleInstalacionPage> {
  final InstalacionService _instalacionService = InstalacionService();

  bool cargando = false;
  String? error;
  List<Map<String, dynamic>> evidencias = [];

  @override
  void initState() {
    super.initState();
    _cargarEvidencias();
  }

  Future<void> _cargarEvidencias() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final data = await _instalacionService.listarEvidenciasInstalacion(
        instalacionId: widget.instalacion.id,
      );

      if (!mounted) return;

      setState(() {
        evidencias = data;
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

  String _tipoTexto(String tipo) {
    switch (tipo) {
      case 'ANTES':
        return 'Antes';
      case 'DURANTE':
        return 'Durante';
      case 'DESPUES':
        return 'Después';
      case 'PLACA_EQUIPO':
        return 'Placa del equipo';
      case 'PRUEBA_FUNCIONAMIENTO':
        return 'Prueba funcionamiento';
      case 'INSTALACION':
        return 'Instalación';
      default:
        return 'Otro';
    }
  }

  Widget _infoRow(String label, String value, IconData icon) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFF97316), size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkRow(String texto, bool valor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: valor ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: valor ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
        ),
      ),
      child: Row(
        children: [
          Icon(
            valor ? Icons.check_circle : Icons.cancel,
            color: valor ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String titulo,
    required IconData icono,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
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
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _header() {
    final item = widget.instalacion;
    final estadoColor = _estadoColor(item.estadoResultado);

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
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.ac_unit,
              color: estadoColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.codigoEquipo.isNotEmpty
                      ? item.codigoEquipo
                      : '${item.marca} ${item.modelo}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.area} · ${item.ubicacion}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: estadoColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    item.estadoResultado,
                    style: TextStyle(
                      color: estadoColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _evidenciasSection() {
    if (cargando) {
      return _sectionCard(
        titulo: 'Evidencias fotográficas',
        icono: Icons.photo_camera_outlined,
        children: const [
          Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF97316),
              ),
            ),
          ),
        ],
      );
    }

    if (error != null) {
      return _sectionCard(
        titulo: 'Evidencias fotográficas',
        icono: Icons.photo_camera_outlined,
        children: [
          Text(
            error!,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    if (evidencias.isEmpty) {
      return _sectionCard(
        titulo: 'Evidencias fotográficas',
        icono: Icons.photo_camera_outlined,
        children: const [
          Padding(
            padding: EdgeInsets.all(14),
            child: Text(
              'No hay evidencias registradas para esta instalación.',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      );
    }

    return _sectionCard(
      titulo: 'Evidencias fotográficas',
      icono: Icons.photo_camera_outlined,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: evidencias.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, index) {
            final e = evidencias[index];
            final url = e['url']?.toString() ?? '';
            final tipo = e['tipo_evidencia']?.toString() ?? '';
            final obs = e['observacion']?.toString() ?? '';

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VistaFotoInstalacionPage(
                      url: url,
                      titulo: _tipoTexto(tipo),
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: const Color(0xFFE5E7EB),
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.black38,
                            size: 44,
                          ),
                        );
                      },
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.75),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: Text(
                          obs.isNotEmpty ? obs : _tipoTexto(tipo),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.instalacion;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Detalle instalación'),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: cargando ? null : _cargarEvidencias,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarEvidencias,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).padding.bottom + 90,
          ),
          children: [
            _header(),
            const SizedBox(height: 14),

            _sectionCard(
              titulo: 'Datos del equipo',
              icono: Icons.ac_unit,
              children: [
                _infoRow('Marca', item.marca, Icons.label_outline),
                _infoRow('Modelo', item.modelo, Icons.memory_outlined),
                _infoRow(
                  'Número de serie',
                  item.numeroSerie,
                  Icons.confirmation_number_outlined,
                ),
                _infoRow('Capacidad', item.capacidadBtu, Icons.speed_outlined),
                _infoRow('Voltaje', item.voltaje, Icons.bolt_outlined),
                _infoRow('Tipo', item.tipoEquipo, Icons.category_outlined),
              ],
            ),

            _sectionCard(
              titulo: 'Fecha y responsables',
              icono: Icons.event_available,
              children: [
                _infoRow(
                  'Fecha instalación',
                  item.fechaInstalacion,
                  Icons.event,
                ),
                _infoRow('Hora inicio', item.horaInicio, Icons.access_time),
                _infoRow('Hora fin', item.horaFin, Icons.access_time_filled),
                _infoRow(
                  'Responsable técnico',
                  item.responsableTecnico,
                  Icons.engineering_outlined,
                ),
                _infoRow(
                  'Responsable área',
                  item.responsableArea,
                  Icons.person_outline,
                ),
              ],
            ),

            _sectionCard(
              titulo: 'Pruebas de funcionamiento',
              icono: Icons.fact_check_outlined,
              children: [
                _checkRow('Prueba de encendido', item.pruebaEncendido),
                _checkRow('Prueba de enfriamiento', item.pruebaEnfriamiento),
                _checkRow('Drenaje verificado', item.drenajeVerificado),
                _checkRow(
                  'Conexiones eléctricas verificadas',
                  item.conexionesElectricasVerificadas,
                ),
                _checkRow(
                  'Fijación del equipo verificada',
                  item.fijacionEquipoVerificada,
                ),
                _checkRow('Tuberías aisladas', item.tuberiasAisladas),
                _checkRow('Limpieza final del área', item.limpiezaArea),
              ],
            ),

            _evidenciasSection(),

            _sectionCard(
              titulo: 'Cierre y conformidad',
              icono: Icons.assignment_turned_in_outlined,
              children: [
                _infoRow(
                  'Observación técnica',
                  item.observacionTecnica,
                  Icons.notes_outlined,
                ),
                _infoRow(
                  'Recomendación',
                  item.recomendacion,
                  Icons.tips_and_updates_outlined,
                ),
                _checkRow(
                  'Conformidad del responsable',
                  item.conformidadResponsable,
                ),
                _infoRow(
                  'Responsable conformidad',
                  item.nombreResponsableConformidad,
                  Icons.verified_user_outlined,
                ),
                _infoRow(
                  'Usuario registro',
                  item.usuarioRegistro,
                  Icons.person_pin_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class VistaFotoInstalacionPage extends StatelessWidget {
  final String url;
  final String titulo;

  const VistaFotoInstalacionPage({
    super.key,
    required this.url,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return const Text(
                'No se pudo cargar la imagen.',
                style: TextStyle(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}