import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import 'informe_service.dart';
import 'informes_generados_page.dart';

class InformesPage extends StatefulWidget {
  const InformesPage({super.key});

  @override
  State<InformesPage> createState() => _InformesPageState();
}

class _InformesPageState extends State<InformesPage> {
  final InformeService informeService = InformeService();

  int mesSeleccionado = 7;
  int anioSeleccionado = 2026;

  bool cargando = false;
  String? error;
  Map<String, dynamic>? reporte;

  final List<_MesItem> meses = const [
    _MesItem(numero: 5, nombre: 'Mayo'),
    _MesItem(numero: 6, nombre: 'Junio'),
    _MesItem(numero: 7, nombre: 'Julio'),
  ];

  @override
  void initState() {
    super.initState();
    _generarReporte();
  }

  Future<void> _abrirPdfInforme() async {
    final requestId =
        '${DateTime.now().millisecondsSinceEpoch}_${mesSeleccionado}_$anioSeleccionado';

    final url = '${AppConfig.baseUrl}/generar_informe_pdf.php'
        '?mes=$mesSeleccionado'
        '&anio=$anioSeleccionado'
        '&request_id=$requestId'
        '&api_key=${Uri.encodeComponent(AppConfig.apiKey)}';

    final uri = Uri.parse(url);

    try {
      final abierto = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!abierto && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el PDF.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir el PDF: $e'),
        ),
      );
    }
  }

  Future<void> _generarReporte() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final data = await informeService.obtenerReporteMensual(
        mes: mesSeleccionado,
        anio: anioSeleccionado,
      );

      if (!mounted) return;

      setState(() {
        reporte = data;
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

  String _texto(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  List<dynamic> _lista(dynamic value) {
    if (value is List) return value;
    return [];
  }

  Map<String, dynamic> _mapa(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  @override
  Widget build(BuildContext context) {
    const Color sefPrimary = Color(0xFF1F2937);
    const Color sefAccent = Color(0xFFF97316);

    final informe = _mapa(reporte?['informe']);
    final resumen = _mapa(reporte?['resumen']);
    final datosGenerales = _mapa(reporte?['datos_generales']);
    final contenidoBase = _mapa(reporte?['contenido_base']);
    final firma = _mapa(reporte?['firma']);
    final equipos = _lista(reporte?['equipos']);
    final anexos = _lista(reporte?['anexos_por_area']);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Informes'),
        backgroundColor: sefPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Informes generados',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InformesGeneradosPage(),
                ),
              );
            },
            icon: const Icon(Icons.folder_copy_outlined),
          ),
          IconButton(
            tooltip: 'Actualizar',
            onPressed: cargando ? null : _generarReporte,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            decoration: const BoxDecoration(
              color: sefPrimary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(26),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informe mensual de mantenimiento',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Mantenimiento preventivo de equipos de aire acondicionado',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: meses.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final mes = meses[index];
                      final selected = mes.numero == mesSeleccionado;

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: cargando
                            ? null
                            : () {
                                setState(() {
                                  mesSeleccionado = mes.numero;
                                });
                                _generarReporte();
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: selected ? sefAccent : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            mes.nombre,
                            style: TextStyle(
                              color: selected ? Colors.white : sefPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: cargando
                ? const Center(
                    child: CircularProgressIndicator(color: sefAccent),
                  )
                : error != null
                    ? Center(
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
                                onPressed: _generarReporte,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : reporte == null
                        ? const Center(
                            child: Text(
                              'No hay información para mostrar.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        : ListView(
                            padding: EdgeInsets.fromLTRB(
                              16,
                              16,
                              16,
                              MediaQuery.of(context).padding.bottom + 110,
                            ),
                            children: [
                              _InformeHeaderCard(informe: informe),
                              const SizedBox(height: 14),
                              _ResumenCard(resumen: resumen),
                              const SizedBox(height: 14),
                              _SeccionCard(
                                titulo: '1. DATOS GENERALES',
                                children: [
                                  _LineaTexto(
                                    label: 'Tipo de servicio',
                                    value: _texto(
                                      datosGenerales['tipo_servicio'],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Áreas intervenidas:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ..._lista(
                                    datosGenerales['areas_intervenidas'],
                                  ).map(
                                    (e) => _BulletText(text: _texto(e)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _SeccionCard(
                                titulo: '2. OBJETIVO DEL MANTENIMIENTO',
                                children: [
                                  Text(
                                    _texto(contenidoBase['objetivo']),
                                    textAlign: TextAlign.justify,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _SeccionCard(
                                titulo: '3. ALCANCE DEL SERVICIO',
                                children: [
                                  Text(
                                    _texto(contenidoBase['alcance']),
                                    textAlign: TextAlign.justify,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _SeccionCard(
                                titulo: '4. ACTIVIDADES REALIZADAS',
                                children: [
                                  ..._lista(
                                    contenidoBase['actividades_realizadas'],
                                  ).map(
                                    (e) => _BulletText(text: _texto(e)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _SeccionCard(
                                titulo: '5. RESULTADOS DEL MANTENIMIENTO',
                                children: [
                                  ..._lista(contenidoBase['resultados']).map(
                                    (e) => _BulletText(text: _texto(e)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _SeccionCard(
                                titulo: '6. OBSERVACIONES',
                                children: [
                                  ..._lista(contenidoBase['observaciones']).map(
                                    (e) => _BulletText(text: _texto(e)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _SeccionCard(
                                titulo: '7. RECOMENDACIONES',
                                children: [
                                  ..._lista(
                                    contenidoBase['recomendaciones'],
                                  ).map(
                                    (e) => _BulletText(text: _texto(e)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _SeccionCard(
                                titulo: '8. CONCLUSIÓN',
                                children: [
                                  Text(
                                    _texto(contenidoBase['conclusion']),
                                    textAlign: TextAlign.justify,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _EquiposCard(equipos: equipos),
                              const SizedBox(height: 14),
                              _AnexosCard(anexos: anexos),
                              const SizedBox(height: 14),
                              _FirmaCard(firma: firma),
                              const SizedBox(height: 18),
                              SizedBox(
                                height: 54,
                                child: ElevatedButton.icon(
                                  onPressed: _abrirPdfInforme,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: sefAccent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: const Icon(Icons.picture_as_pdf),
                                  label: const Text(
                                    'Generar documento',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
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
}

class _MesItem {
  final int numero;
  final String nombre;

  const _MesItem({
    required this.numero,
    required this.nombre,
  });
}

class _InformeHeaderCard extends StatelessWidget {
  final Map<String, dynamic> informe;

  const _InformeHeaderCard({
    required this.informe,
  });

  String _texto(dynamic value) => value?.toString() ?? '';

  @override
  Widget build(BuildContext context) {
    return _SeccionCard(
      titulo: _texto(informe['numero']),
      children: [
        _LineaTexto(label: 'RUC', value: _texto(informe['ruc_sefab'])),
        _LineaTexto(label: 'Señores', value: _texto(informe['cliente'])),
        _LineaTexto(label: 'DNI/RUC', value: _texto(informe['ruc_cliente'])),
        _LineaTexto(label: 'Asunto', value: _texto(informe['asunto'])),
        _LineaTexto(label: 'Fecha', value: _texto(informe['fecha'])),
        _LineaTexto(label: 'Periodo', value: _texto(informe['periodo'])),
      ],
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final Map<String, dynamic> resumen;

  const _ResumenCard({
    required this.resumen,
  });

  String _texto(dynamic value) => value?.toString() ?? '0';

  @override
  Widget build(BuildContext context) {
    final porcentaje = _texto(resumen['porcentaje_cumplimiento']);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de cumplimiento',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ResumenItem(
                    label: 'Programados',
                    value: _texto(resumen['total_programados']),
                  ),
                ),
                Expanded(
                  child: _ResumenItem(
                    label: 'Cumplidos',
                    value: _texto(resumen['cumplidos']),
                  ),
                ),
                Expanded(
                  child: _ResumenItem(
                    label: 'Avance',
                    value: '$porcentaje%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _EstadoChip(
                  label: 'Realizados: ${_texto(resumen['realizados'])}',
                  color: const Color(0xFF16A34A),
                ),
                _EstadoChip(
                  label: 'Observados: ${_texto(resumen['observados'])}',
                  color: const Color(0xFFF97316),
                ),
                _EstadoChip(
                  label: 'Pendientes: ${_texto(resumen['pendientes'])}',
                  color: const Color(0xFF6B7280),
                ),
                _EstadoChip(
                  label: 'En proceso: ${_texto(resumen['en_proceso'])}',
                  color: const Color(0xFF2563EB),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumenItem extends StatelessWidget {
  final String label;
  final String value;

  const _ResumenItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF97316),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _EstadoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _EstadoChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        Icons.circle,
        size: 12,
        color: color,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.withOpacity(0.10),
      side: BorderSide.none,
    );
  }
}

class _SeccionCard extends StatelessWidget {
  final String titulo;
  final List<Widget> children;

  const _SeccionCard({
    required this.titulo,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            height: 1.35,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _LineaTexto extends StatelessWidget {
  final String label;
  final String value;

  const _LineaTexto({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final texto = value.trim().isEmpty ? 'No registrado' : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            height: 1.35,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: texto),
          ],
        ),
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  final String text;

  const _BulletText({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}

class _EquiposCard extends StatelessWidget {
  final List<dynamic> equipos;

  const _EquiposCard({
    required this.equipos,
  });

  Map<String, dynamic> _mapa(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  String _texto(dynamic value) => value?.toString() ?? '';

  @override
  Widget build(BuildContext context) {
    return _SeccionCard(
      titulo: 'Equipos intervenidos',
      children: [
        if (equipos.isEmpty)
          const Text(
            'No hay equipos registrados para este periodo.',
            style: TextStyle(color: Colors.black54),
          )
        else
          ...equipos.map((item) {
            final map = _mapa(item);
            final mantenimiento = _mapa(map['mantenimiento']);
            final ejecucion = _mapa(map['ejecucion']);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_texto(mantenimiento['equipo_codigo'])} · ${_texto(mantenimiento['area'])}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Estado: ${_texto(mantenimiento['estado'])} · Fecha: ${_texto(mantenimiento['fecha_programada'])}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  if (ejecucion.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Presión: ${_texto(ejecucion['presion_refrigerante'])} · Amperaje: ${_texto(ejecucion['amperaje_compresor'])}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _AnexosCard extends StatelessWidget {
  final List<dynamic> anexos;

  const _AnexosCard({
    required this.anexos,
  });

  Map<String, dynamic> _mapa(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  String _texto(dynamic value) => value?.toString() ?? '';

  List<dynamic> _lista(dynamic value) {
    if (value is List) return value;
    return [];
  }

  String _actividadDesdeObservacion(String observacion) {
    var texto = observacion.trim();

    texto = texto.replaceAll(
      RegExp(r'\s*-\s*Evidencia\s*\d+$', caseSensitive: false),
      '',
    );

    if (texto.isEmpty) {
      return 'Actividad sin descripción';
    }

    return texto;
  }

  @override
  Widget build(BuildContext context) {
    return _SeccionCard(
      titulo: '9. ANEXOS',
      children: [
        const Text(
          'Evidencia fotográfica de las labores de mantenimiento del sistema de aire acondicionado.',
          style: TextStyle(color: Colors.black87),
        ),
        const SizedBox(height: 12),
        if (anexos.isEmpty)
          const Text(
            'No hay evidencias registradas para este periodo.',
            style: TextStyle(color: Colors.black54),
          )
        else
          ...anexos.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final anexo = _mapa(entry.value);
            final area = _texto(anexo['area']);

            final evidenciasFlat = _lista(anexo['evidencias']);
            final generalesDirecto = _lista(anexo['generales']);
            final checklistDirecto = anexo['checklist'];

            final List<Map<String, dynamic>> generales = [];
            final Map<String, List<Map<String, dynamic>>> checklist = {};

            if (generalesDirecto.isNotEmpty || checklistDirecto != null) {
              for (final item in generalesDirecto) {
                final evidencia = _mapa(item);
                if (evidencia.isNotEmpty) {
                  generales.add(evidencia);
                }
              }

              if (checklistDirecto is Map) {
                checklistDirecto.forEach((actividad, fotos) {
                  final listaFotos = _lista(fotos)
                      .map((e) => _mapa(e))
                      .where((e) => e.isNotEmpty)
                      .toList();

                  if (listaFotos.isNotEmpty) {
                    checklist[actividad.toString()] = listaFotos;
                  }
                });
              }
            } else {
              for (final item in evidenciasFlat) {
                final evidencia = _mapa(item);
                if (evidencia.isEmpty) continue;

                final tipo = _texto(
                  evidencia['tipo_evidencia'],
                ).trim().toLowerCase();

                final obs = _texto(evidencia['observacion']);

                if (tipo == 'checklist') {
                  final actividad = _actividadDesdeObservacion(obs);

                  checklist.putIfAbsent(actividad, () => []);
                  checklist[actividad]!.add(evidencia);
                } else {
                  generales.add(evidencia);
                }
              }
            }

            final sinEvidencias = generales.isEmpty && checklist.isEmpty;

            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fotos Grupo $index: $area',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (sinEvidencias)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Sin evidencias fotográficas registradas.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  if (generales.isNotEmpty) ...[
                    const Text(
                      'Evidencias generales:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _GridEvidenciasInforme(evidencias: generales),
                    const SizedBox(height: 14),
                  ],
                  if (checklist.isNotEmpty) ...[
                    const Text(
                      'Evidencias por actividad:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...checklist.entries.map((actividadEntry) {
                      final actividad = actividadEntry.key;
                      final fotos = actividadEntry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              actividad,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _GridEvidenciasInforme(evidencias: fotos),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _GridEvidenciasInforme extends StatelessWidget {
  final List<Map<String, dynamic>> evidencias;

  const _GridEvidenciasInforme({
    required this.evidencias,
  });

  String _texto(dynamic value) => value?.toString() ?? '';

  @override
  Widget build(BuildContext context) {
    if (evidencias.isEmpty) {
      return const Text(
        'Sin evidencias fotográficas registradas.',
        style: TextStyle(color: Colors.black54),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: evidencias.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final evidencia = evidencias[index];

        final url = _texto(evidencia['url']);
        final obs = _texto(evidencia['observacion']);
        final tipo = _texto(evidencia['tipo_evidencia']);

        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
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
                    ),
                  );
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.black.withOpacity(0.60),
                  child: Text(
                    obs.isNotEmpty
                        ? obs
                        : tipo.isNotEmpty
                            ? tipo
                            : 'Evidencia',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FirmaCard extends StatelessWidget {
  final Map<String, dynamic> firma;

  const _FirmaCard({
    required this.firma,
  });

  String _texto(dynamic value) => value?.toString() ?? '';

  @override
  Widget build(BuildContext context) {
    return _SeccionCard(
      titulo: 'Firma',
      children: [
        const SizedBox(height: 26),
        const Center(
          child: Text('____________________________'),
        ),
        Center(
          child: Text(
            'Tec. ${_texto(firma['nombre'])}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Text(
            _texto(firma['cargo']),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Dirección: ${_texto(firma['direccion'])} / RPC: ${_texto(firma['telefono'])} / ${_texto(firma['correo'])}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}