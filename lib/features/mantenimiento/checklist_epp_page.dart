import 'package:flutter/material.dart';

import '../../core/services/seguridad_service.dart';
import '../../data/models/epp_checklist_model.dart';
import 'package:flutter/foundation.dart';

class ChecklistEppPage extends StatefulWidget {
  final int ejecucionId;
  final String usuarioRegistro;

  const ChecklistEppPage({
    super.key,
    required this.ejecucionId,
    required this.usuarioRegistro,
  });

  @override
  State<ChecklistEppPage> createState() => _ChecklistEppPageState();
}

class _ChecklistEppPageState extends State<ChecklistEppPage> {
  final SeguridadService _seguridadService = SeguridadService();
  final TextEditingController _observacionController = TextEditingController();

  bool _casco = false;
  bool _lentes = false;
  bool _guantesTrabajo = false;
  bool _guantesDielectricos = false;
  bool _zapatosSeguridad = false;
  bool _mascarilla = false;
  bool _arnes = false;
  bool _proteccionAuditiva = false;
  bool _ropaMangaLarga = false;

  bool _guardando = false;

  bool get _eppBasicoCompleto {
    return _casco &&
        _lentes &&
        _guantesTrabajo &&
        _zapatosSeguridad &&
        _ropaMangaLarga;
  }

  @override
  void initState() {
    super.initState();
    _cargarChecklistGuardado();
  }

  @override
  void dispose() {
    _observacionController.dispose();
    super.dispose();
  }

  Future<void> _cargarChecklistGuardado() async {
    try {
      final resp = await _seguridadService.listarEppChecklist(
        ejecucionId: widget.ejecucionId,
      );

      if (!mounted) return;

      if (resp['success'] != true || resp['data'] == null) {
        return;
      }

      final data = Map<String, dynamic>.from(resp['data']);

      setState(() {
        _casco =
            int.tryParse(data['casco']?.toString() ?? '0') == 1;

        _lentes =
            int.tryParse(data['lentes']?.toString() ?? '0') == 1;

        _guantesTrabajo =
            int.tryParse(data['guantes_trabajo']?.toString() ?? '0') == 1;

        _guantesDielectricos =
            int.tryParse(data['guantes_dielectricos']?.toString() ?? '0') == 1;

        _zapatosSeguridad =
            int.tryParse(data['zapatos_seguridad']?.toString() ?? '0') == 1;

        _mascarilla =
            int.tryParse(data['mascarilla']?.toString() ?? '0') == 1;

        _arnes =
            int.tryParse(data['arnes']?.toString() ?? '0') == 1;

        _proteccionAuditiva =
            int.tryParse(data['proteccion_auditiva']?.toString() ?? '0') == 1;

        _ropaMangaLarga =
            int.tryParse(data['ropa_manga_larga']?.toString() ?? '0') == 1;

        _observacionController.text =
            data['observacion']?.toString() ?? '';
      });
    } catch (e) {
      debugPrint('Error cargando EPP guardado: $e');
    }
  }

  Future<void> _guardarChecklist() async {
    if (!_eppBasicoCompleto) {
      _mostrarMensaje(
        'Debe completar el EPP básico: casco, lentes, guantes, zapatos y ropa de manga larga.',
        esError: true,
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    final data = EppChecklistModel(
      ejecucionId: widget.ejecucionId,
      casco: _casco,
      lentes: _lentes,
      guantesTrabajo: _guantesTrabajo,
      guantesDielectricos: _guantesDielectricos,
      zapatosSeguridad: _zapatosSeguridad,
      mascarilla: _mascarilla,
      arnes: _arnes,
      proteccionAuditiva: _proteccionAuditiva,
      ropaMangaLarga: _ropaMangaLarga,
      observacion: _observacionController.text.trim(),
      usuarioRegistro: widget.usuarioRegistro,
    );

    final resp = await _seguridadService.guardarEppChecklist(data);

    if (!mounted) return;

    setState(() {
      _guardando = false;
    });

    final success = resp['success'] == true;

    _mostrarMensaje(
      resp['message']?.toString() ??
          (success ? 'Checklist EPP guardado.' : 'No se pudo guardar.'),
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

  Widget _checkItem({
    required String titulo,
    required String subtitulo,
    required bool valor,
    required ValueChanged<bool?> onChanged,
    required IconData icono,
    bool obligatorio = false,
  }) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: CheckboxListTile(
        value: valor,
        onChanged: _guardando ? null : onChanged,
        activeColor: const Color(0xFFF97316),
        controlAffinity: ListTileControlAffinity.leading,
        title: Row(
          children: [
            Icon(icono, size: 21, color: const Color(0xFF1F2937)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                obligatorio ? '$titulo *' : titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitulo,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _estadoCard() {
    if (_eppBasicoCompleto) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.verified_rounded, color: Colors.green.shade700),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'EPP básico completo. Puede guardar el checklist.',
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade800),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Complete los EPP obligatorios antes de continuar.',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const colorPrincipal = Color(0xFFF97316);
    const colorOscuro = Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Checklist EPP'),
        backgroundColor: colorOscuro,
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
                    Color(0xFF1F2937),
                    Color(0xFF374151),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.construction,
                      color: colorPrincipal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ejecución N° ${widget.ejecucionId}\nValidación de equipos de protección personal',
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

            _estadoCard(),

            const SizedBox(height: 18),

            const Text(
              'EPP obligatorio',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Color(0xFF263238),
              ),
            ),

            const SizedBox(height: 8),

            _checkItem(
              titulo: 'Casco de seguridad',
              subtitulo: 'Protección contra golpes o caída de objetos.',
              valor: _casco,
              obligatorio: true,
              icono: Icons.sports_motorsports_outlined,
              onChanged: (v) => setState(() => _casco = v ?? false),
            ),
            _checkItem(
              titulo: 'Lentes de protección',
              subtitulo: 'Protección ocular ante polvo, partículas o salpicaduras.',
              valor: _lentes,
              obligatorio: true,
              icono: Icons.visibility_outlined,
              onChanged: (v) => setState(() => _lentes = v ?? false),
            ),
            _checkItem(
              titulo: 'Guantes de trabajo',
              subtitulo: 'Protección para manipulación de herramientas y componentes.',
              valor: _guantesTrabajo,
              obligatorio: true,
              icono: Icons.pan_tool_alt_outlined,
              onChanged: (v) =>
                  setState(() => _guantesTrabajo = v ?? false),
            ),
            _checkItem(
              titulo: 'Zapatos de seguridad',
              subtitulo: 'Protección frente a golpes, caídas y superficies inseguras.',
              valor: _zapatosSeguridad,
              obligatorio: true,
              icono: Icons.hiking_outlined,
              onChanged: (v) =>
                  setState(() => _zapatosSeguridad = v ?? false),
            ),
            _checkItem(
              titulo: 'Ropa de manga larga',
              subtitulo: 'Protección corporal durante la intervención.',
              valor: _ropaMangaLarga,
              obligatorio: true,
              icono: Icons.checkroom_outlined,
              onChanged: (v) =>
                  setState(() => _ropaMangaLarga = v ?? false),
            ),

            const SizedBox(height: 18),

            const Text(
              'EPP según actividad',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Color(0xFF263238),
              ),
            ),

            const SizedBox(height: 8),

            _checkItem(
              titulo: 'Guantes dieléctricos',
              subtitulo: 'Obligatorio si hay intervención eléctrica o verificación de tensión.',
              valor: _guantesDielectricos,
              icono: Icons.electrical_services_outlined,
              onChanged: (v) =>
                  setState(() => _guantesDielectricos = v ?? false),
            ),
            _checkItem(
              titulo: 'Mascarilla',
              subtitulo: 'Necesaria durante limpieza con polvo, químicos o partículas.',
              valor: _mascarilla,
              icono: Icons.masks_outlined,
              onChanged: (v) => setState(() => _mascarilla = v ?? false),
            ),
            _checkItem(
              titulo: 'Arnés',
              subtitulo: 'Aplica cuando exista trabajo en altura.',
              valor: _arnes,
              icono: Icons.health_and_safety_outlined,
              onChanged: (v) => setState(() => _arnes = v ?? false),
            ),
            _checkItem(
              titulo: 'Protección auditiva',
              subtitulo: 'Aplica si el entorno o equipo genera ruido elevado.',
              valor: _proteccionAuditiva,
              icono: Icons.hearing_outlined,
              onChanged: (v) =>
                  setState(() => _proteccionAuditiva = v ?? false),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: _observacionController,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Observación',
                hintText: 'Ingrese observaciones sobre el EPP utilizado...',
                filled: true,
                fillColor: Colors.white,
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _guardando ? null : _guardarChecklist,
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
                  _guardando ? 'Guardando...' : 'Guardar Checklist EPP',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrincipal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}