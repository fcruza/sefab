import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import '../../core/services/instalacion_service.dart';
import '../../data/models/instalacion_model.dart';

class RegistrarInstalacionPage extends StatefulWidget {
  const RegistrarInstalacionPage({super.key});

  @override
  State<RegistrarInstalacionPage> createState() =>
      _RegistrarInstalacionPageState();
}

class _RegistrarInstalacionPageState extends State<RegistrarInstalacionPage> {
  final InstalacionService _instalacionService = InstalacionService();

  final ImagePicker _picker = ImagePicker();

  final List<XFile> fotosAntes = [];
  final List<XFile> fotosDurante = [];
  final List<XFile> fotosDespues = [];
  final List<XFile> fotosPlaca = [];
  final List<XFile> fotosPrueba = [];

  final codigoCtrl = TextEditingController();
  final marcaCtrl = TextEditingController();
  final modeloCtrl = TextEditingController();
  final serieCtrl = TextEditingController();
  final btuCtrl = TextEditingController();
  final voltajeCtrl = TextEditingController();
  final tipoCtrl = TextEditingController();

  final areaCtrl = TextEditingController();
  final ubicacionCtrl = TextEditingController();

  final fechaCtrl = TextEditingController();
  final horaInicioCtrl = TextEditingController();
  final horaFinCtrl = TextEditingController();

  final responsableTecnicoCtrl = TextEditingController();
  final responsableAreaCtrl = TextEditingController();

  final observacionCtrl = TextEditingController();
  final recomendacionCtrl = TextEditingController();
  final responsableConformidadCtrl = TextEditingController();

  bool pruebaEncendido = false;
  bool pruebaEnfriamiento = false;
  bool drenajeVerificado = false;
  bool conexionesElectricasVerificadas = false;
  bool fijacionEquipoVerificada = false;
  bool tuberiasAisladas = false;
  bool limpiezaArea = false;
  bool conformidadResponsable = false;

  bool guardando = false;

  String estadoResultado = 'CONFORME';

  @override
  void initState() {
    super.initState();
    codigoCtrl.text = 'Automático';

    final hoy = DateTime.now();
    fechaCtrl.text =
        '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';

    responsableTecnicoCtrl.text = 'SEFAB';
  }

  @override
  void dispose() {
    codigoCtrl.dispose();
    marcaCtrl.dispose();
    modeloCtrl.dispose();
    serieCtrl.dispose();
    btuCtrl.dispose();
    voltajeCtrl.dispose();
    tipoCtrl.dispose();
    areaCtrl.dispose();
    ubicacionCtrl.dispose();
    fechaCtrl.dispose();
    horaInicioCtrl.dispose();
    horaFinCtrl.dispose();
    responsableTecnicoCtrl.dispose();
    responsableAreaCtrl.dispose();
    observacionCtrl.dispose();
    recomendacionCtrl.dispose();
    responsableConformidadCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final actual = DateTime.now();

    final fecha = await showDatePicker(
      context: context,
      initialDate: actual,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (fecha == null) return;

    fechaCtrl.text =
        '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
  }

  Future<void> _seleccionarFoto({
    required String tipo,
    required ImageSource source,
  }) async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: source,
        imageQuality: 60,
        maxWidth: 1280,
        maxHeight: 1280,
      );

      if (foto == null) return;

      setState(() {
        switch (tipo) {
          case 'ANTES':
            fotosAntes.add(foto);
            break;
          case 'DURANTE':
            fotosDurante.add(foto);
            break;
          case 'DESPUES':
            fotosDespues.add(foto);
            break;
          case 'PLACA_EQUIPO':
            fotosPlaca.add(foto);
            break;
          case 'PRUEBA_FUNCIONAMIENTO':
            fotosPrueba.add(foto);
            break;
        }
      });
    } catch (e) {
      _mensaje('No se pudo seleccionar la foto: $e', error: true);
    }
  }

  void _mostrarOpcionesFoto(String tipo) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarFoto(
                    tipo: tipo,
                    source: ImageSource.camera,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Seleccionar de galería'),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarFoto(
                    tipo: tipo,
                    source: ImageSource.gallery,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _seleccionarHora(TextEditingController controller) async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora == null) return;

    controller.text =
        '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}:00';
  }

  bool get pruebasCompletas {
    return pruebaEncendido &&
        pruebaEnfriamiento &&
        drenajeVerificado &&
        conexionesElectricasVerificadas &&
        fijacionEquipoVerificada &&
        tuberiasAisladas &&
        limpiezaArea;
  }

  Future<void> _subirTodasLasEvidencias(int instalacionId) async {
    Future<void> subirGrupo({
      required List<XFile> fotos,
      required String tipo,
      required String observacion,
    }) async {
      for (int i = 0; i < fotos.length; i++) {
        final resp = await _instalacionService.subirEvidenciaInstalacion(
          instalacionId: instalacionId,
          foto: fotos[i],
          tipoEvidencia: tipo,
          observacion: '$observacion ${i + 1}',
        );

        if (resp['success'] != true) {
          debugPrint(
            'Error subiendo $tipo: ${resp['message'] ?? 'Error desconocido'}',
          );
        }
      }
    }

    await subirGrupo(
      fotos: fotosAntes,
      tipo: 'ANTES',
      observacion: 'Foto antes de la instalación',
    );

    await subirGrupo(
      fotos: fotosDurante,
      tipo: 'DURANTE',
      observacion: 'Foto durante la instalación',
    );

    await subirGrupo(
      fotos: fotosDespues,
      tipo: 'DESPUES',
      observacion: 'Foto después de la instalación',
    );

    await subirGrupo(
      fotos: fotosPlaca,
      tipo: 'PLACA_EQUIPO',
      observacion: 'Foto de placa del equipo',
    );

    await subirGrupo(
      fotos: fotosPrueba,
      tipo: 'PRUEBA_FUNCIONAMIENTO',
      observacion: 'Prueba de funcionamiento',
    );
  }

  Future<void> _guardarInstalacion() async {

    if (marcaCtrl.text.trim().isEmpty) {
      _mensaje('Ingrese la marca del equipo.', error: true);
      return;
    }

    if (areaCtrl.text.trim().isEmpty) {
      _mensaje('Ingrese el área de instalación.', error: true);
      return;
    }

    if (ubicacionCtrl.text.trim().isEmpty) {
      _mensaje('Ingrese la ubicación exacta.', error: true);
      return;
    }

    if (fechaCtrl.text.trim().isEmpty) {
      _mensaje('Seleccione la fecha de instalación.', error: true);
      return;
    }

    if (!pruebasCompletas) {
      final continuar = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Pruebas incompletas'),
          content: const Text(
            'No todas las pruebas de instalación están marcadas. La instalación será registrada como OBSERVADA. ¿Desea continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continuar'),
            ),
          ],
        ),
      );

      if (continuar != true) return;
      estadoResultado = 'OBSERVADO';
    }

    if (conformidadResponsable &&
        responsableConformidadCtrl.text.trim().isEmpty) {
      _mensaje(
        'Ingrese el nombre del responsable que da conformidad.',
        error: true,
      );
      return;
    }

    setState(() {
      guardando = true;
    });

    final instalacion = InstalacionModel(
      id: 0,
      aireId: 0,
      mantenimientoId: 0,
      codigoEquipo: codigoCtrl.text.trim(),
      marca: marcaCtrl.text.trim(),
      modelo: modeloCtrl.text.trim(),
      numeroSerie: serieCtrl.text.trim(),
      capacidadBtu: btuCtrl.text.trim(),
      voltaje: voltajeCtrl.text.trim(),
      tipoEquipo: tipoCtrl.text.trim(),
      area: areaCtrl.text.trim(),
      ubicacion: ubicacionCtrl.text.trim(),
      fechaInstalacion: fechaCtrl.text.trim(),
      horaInicio: horaInicioCtrl.text.trim(),
      horaFin: horaFinCtrl.text.trim(),
      responsableTecnico: responsableTecnicoCtrl.text.trim(),
      responsableArea: responsableAreaCtrl.text.trim(),
      pruebaEncendido: pruebaEncendido,
      pruebaEnfriamiento: pruebaEnfriamiento,
      drenajeVerificado: drenajeVerificado,
      conexionesElectricasVerificadas: conexionesElectricasVerificadas,
      fijacionEquipoVerificada: fijacionEquipoVerificada,
      tuberiasAisladas: tuberiasAisladas,
      limpiezaArea: limpiezaArea,
      estadoResultado: pruebasCompletas ? 'CONFORME' : estadoResultado,
      observacionTecnica: observacionCtrl.text.trim(),
      recomendacion: recomendacionCtrl.text.trim(),
      conformidadResponsable: conformidadResponsable,
      nombreResponsableConformidad: responsableConformidadCtrl.text.trim(),
      usuarioRegistro: 'admin',
      fechaRegistro: '',
    );

    final resp = await _instalacionService.guardarInstalacion(instalacion);

    if (!mounted) return;

    setState(() {
      guardando = false;
    });

    final success = resp['success'] == true;

    if (success) {
      final data = resp['data'];

      final instalacionId = data is Map
          ? int.tryParse(data['id']?.toString() ?? '0') ?? 0
          : 0;

      if (instalacionId > 0) {
        await _subirTodasLasEvidencias(instalacionId);
      }
    }

    _mensaje(
      resp['message']?.toString() ??
          (success
              ? 'Instalación registrada correctamente.'
              : 'No se pudo registrar la instalación.'),
      error: !success,
    );

    if (success) {
      Navigator.pop(context, true);
    }
  }

  void _mensaje(String texto, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _titulo(String texto, IconData icono) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Row(
        children: [
          Icon(icono, color: const Color(0xFFF97316)),
          const SizedBox(width: 8),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _check({
    required String titulo,
    required bool valor,
    required ValueChanged<bool?> onChanged,
    IconData icono = Icons.check_circle_outline,
  }) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: CheckboxListTile(
        value: valor,
        onChanged: guardando ? null : onChanged,
        activeColor: const Color(0xFFF97316),
        controlAffinity: ListTileControlAffinity.leading,
        title: Row(
          children: [
            Icon(icono, color: const Color(0xFF1F2937), size: 21),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _estadoPruebas() {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: pruebasCompletas ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              pruebasCompletas ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            pruebasCompletas
                ? Icons.verified_outlined
                : Icons.info_outline,
            color:
                pruebasCompletas ? Colors.green.shade700 : Colors.orange.shade800,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              pruebasCompletas
                  ? 'Pruebas de instalación completas. La instalación quedará CONFORME.'
                  : 'Complete todas las pruebas para registrar la instalación como CONFORME.',
              style: TextStyle(
                color: pruebasCompletas
                    ? Colors.green.shade800
                    : Colors.orange.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _evidenciaCard({
    required String titulo,
    required String tipo,
    required List<XFile> fotos,
    required IconData icono,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, color: const Color(0xFFF97316)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: guardando ? null : () => _mostrarOpcionesFoto(tipo),
                  icon: const Icon(Icons.add_a_photo_outlined),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (fotos.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Sin fotos agregadas',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              SizedBox(
                height: 82,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: fotos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final foto = fotos[index];

                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(foto.path),
                            width: 82,
                            height: 82,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 3,
                          right: 3,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                fotos.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const colorPrincipal = Color(0xFF1F2937);
    const colorNaranja = Color(0xFFF97316);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Registrar instalación'),
        backgroundColor: colorPrincipal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).padding.bottom + 100,
        ),
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
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.ac_unit,
                    color: colorNaranja,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Registro técnico de instalación de aire acondicionado',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          _titulo('Datos del equipo', Icons.ac_unit),
          _campo(
            controller: codigoCtrl,
            label: 'Código del equipo',
            icon: Icons.qr_code,
            readOnly: true,
          ),
          _campo(
            controller: marcaCtrl,
            label: 'Marca',
            icon: Icons.label_outline,
          ),
          _campo(
            controller: modeloCtrl,
            label: 'Modelo',
            icon: Icons.memory_outlined,
          ),
          _campo(
            controller: serieCtrl,
            label: 'Número de serie',
            icon: Icons.confirmation_number_outlined,
          ),
          Row(
            children: [
              Expanded(
                child: _campo(
                  controller: btuCtrl,
                  label: 'Capacidad BTU',
                  icon: Icons.speed_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _campo(
                  controller: voltajeCtrl,
                  label: 'Voltaje',
                  icon: Icons.bolt_outlined,
                ),
              ),
            ],
          ),
          _campo(
            controller: tipoCtrl,
            label: 'Tipo de equipo',
            icon: Icons.category_outlined,
          ),

          _titulo('Ubicación', Icons.location_on_outlined),
          _campo(
            controller: areaCtrl,
            label: 'Área',
            icon: Icons.business,
          ),
          _campo(
            controller: ubicacionCtrl,
            label: 'Ubicación exacta',
            icon: Icons.place_outlined,
          ),

          _titulo('Fecha y responsables', Icons.event_available),
          _campo(
            controller: fechaCtrl,
            label: 'Fecha de instalación',
            icon: Icons.event,
            readOnly: true,
            onTap: _seleccionarFecha,
          ),
          Row(
            children: [
              Expanded(
                child: _campo(
                  controller: horaInicioCtrl,
                  label: 'Hora inicio',
                  icon: Icons.access_time,
                  readOnly: true,
                  onTap: () => _seleccionarHora(horaInicioCtrl),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _campo(
                  controller: horaFinCtrl,
                  label: 'Hora fin',
                  icon: Icons.access_time_filled,
                  readOnly: true,
                  onTap: () => _seleccionarHora(horaFinCtrl),
                ),
              ),
            ],
          ),
          _campo(
            controller: responsableTecnicoCtrl,
            label: 'Responsable técnico',
            icon: Icons.engineering_outlined,
          ),
          _campo(
            controller: responsableAreaCtrl,
            label: 'Responsable del área',
            icon: Icons.person_outline,
          ),

          _titulo('Pruebas de funcionamiento', Icons.fact_check_outlined),
          _estadoPruebas(),
          _check(
            titulo: 'Prueba de encendido',
            valor: pruebaEncendido,
            icono: Icons.power_settings_new,
            onChanged: (v) => setState(() => pruebaEncendido = v ?? false),
          ),
          _check(
            titulo: 'Prueba de enfriamiento',
            valor: pruebaEnfriamiento,
            icono: Icons.ac_unit,
            onChanged: (v) => setState(() => pruebaEnfriamiento = v ?? false),
          ),
          _check(
            titulo: 'Drenaje verificado',
            valor: drenajeVerificado,
            icono: Icons.water_drop_outlined,
            onChanged: (v) => setState(() => drenajeVerificado = v ?? false),
          ),
          _check(
            titulo: 'Conexiones eléctricas verificadas',
            valor: conexionesElectricasVerificadas,
            icono: Icons.electrical_services_outlined,
            onChanged: (v) => setState(
              () => conexionesElectricasVerificadas = v ?? false,
            ),
          ),
          _check(
            titulo: 'Fijación del equipo verificada',
            valor: fijacionEquipoVerificada,
            icono: Icons.handyman_outlined,
            onChanged: (v) => setState(
              () => fijacionEquipoVerificada = v ?? false,
            ),
          ),
          _check(
            titulo: 'Tuberías aisladas',
            valor: tuberiasAisladas,
            icono: Icons.settings_input_component_outlined,
            onChanged: (v) => setState(() => tuberiasAisladas = v ?? false),
          ),
          _check(
            titulo: 'Limpieza final del área',
            valor: limpiezaArea,
            icono: Icons.cleaning_services_outlined,
            onChanged: (v) => setState(() => limpiezaArea = v ?? false),
          ),

          _titulo('Evidencias fotográficas', Icons.photo_camera_outlined),
          _evidenciaCard(
            titulo: 'Antes de la instalación',
            tipo: 'ANTES',
            fotos: fotosAntes,
            icono: Icons.photo_camera_outlined,
          ),
          _evidenciaCard(
            titulo: 'Durante la instalación',
            tipo: 'DURANTE',
            fotos: fotosDurante,
            icono: Icons.construction_outlined,
          ),
          _evidenciaCard(
            titulo: 'Después de la instalación',
            tipo: 'DESPUES',
            fotos: fotosDespues,
            icono: Icons.verified_outlined,
          ),
          _evidenciaCard(
            titulo: 'Placa del equipo',
            tipo: 'PLACA_EQUIPO',
            fotos: fotosPlaca,
            icono: Icons.confirmation_number_outlined,
          ),
          _evidenciaCard(
            titulo: 'Prueba de funcionamiento',
            tipo: 'PRUEBA_FUNCIONAMIENTO',
            fotos: fotosPrueba,
            icono: Icons.fact_check_outlined,
          ),

          _titulo('Cierre y conformidad', Icons.assignment_turned_in_outlined),
          _campo(
            controller: observacionCtrl,
            label: 'Observación técnica',
            icon: Icons.notes_outlined,
            maxLines: 3,
          ),
          _campo(
            controller: recomendacionCtrl,
            label: 'Recomendación',
            icon: Icons.tips_and_updates_outlined,
            maxLines: 3,
          ),
          SwitchListTile(
            value: conformidadResponsable,
            activeColor: colorNaranja,
            title: const Text(
              'Conformidad del responsable',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Marcar si el responsable del área valida la instalación.',
            ),
            onChanged: guardando
                ? null
                : (value) {
                    setState(() {
                      conformidadResponsable = value;
                    });
                  },
          ),
          if (conformidadResponsable)
            _campo(
              controller: responsableConformidadCtrl,
              label: 'Nombre del responsable de conformidad',
              icon: Icons.verified_user_outlined,
            ),

          const SizedBox(height: 20),
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: guardando ? null : _guardarInstalacion,
              icon: guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                guardando ? 'Guardando...' : 'Guardar instalación',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorNaranja,
                foregroundColor: Colors.white,
                disabledBackgroundColor: colorNaranja.withOpacity(0.55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}