import 'package:flutter/material.dart';

import '../../../core/services/seguridad_service.dart';
import '../../../data/models/pets_checklist_model.dart';
import 'package:flutter/foundation.dart';

class ChecklistPetsPage extends StatefulWidget {
  final int ejecucionId;
  final String usuarioRegistro;

  const ChecklistPetsPage({
    super.key,
    required this.ejecucionId,
    required this.usuarioRegistro,
  });

  @override
  State<ChecklistPetsPage> createState() => _ChecklistPetsPageState();
}

class _ChecklistPetsPageState extends State<ChecklistPetsPage> {
  final SeguridadService _seguridadService = SeguridadService();
  final TextEditingController _observacionController = TextEditingController();

  bool _coordinacionArea = false;
  bool _ipercRevisado = false;
  bool _zonaDelimitada = false;
  bool _accesoRestringido = false;
  bool _herramientasVerificadas = false;
  bool _permisoTrabajo = false;

  bool _lotoAplicado = false;
  bool _ausenciaTensionVerificada = false;
  bool _personalAutorizado = false;

  bool _condicionInsegura = false;
  bool _actividadSuspendida = false;

  bool _guardando = false;

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

  bool get _controlesBasicosCompletos {
    return _coordinacionArea &&
        _ipercRevisado &&
        _zonaDelimitada &&
        _accesoRestringido &&
        _herramientasVerificadas &&
        _personalAutorizado;
  }

  Future<void> _cargarChecklistGuardado() async {
    try {
      final resp = await _seguridadService.listarPetsChecklist(
        ejecucionId: widget.ejecucionId,
      );

      if (!mounted) return;

      if (resp['success'] != true || resp['data'] == null) {
        return;
      }

      final data = Map<String, dynamic>.from(resp['data']);

      setState(() {
        _coordinacionArea =
            int.tryParse(data['coordinacion_area'].toString()) == 1;

        _ipercRevisado =
            int.tryParse(data['iperc_revisado'].toString()) == 1;

        _zonaDelimitada =
            int.tryParse(data['zona_delimitada'].toString()) == 1;

        _accesoRestringido =
            int.tryParse(data['acceso_restringido'].toString()) == 1;

        _herramientasVerificadas =
            int.tryParse(data['herramientas_verificadas'].toString()) == 1;

        _permisoTrabajo =
            int.tryParse(data['permiso_trabajo'].toString()) == 1;

        _lotoAplicado =
            int.tryParse(data['loto_aplicado'].toString()) == 1;

        _ausenciaTensionVerificada =
            int.tryParse(data['ausencia_tension_verificada'].toString()) == 1;

        _personalAutorizado =
            int.tryParse(data['personal_autorizado'].toString()) == 1;

        _condicionInsegura =
            int.tryParse(data['condicion_insegura'].toString()) == 1;

        _actividadSuspendida =
            int.tryParse(data['actividad_suspendida'].toString()) == 1;

        _observacionController.text = data['observacion']?.toString() ?? '';
      });
    } catch (e) {
      debugPrint('Error cargando PETS guardado: $e');
    }
  }

  Future<void> _guardarChecklist() async {
    if (!_controlesBasicosCompletos) {
      _mostrarMensaje(
        'Debe completar los controles básicos antes de guardar.',
        esError: true,
      );
      return;
    }

    if (_condicionInsegura && !_actividadSuspendida) {
      _mostrarMensaje(
        'Si existe condición insegura, debe marcar la actividad como suspendida.',
        esError: true,
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    final data = PetsChecklistModel(
      ejecucionId: widget.ejecucionId,
      coordinacionArea: _coordinacionArea,
      ipercRevisado: _ipercRevisado,
      zonaDelimitada: _zonaDelimitada,
      accesoRestringido: _accesoRestringido,
      herramientasVerificadas: _herramientasVerificadas,
      permisoTrabajo: _permisoTrabajo,
      lotoAplicado: _lotoAplicado,
      ausenciaTensionVerificada: _ausenciaTensionVerificada,
      personalAutorizado: _personalAutorizado,
      condicionInsegura: _condicionInsegura,
      actividadSuspendida: _actividadSuspendida,
      observacion: _observacionController.text.trim(),
      usuarioRegistro: widget.usuarioRegistro,
    );

    final resp = await _seguridadService.guardarPetsChecklist(data);

    if (!mounted) return;

    setState(() {
      _guardando = false;
    });

    final success = resp['success'] == true;

    _mostrarMensaje(
      resp['message']?.toString() ??
          (success ? 'Checklist guardado.' : 'No se pudo guardar.'),
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

  Widget _seccionTitulo(String titulo, IconData icono) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Row(
        children: [
          Icon(icono, color: const Color(0xFFF57C00)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263238),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkItem({
    required String titulo,
    required String subtitulo,
    required bool valor,
    required ValueChanged<bool?> onChanged,
    IconData icono = Icons.check_circle_outline,
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
        activeColor: const Color(0xFFF57C00),
        controlAffinity: ListTileControlAffinity.leading,
        title: Row(
          children: [
            Icon(icono, size: 20, color: const Color(0xFF024F8C)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                titulo,
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

  Widget _alertaEstado() {
    if (_condicionInsegura) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Se marcó condición insegura. La actividad debe suspenderse y reportarse antes de continuar.',
                style: TextStyle(
                  color: Colors.red.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_controlesBasicosCompletos) {
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
                'Controles básicos completados. Puede guardar el checklist PETS.',
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
              'Complete los controles básicos antes de iniciar o cerrar la intervención.',
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
    const colorPrincipal = Color(0xFFF57C00);
    const colorAzul = Color(0xFF024F8C);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Checklist PETS'),
        backgroundColor: colorAzul,
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
                    Color(0xFF024F8C),
                    Color(0xFF0277BD),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.health_and_safety,
                      color: colorPrincipal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ejecución N° ${widget.ejecucionId}\nValidación de trabajo seguro',
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

            _alertaEstado(),

            _seccionTitulo('Controles previos obligatorios', Icons.fact_check),

            _checkItem(
              titulo: 'Coordinación con el área',
              subtitulo: 'Se coordinó con el responsable del área intervenida.',
              valor: _coordinacionArea,
              onChanged: (v) => setState(() => _coordinacionArea = v ?? false),
              icono: Icons.groups,
            ),
            _checkItem(
              titulo: 'IPERC revisado',
              subtitulo: 'Se revisaron riesgos y controles antes de iniciar.',
              valor: _ipercRevisado,
              onChanged: (v) => setState(() => _ipercRevisado = v ?? false),
              icono: Icons.assignment_turned_in,
            ),
            _checkItem(
              titulo: 'Zona delimitada',
              subtitulo: 'El área fue señalizada y delimitada correctamente.',
              valor: _zonaDelimitada,
              onChanged: (v) => setState(() => _zonaDelimitada = v ?? false),
              icono: Icons.warning_amber,
            ),
            _checkItem(
              titulo: 'Acceso restringido',
              subtitulo: 'Se restringió el acceso a personal no autorizado.',
              valor: _accesoRestringido,
              onChanged: (v) => setState(() => _accesoRestringido = v ?? false),
              icono: Icons.no_accounts,
            ),
            _checkItem(
              titulo: 'Herramientas verificadas',
              subtitulo: 'Herramientas en buen estado y adecuadas para la tarea.',
              valor: _herramientasVerificadas,
              onChanged: (v) =>
                  setState(() => _herramientasVerificadas = v ?? false),
              icono: Icons.handyman,
            ),
            _checkItem(
              titulo: 'Permiso de trabajo',
              subtitulo: 'Se cuenta con autorización o permiso si aplica.',
              valor: _permisoTrabajo,
              onChanged: (v) => setState(() => _permisoTrabajo = v ?? false),
              icono: Icons.description,
            ),

            _seccionTitulo('Controles eléctricos / LOTO', Icons.electric_bolt),

            _checkItem(
              titulo: 'LOTO aplicado',
              subtitulo: 'Se aplicó bloqueo y etiquetado cuando corresponde.',
              valor: _lotoAplicado,
              onChanged: (v) => setState(() => _lotoAplicado = v ?? false),
              icono: Icons.lock,
            ),
            _checkItem(
              titulo: 'Ausencia de tensión verificada',
              subtitulo: 'Se verificó con instrumento adecuado antes de intervenir.',
              valor: _ausenciaTensionVerificada,
              onChanged: (v) =>
                  setState(() => _ausenciaTensionVerificada = v ?? false),
              icono: Icons.electrical_services,
            ),
            _checkItem(
              titulo: 'Personal autorizado',
              subtitulo: 'La tarea es ejecutada por personal competente/autorizado.',
              valor: _personalAutorizado,
              onChanged: (v) => setState(() => _personalAutorizado = v ?? false),
              icono: Icons.verified_user,
            ),

            _seccionTitulo('Condiciones inseguras', Icons.report_problem),

            _checkItem(
              titulo: 'Existe condición insegura',
              subtitulo: 'Fuga, cortocircuito, sobrecalentamiento, daño estructural u otro riesgo.',
              valor: _condicionInsegura,
              onChanged: (v) {
                setState(() {
                  _condicionInsegura = v ?? false;
                  if (_condicionInsegura) {
                    _actividadSuspendida = true;
                  }
                });
              },
              icono: Icons.dangerous,
            ),
            _checkItem(
              titulo: 'Actividad suspendida',
              subtitulo: 'Se suspende la intervención hasta controlar el riesgo.',
              valor: _actividadSuspendida,
              onChanged: (v) =>
                  setState(() => _actividadSuspendida = v ?? false),
              icono: Icons.pause_circle,
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _observacionController,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Observación',
                hintText: 'Ingrese observaciones del checklist PETS...',
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
                  _guardando ? 'Guardando...' : 'Guardar Checklist PETS',
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