import 'package:flutter/material.dart';

import 'informe_service.dart';

class HistorialMedicionesPage extends StatefulWidget {
  final String equipoCodigo;

  const HistorialMedicionesPage({
    super.key,
    required this.equipoCodigo,
  });

  @override
  State<HistorialMedicionesPage> createState() =>
      _HistorialMedicionesPageState();
}

class _HistorialMedicionesPageState extends State<HistorialMedicionesPage> {
  final InformeService informeService = InformeService();

  bool cargando = false;
  String? error;

  Map<String, dynamic>? data;
  List<dynamic> historial = [];

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final res = await informeService.listarHistorialMediciones(
        equipoCodigo: widget.equipoCodigo,
      );

      if (!mounted) return;

      setState(() {
        data = res;
        historial = res['data'] is List ? res['data'] : [];
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

  Map<String, dynamic> _mapa(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  Color _colorNivel(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'normal':
        return const Color(0xFF16A34A);
      case 'leve':
        return const Color(0xFFF97316);
      case 'moderada':
        return const Color(0xFFEA580C);
      case 'alta':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color sefPrimary = Color(0xFF1F2937);
    const Color sefAccent = Color(0xFFF97316);

    final equipo = _mapa(data?['equipo']);
    final alerta = _mapa(data?['alerta']);
    final alertaPresion = _mapa(alerta['presion']);
    final alertaAmperaje = _mapa(alerta['amperaje']);
    final nivelGeneral = _texto(alerta['nivel_general']);
    final colorGeneral = _colorNivel(nivelGeneral);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Historial técnico'),
        backgroundColor: sefPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: cargando ? null : _cargarHistorial,
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
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.ac_unit,
                    color: Color(0xFF0891B2),
                    size: 31,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.equipoCodigo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_texto(equipo['area'])} · ${_texto(equipo['ubicacion'])}',
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
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
                                onPressed: _cargarHistorial,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
                              ),
                            ],
                          ),
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
                          _AlertaTecnicaCard(
                            nivelGeneral: nivelGeneral,
                            colorGeneral: colorGeneral,
                            alertaPresion: alertaPresion,
                            alertaAmperaje: alertaAmperaje,
                          ),
                          const SizedBox(height: 14),
                          _UltimaMedicionCard(
                            ultima: _mapa(data?['ultima_medicion']),
                            anterior: _mapa(data?['medicion_anterior']),
                          ),
                          const SizedBox(height: 14),
                          _HistorialTablaCard(
                            historial: historial,
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _AlertaTecnicaCard extends StatelessWidget {
  final String nivelGeneral;
  final Color colorGeneral;
  final Map<String, dynamic> alertaPresion;
  final Map<String, dynamic> alertaAmperaje;

  const _AlertaTecnicaCard({
    required this.nivelGeneral,
    required this.colorGeneral,
    required this.alertaPresion,
    required this.alertaAmperaje,
  });

  String _texto(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final nivel = nivelGeneral.trim().isEmpty ? 'Sin datos' : nivelGeneral;

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
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: colorGeneral,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Alerta técnica: $nivel',
                    style: TextStyle(
                      color: colorGeneral,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _VariacionItem(
              titulo: 'Presión',
              porcentaje: _texto(alertaPresion['porcentaje']),
              valor: _texto(alertaPresion['valor']),
              nivel: _texto(alertaPresion['nivel']),
              mensaje: _texto(alertaPresion['mensaje']),
            ),
            const Divider(height: 22),
            _VariacionItem(
              titulo: 'Amperaje',
              porcentaje: _texto(alertaAmperaje['porcentaje']),
              valor: _texto(alertaAmperaje['valor']),
              nivel: _texto(alertaAmperaje['nivel']),
              mensaje: _texto(alertaAmperaje['mensaje']),
            ),
          ],
        ),
      ),
    );
  }
}

class _VariacionItem extends StatelessWidget {
  final String titulo;
  final String porcentaje;
  final String valor;
  final String nivel;
  final String mensaje;

  const _VariacionItem({
    required this.titulo,
    required this.porcentaje,
    required this.valor,
    required this.nivel,
    required this.mensaje,
  });

  Color _colorNivel(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'normal':
        return const Color(0xFF16A34A);
      case 'leve':
        return const Color(0xFFF97316);
      case 'moderada':
        return const Color(0xFFEA580C);
      case 'alta':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorNivel(nivel);

    final porcentajeTexto =
        porcentaje.trim().isEmpty || porcentaje == 'null' ? 'Sin datos' : '$porcentaje%';

    final valorTexto =
        valor.trim().isEmpty || valor == 'null' ? '' : 'Variación: $valor';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              label: Text(
                nivel.trim().isEmpty ? 'Sin datos' : nivel,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: color.withOpacity(0.10),
              side: BorderSide.none,
            ),
            Chip(
              label: Text(porcentajeTexto),
              backgroundColor: const Color(0xFFF3F4F6),
              side: BorderSide.none,
            ),
            if (valorTexto.isNotEmpty)
              Chip(
                label: Text(valorTexto),
                backgroundColor: const Color(0xFFF3F4F6),
                side: BorderSide.none,
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          mensaje.trim().isEmpty ? 'No hay datos suficientes para comparar.' : mensaje,
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}

class _UltimaMedicionCard extends StatelessWidget {
  final Map<String, dynamic> ultima;
  final Map<String, dynamic> anterior;

  const _UltimaMedicionCard({
    required this.ultima,
    required this.anterior,
  });

  String _texto(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  String _valor(dynamic value, String unidad) {
    final texto = _texto(value);
    if (texto.trim().isEmpty || texto == 'null') return 'Sin dato';
    return '$texto $unidad';
  }

  @override
  Widget build(BuildContext context) {
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
              'Última medición',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MedicionBox(
                    label: 'Presión',
                    value: _valor(ultima['presion_refrigerante'], 'PSI'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MedicionBox(
                    label: 'Amperaje',
                    value: _valor(ultima['amperaje_compresor'], 'A'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Fecha: ${_texto(ultima['fecha_medicion']).isEmpty ? 'Sin dato' : _texto(ultima['fecha_medicion'])}',
              style: const TextStyle(color: Colors.black54),
            ),
            if (anterior.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Medición anterior: ${_texto(anterior['fecha_medicion'])}',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MedicionBox extends StatelessWidget {
  final String label;
  final String value;

  const _MedicionBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFED7AA),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFF97316),
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _HistorialTablaCard extends StatelessWidget {
  final List<dynamic> historial;

  const _HistorialTablaCard({
    required this.historial,
  });

  String _texto(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  Map<String, dynamic> _mapa(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  @override
  Widget build(BuildContext context) {
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
              'Historial de mediciones',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 12),
            if (historial.isEmpty)
              const Text(
                'No hay mediciones registradas para este equipo.',
                style: TextStyle(color: Colors.black54),
              )
            else
              ...historial.map((item) {
                final h = _mapa(item);

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _texto(h['fecha_medicion']),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _DatoTecnicoMini(
                              label: 'Presión',
                              value: '${_texto(h['presion_refrigerante'])} PSI',
                            ),
                          ),
                          Expanded(
                            child: _DatoTecnicoMini(
                              label: 'Amperaje',
                              value: '${_texto(h['amperaje_compresor'])} A',
                            ),
                          ),
                        ],
                      ),
                      if (_texto(h['observacion_tecnica']).trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Obs.: ${_texto(h['observacion_tecnica'])}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                      if (_texto(h['recomendacion_correctiva']).trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Reco.: ${_texto(h['recomendacion_correctiva'])}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _DatoTecnicoMini extends StatelessWidget {
  final String label;
  final String value;

  const _DatoTecnicoMini({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final texto = value.trim().isEmpty || value.contains('null') ? 'Sin dato' : value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texto,
          style: const TextStyle(
            color: Color(0xFFF97316),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}