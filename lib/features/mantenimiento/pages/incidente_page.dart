import 'package:flutter/material.dart';

import '../../../core/services/seguridad_service.dart';
import '../../../data/models/incidente_model.dart';

class IncidentePage extends StatefulWidget {
  final int ejecucionId;
  final String usuarioRegistro;

  const IncidentePage({
    super.key,
    required this.ejecucionId,
    required this.usuarioRegistro,
  });

  @override
  State<IncidentePage> createState() => _IncidentePageState();
}

class _IncidentePageState extends State<IncidentePage> {
  final SeguridadService _seguridadService = SeguridadService();

  final TextEditingController _descripcionCtrl = TextEditingController();
  final TextEditingController _accionCtrl = TextEditingController();
  final TextEditingController _reportadoCtrl = TextEditingController();

  String _tipoIncidente = 'FUGA_REFRIGERANTE';
  bool _actividadSuspendida = true;
  bool _guardando = false;

  final List<Map<String, String>> _tipos = const [
    {
      'valor': 'FUGA_REFRIGERANTE',
      'texto': 'Fuga de refrigerante',
    },
    {
      'valor': 'CORTOCIRCUITO',
      'texto': 'Cortocircuito',
    },
    {
      'valor': 'SOBRECALENTAMIENTO',
      'texto': 'Sobrecalentamiento',
    },
    {
      'valor': 'DANO_ESTRUCTURAL',
      'texto': 'Daño estructural',
    },
    {
      'valor': 'RIESGO_ELECTRICO',
      'texto': 'Riesgo eléctrico',
    },
    {
      'valor': 'CAIDA',
      'texto': 'Caída',
    },
    {
      'valor': 'GOLPE',
      'texto': 'Golpe',
    },
    {
      'valor': 'OTRO',
      'texto': 'Otro',
    },
  ];

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    _accionCtrl.dispose();
    _reportadoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarIncidente() async {
    if (_descripcionCtrl.text.trim().isEmpty) {
      _mostrarMensaje(
        'Ingrese la descripción del incidente.',
        esError: true,
      );
      return;
    }

    if (_reportadoCtrl.text.trim().isEmpty) {
      _mostrarMensaje(
        'Ingrese a quién fue reportado el incidente.',
        esError: true,
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    final data = IncidenteModel(
      ejecucionId: widget.ejecucionId,
      tipoIncidente: _tipoIncidente,
      descripcion: _descripcionCtrl.text.trim(),
      accionTomada: _accionCtrl.text.trim(),
      actividadSuspendida: _actividadSuspendida,
      reportadoA: _reportadoCtrl.text.trim(),
      foto: '',
      usuarioRegistro: widget.usuarioRegistro,
    );

    final resp = await _seguridadService.guardarIncidente(data);

    if (!mounted) return;

    setState(() {
      _guardando = false;
    });

    final success = resp['success'] == true;

    _mostrarMensaje(
      resp['message']?.toString() ??
          (success ? 'Incidente registrado.' : 'No se pudo registrar.'),
      esError: !success,
    );

    if (success) {
      Navigator.pop(context, true);
    }
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const colorOscuro = Color(0xFF1F2937);
    const colorRojo = Color(0xFFDC2626);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Registrar incidente'),
        backgroundColor: colorRojo,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF991B1B),
                    Color(0xFFDC2626),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.report_problem,
                      color: colorRojo,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ejecución N° ${widget.ejecucionId}\nReporte de condición insegura o incidente',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _tipoIncidente,
                      decoration: InputDecoration(
                        labelText: 'Tipo de incidente',
                        prefixIcon: const Icon(Icons.warning_amber_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      items: _tipos.map((item) {
                        return DropdownMenuItem<String>(
                          value: item['valor'],
                          child: Text(item['texto'] ?? ''),
                        );
                      }).toList(),
                      onChanged: _guardando
                          ? null
                          : (value) {
                              setState(() {
                                _tipoIncidente = value ?? 'OTRO';
                              });
                            },
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: _descripcionCtrl,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Descripción del incidente',
                        hintText: 'Detalle lo ocurrido o la condición detectada...',
                        alignLabelWithHint: true,
                        prefixIcon: const Icon(Icons.notes_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: _accionCtrl,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Acción tomada',
                        hintText: 'Ejemplo: Se suspendió la actividad y se notificó al responsable.',
                        alignLabelWithHint: true,
                        prefixIcon: const Icon(Icons.task_alt_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: _reportadoCtrl,
                      decoration: InputDecoration(
                        labelText: 'Reportado a',
                        hintText: 'Ejemplo: Supervisor / SSOMA / Responsable del área',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    SwitchListTile(
                      value: _actividadSuspendida,
                      activeColor: colorRojo,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Actividad suspendida',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Debe marcarse cuando existe riesgo o condición insegura.',
                      ),
                      onChanged: _guardando
                          ? null
                          : (value) {
                              setState(() {
                                _actividadSuspendida = value;
                              });
                            },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.red.shade700),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Ante fuga, cortocircuito, sobrecalentamiento, daño estructural o riesgo eléctrico, se debe suspender la intervención y reportar al área correspondiente.',
                      style: TextStyle(
                        color: colorOscuro,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _guardando ? null : _guardarIncidente,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _guardando ? 'Guardando...' : 'Guardar incidente',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorRojo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}