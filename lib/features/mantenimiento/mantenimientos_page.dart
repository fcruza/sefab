import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/mantenimiento_model.dart';
import 'mantenimiento_service.dart';

import 'pages/checklist_pets_page.dart';
import 'checklist_epp_page.dart';
import 'pages/incidente_page.dart';
import '../../core/services/seguridad_service.dart';

class MantenimientosPage extends StatefulWidget {
  const MantenimientosPage({super.key});

  @override
  State<MantenimientosPage> createState() => _MantenimientosPageState();
}

class _MantenimientosPageState extends State<MantenimientosPage> {
  final MantenimientoService mantenimientoService = MantenimientoService();
  final SeguridadService seguridadService = SeguridadService();
  final Map<int, List<XFile>> evidenciasPorMantenimiento = {};

  int mesSeleccionado = 5;
  int anioSeleccionado = 2026;

  bool cargando = false;
  String? error;

  List<MantenimientoProgramado> mantenimientos = [];

  final List<MesCronograma> meses = const [
    MesCronograma(numero: 1, nombre: 'Enero'),
    MesCronograma(numero: 2, nombre: 'Febrero'),
    MesCronograma(numero: 3, nombre: 'Marzo'),
    MesCronograma(numero: 4, nombre: 'Abril'),
    MesCronograma(numero: 5, nombre: 'Mayo'),
    MesCronograma(numero: 6, nombre: 'Junio'),
    MesCronograma(numero: 7, nombre: 'Julio'),
    MesCronograma(numero: 8, nombre: 'Agosto'),
    MesCronograma(numero: 9, nombre: 'Septiembre'),
    MesCronograma(numero: 10, nombre: 'Octubre'),
    MesCronograma(numero: 11, nombre: 'Noviembre'),
    MesCronograma(numero: 12, nombre: 'Diciembre'),
  ];

  @override
  void initState() {
    super.initState();
    _cargarCronograma();
  }

  Future<void> _cargarCronograma() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final data = await mantenimientoService.listarCronograma(
        mes: mesSeleccionado,
        anio: anioSeleccionado,
      );

      if (!mounted) return;

      setState(() {
        mantenimientos = data;
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

  List<MantenimientoProgramado> get mantenimientosDelMes {
    return mantenimientos.where((m) => m.mes == mesSeleccionado).toList();
  }

  int get totalMes => mantenimientosDelMes.length;

  int get realizadosMes {
    return mantenimientosDelMes.where((m) {
      return m.estado == 'Realizado' || m.estado == 'Observado';
    }).length;
  }

  int get pendientesMes {
    return mantenimientosDelMes.where((m) {
      return m.estado == 'Pendiente' || m.estado == 'En proceso';
    }).length;
  }

  double get porcentajeCumplimiento {
    if (totalMes == 0) return 0;
    return (realizadosMes / totalMes) * 100;
  }

  int _cantidadEvidencias(MantenimientoProgramado mantenimiento) {
    final evidenciasGuardadas = evidenciasPorMantenimiento[mantenimiento.id];

    if (evidenciasGuardadas != null) {
      return evidenciasGuardadas.length;
    }

    return mantenimiento.fotos;
  }

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'realizado':
        return const Color(0xFF16A34A);
      case 'observado':
        return const Color(0xFFF97316);
      case 'en proceso':
        return const Color(0xFF2563EB);
      case 'vencido':
        return const Color(0xFFDC2626);
      case 'pendiente':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _faseIcon(String fase) {
    switch (fase.toLowerCase()) {
      case 'evaporador':
        return Icons.air;
      case 'condensador':
        return Icons.settings_input_component_outlined;
      case 'completo':
        return Icons.build_circle_outlined;
      default:
        return Icons.ac_unit;
    }
  }

  Future<void> _moverMantenimientoMes({
    required MantenimientoProgramado mantenimiento,
    required int mesDestino,
    required int anioDestino,
    required String fechaProgramada,
  }) async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final res = await mantenimientoService.moverMantenimientoMes(
        id: mantenimiento.id,
        mes: mesDestino,
        anio: anioDestino,
        fechaProgramada: fechaProgramada,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res['message']?.toString() ?? 'Mantenimiento movido correctamente.',
          ),
        ),
      );

      setState(() {
        mesSeleccionado = mesDestino;
        anioSeleccionado = anioDestino;
      });

      await _cargarCronograma();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  Future<void> _abrirMoverMes(MantenimientoProgramado mantenimiento) async {
    int mesDestino = mantenimiento.mes;
    int anioDestino = mantenimiento.anio;

    final fechaCtrl = TextEditingController(
      text: mantenimiento.fechaProgramada,
    );

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text('Mover mantenimiento'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${mantenimiento.equipoCodigo} · ${mantenimiento.area}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: mesDestino,
                      decoration: InputDecoration(
                        labelText: 'Mes destino',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      items: meses
                          .map(
                            (m) => DropdownMenuItem(
                              value: m.numero,
                              child: Text(m.nombre),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          mesDestino = value ?? mantenimiento.mes;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      initialValue: anioDestino.toString(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Año destino',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onChanged: (value) {
                        anioDestino = int.tryParse(value) ?? mantenimiento.anio;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: fechaCtrl,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Fecha programada',
                        hintText: 'dd/mm/aaaa',
                        prefixIcon: const Icon(Icons.event),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onTap: () async {
                        final ahora = DateTime.now();

                        final fecha = await showDatePicker(
                          context: context,
                          initialDate: ahora,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );

                        if (fecha == null) return;

                        final dia = fecha.day.toString().padLeft(2, '0');
                        final mes = fecha.month.toString().padLeft(2, '0');
                        final anio = fecha.year.toString();

                        fechaCtrl.text = '$dia/$mes/$anio';

                        setDialogState(() {
                          mesDestino = fecha.month;
                          anioDestino = fecha.year;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.drive_file_move_outline),
                  label: const Text('Mover'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmado != true) {
      fechaCtrl.dispose();
      return;
    }

    final fechaProgramada = fechaCtrl.text.trim();
    fechaCtrl.dispose();

    if (fechaProgramada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione una fecha programada.'),
        ),
      );
      return;
    }

    await _moverMantenimientoMes(
      mantenimiento: mantenimiento,
      mesDestino: mesDestino,
      anioDestino: anioDestino,
      fechaProgramada: fechaProgramada,
    );
  }

  Future<void> _registrarEjecucion(
    MantenimientoProgramado mantenimiento,
  ) async {
    final resultado = await Navigator.push<ResultadoEjecucionMantenimiento>(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrarMantenimientoPage(
          mantenimiento: mantenimiento,
          evidenciasIniciales:
              evidenciasPorMantenimiento[mantenimiento.id] ?? [],
        ),
      ),
    );

    if (resultado == null) return;

    setState(() {
      final index = mantenimientos.indexWhere(
        (x) => x.id == resultado.mantenimiento.id,
      );

      if (index != -1) {
        mantenimientos[index] = resultado.mantenimiento;
      }

      evidenciasPorMantenimiento[resultado.mantenimiento.id] =
          resultado.evidencias;
    });

    await _cargarCronograma();
  }

  void _verEvidencias(MantenimientoProgramado mantenimiento) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EvidenciasMantenimientoPage(
          mantenimiento: mantenimiento,
        ),
      ),
    );
  }

  Future<void> _abrirGenerarPlanificacion() async {
    int cantidadMeses = 3;
    int mesInicio = mesSeleccionado;
    int anioInicio = anioSeleccionado;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text('Generar planificación'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Se generará el cronograma automático usando todos los equipos activos del inventario AA. Si ya existen registros, serán omitidos.',
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: cantidadMeses,
                      decoration: InputDecoration(
                        labelText: 'Cantidad de meses',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('1 mes')),
                        DropdownMenuItem(value: 2, child: Text('2 meses')),
                        DropdownMenuItem(value: 3, child: Text('3 meses')),
                        DropdownMenuItem(value: 6, child: Text('6 meses')),
                        DropdownMenuItem(value: 12, child: Text('12 meses')),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          cantidadMeses = value ?? 3;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<int>(
                      value: mesInicio,
                      decoration: InputDecoration(
                        labelText: 'Mes de inicio',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      items: meses
                          .map(
                            (m) => DropdownMenuItem(
                              value: m.numero,
                              child: Text(m.nombre),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          mesInicio = value ?? mesSeleccionado;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      initialValue: anioInicio.toString(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Año de inicio',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onChanged: (value) {
                        anioInicio = int.tryParse(value) ?? anioSeleccionado;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmado != true) return;

    await _generarPlanificacionAutomatica(
      cantidadMeses: cantidadMeses,
      mesInicio: mesInicio,
      anioInicio: anioInicio,
    );
  }

  Future<void> _generarPlanificacionAutomatica({
    required int cantidadMeses,
    required int mesInicio,
    required int anioInicio,
  }) async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final res = await mantenimientoService.generarPlanificacion(
        cantidadMeses: cantidadMeses,
        mesInicio: mesInicio,
        anioInicio: anioInicio,
        responsable: 'SEFAB',
        tipo: 'Preventivo',
      );

      if (!mounted) return;

      final insertados = res['insertados']?.toString() ?? '0';
      final omitidos = res['omitidos_por_duplicado']?.toString() ?? '0';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Planificación generada: $insertados insertados, $omitidos omitidos.',
          ),
        ),
      );

      setState(() {
        mesSeleccionado = mesInicio;
        anioSeleccionado = anioInicio;
      });

      await _cargarCronograma();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color sefPrimary = Color(0xFF1F2937);
    const Color sefAccent = Color(0xFFF97316);

    final mesNombre = meses
        .firstWhere(
          (m) => m.numero == mesSeleccionado,
          orElse: () => const MesCronograma(numero: 0, nombre: 'Mes'),
        )
        .nombre;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Cronograma'),
        backgroundColor: sefPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Generar planificación',
            onPressed: cargando ? null : _abrirGenerarPlanificacion,
            icon: const Icon(Icons.auto_awesome),
          ),
          IconButton(
            tooltip: 'Actualizar',
            onPressed: cargando ? null : _cargarCronograma,
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
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Mantenimientos mensuales',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: sefAccent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '${porcentajeCumplimiento.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Periodo $mesNombre $anioSeleccionado',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalMes programados · $realizadosMes realizados · $pendientesMes pendientes',
                  style: const TextStyle(color: Colors.white70),
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
                                _cargarCronograma();
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
                                onPressed: _cargarCronograma,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : mantenimientosDelMes.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay mantenimientos programados para este mes.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(
                              16,
                              16,
                              16,
                              MediaQuery.of(context).padding.bottom + 110,
                            ),
                            itemCount: mantenimientosDelMes.length,
                            itemBuilder: (context, index) {
                              final m = mantenimientosDelMes[index];
                              final estadoColor = _estadoColor(m.estado);
                              final avanceChecklist = m.checklistTotal == 0
                                  ? 0.0
                                  : m.checklistCompletado / m.checklistTotal;

                              return Card(
                                elevation: 3,
                                margin: const EdgeInsets.only(bottom: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 52,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color:
                                                  estadoColor.withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Icon(
                                              _faseIcon(m.fase),
                                              color: estadoColor,
                                              size: 30,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${m.equipoCodigo} · ${m.equipoMarca}',
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  '${m.tipo} · ${m.fase}',
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Chip(
                                            label: Text(
                                              m.estado,
                                              style: TextStyle(
                                                color: estadoColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            backgroundColor:
                                                estadoColor.withOpacity(0.10),
                                            side: BorderSide.none,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _InfoChip(
                                            icon: Icons.event,
                                            text: m.fechaProgramada,
                                          ),
                                          _InfoChip(
                                            icon: Icons.weekend_outlined,
                                            text: m.diaTrabajo,
                                          ),
                                          _InfoChip(
                                            icon: Icons.business,
                                            text: m.area,
                                          ),
                                          _InfoChip(
                                            icon: Icons.location_on_outlined,
                                            text: m.ubicacion,
                                          ),
                                          _InfoChip(
                                            icon: Icons.photo_camera_outlined,
                                            text:
                                                '${_cantidadEvidencias(m)} evidencias',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: LinearProgressIndicator(
                                                value: avanceChecklist,
                                                minHeight: 8,
                                                backgroundColor:
                                                    const Color(0xFFE5E7EB),
                                                color: estadoColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '${m.checklistCompletado}/${m.checklistTotal}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Avance de checklist técnico',
                                        style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (m.observacion.trim().isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Text(
                                          m.observacion,
                                          style: const TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                      const Divider(height: 24),
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            final esPantallaPequena = constraints.maxWidth < 390;

                                            if (esPantallaPequena) {
                                              return Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: OutlinedButton.icon(
                                                          onPressed: () => _verEvidencias(m),
                                                          icon: const Icon(Icons.image_outlined, size: 18),
                                                          label: const Text(
                                                            'Evidencias',
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          style: OutlinedButton.styleFrom(
                                                            minimumSize: const Size.fromHeight(46),
                                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(14),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: OutlinedButton.icon(
                                                          onPressed: () => _abrirMoverMes(m),
                                                          icon: const Icon(Icons.drive_file_move_outline, size: 18),
                                                          label: const Text(
                                                            'Mover',
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          style: OutlinedButton.styleFrom(
                                                            minimumSize: const Size.fromHeight(46),
                                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(14),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: ElevatedButton.icon(
                                                      onPressed: () => _registrarEjecucion(m),
                                                      icon: const Icon(Icons.fact_check_outlined, size: 18),
                                                      label: const Text(
                                                        'Registrar',
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                        minimumSize: const Size.fromHeight(48),
                                                        backgroundColor: sefAccent,
                                                        foregroundColor: Colors.white,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(14),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }

                                            return Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton.icon(
                                                    onPressed: () => _verEvidencias(m),
                                                    icon: const Icon(Icons.image_outlined, size: 18),
                                                    label: const Text(
                                                      'Evidencias',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    style: OutlinedButton.styleFrom(
                                                      minimumSize: const Size.fromHeight(46),
                                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(14),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: OutlinedButton.icon(
                                                    onPressed: () => _abrirMoverMes(m),
                                                    icon: const Icon(Icons.drive_file_move_outline, size: 18),
                                                    label: const Text(
                                                      'Mover',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    style: OutlinedButton.styleFrom(
                                                      minimumSize: const Size.fromHeight(46),
                                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(14),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    onPressed: () => _registrarEjecucion(m),
                                                    icon: const Icon(Icons.fact_check_outlined, size: 18),
                                                    label: const Text(
                                                      'Registrar',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    style: ElevatedButton.styleFrom(
                                                      minimumSize: const Size.fromHeight(46),
                                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                                      backgroundColor: sefAccent,
                                                      foregroundColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(14),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class MesCronograma {
  final int numero;
  final String nombre;

  const MesCronograma({
    required this.numero,
    required this.nombre,
  });
}

class ResultadoEjecucionMantenimiento {
  final MantenimientoProgramado mantenimiento;
  final List<XFile> evidencias;

  ResultadoEjecucionMantenimiento({
    required this.mantenimiento,
    required this.evidencias,
  });
}

class ChecklistMantenimiento {
  final String descripcion;
  bool realizado;

  final List<XFile> evidencias;
  final List<Map<String, dynamic>> evidenciasServidor;

  ChecklistMantenimiento({
    required this.descripcion,
    required this.realizado,
    List<XFile>? evidencias,
    List<Map<String, dynamic>>? evidenciasServidor,
  })  : evidencias = evidencias ?? [],
        evidenciasServidor = evidenciasServidor ?? [];

  int get totalEvidencias => evidencias.length + evidenciasServidor.length;

  bool get tieneEvidencia => totalEvidencias > 0;
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

class RegistrarMantenimientoPage extends StatefulWidget {
  final MantenimientoProgramado mantenimiento;
  final List<XFile> evidenciasIniciales;

  const RegistrarMantenimientoPage({
    super.key,
    required this.mantenimiento,
    this.evidenciasIniciales = const [],
  });

  @override
  State<RegistrarMantenimientoPage> createState() =>
      _RegistrarMantenimientoPageState();
}

class _RegistrarMantenimientoPageState
    extends State<RegistrarMantenimientoPage> {
  final TextEditingController presionCtrl = TextEditingController();
  final TextEditingController amperajeCtrl = TextEditingController();
  final TextEditingController observacionCtrl = TextEditingController();
  final TextEditingController recomendacionCtrl = TextEditingController();

  final ImagePicker picker = ImagePicker();
  final MantenimientoService mantenimientoService = MantenimientoService();
  final SeguridadService seguridadService = SeguridadService();

  bool guardando = false;
  bool cargandoEjecucion = false;

  int? ejecucionIdActual;
  bool petsCompletado = false;
  bool eppCompletado = false;
  bool incidenteRegistrado = false;

  late List<ChecklistMantenimiento> checklist;
  final List<XFile> evidencias = [];

  @override
  void initState() {
    super.initState();
    checklist = _generarChecklist(widget.mantenimiento.fase);
    evidencias.addAll(widget.evidenciasIniciales);
    _cargarEjecucionGuardada();
  }

  @override
  void dispose() {
    presionCtrl.dispose();
    amperajeCtrl.dispose();
    observacionCtrl.dispose();
    recomendacionCtrl.dispose();
    super.dispose();
  }

  void _mostrarOpcionesEvidenciaChecklist(int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Tomar foto'),
                subtitle: Text(checklist[index].descripcion),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarEvidenciaChecklist(
                    index: index,
                    source: ImageSource.camera,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Seleccionar de galería'),
                subtitle: Text(checklist[index].descripcion),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarEvidenciaChecklist(
                    index: index,
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

  Future<void> _cargarEstadoSeguridad(int ejecucionId) async {
    try {
      final petsResp = await seguridadService.listarPetsChecklist(
        ejecucionId: ejecucionId,
      );

      final eppResp = await seguridadService.listarEppChecklist(
        ejecucionId: ejecucionId,
      );

      final incidenteResp = await seguridadService.listarIncidente(
        ejecucionId: ejecucionId,
      );

      if (!mounted) return;

      final petsData = petsResp['data'];
      final eppData = eppResp['data'];
      final incidenteData = incidenteResp['data'];

      setState(() {
        petsCompletado =
            petsResp['success'] == true &&
            petsData is Map &&
            petsData.isNotEmpty;

        eppCompletado =
            eppResp['success'] == true &&
            eppData is Map &&
            eppData.isNotEmpty;

        incidenteRegistrado =
            incidenteResp['success'] == true &&
            incidenteData is Map &&
            incidenteData.isNotEmpty;
      });
    } catch (e) {
      debugPrint('Error cargando estado PETS/EPP/Incidente: $e');
    }
  }

  
  Future<void> _abrirIncidente() async {
    if (ejecucionIdActual == null || ejecucionIdActual! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Primero debe guardar la ejecución para generar el ID del trabajo.',
          ),
        ),
      );
      return;
    }

    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => IncidentePage(
          ejecucionId: ejecucionIdActual!,
          usuarioRegistro: 'admin',
        ),
      ),
    );

    if (mounted) {
      await _cargarEstadoSeguridad(ejecucionIdActual!);
    }
  }

  Future<void> _cargarEjecucionGuardada() async {
    setState(() {
      cargandoEjecucion = true;
    });

    try {
      final response = await mantenimientoService.listarEjecucion(
        mantenimientoId: widget.mantenimiento.id,
      );

      final ejecucion = response['ejecucion'];
      final List checklistGuardado = response['checklist'] ?? [];

      if (ejecucion == null) return;

      ejecucionIdActual = int.tryParse(ejecucion['id'].toString());
      if (ejecucionIdActual != null && ejecucionIdActual! > 0) {
        await _cargarEstadoSeguridad(ejecucionIdActual!);
      }

      for (final itemGuardado in checklistGuardado) {
        final descripcionGuardada =
            itemGuardado['descripcion']?.toString().trim() ?? '';

        final realizado =
            int.tryParse(itemGuardado['realizado'].toString()) == 1;

        final index = checklist.indexWhere(
          (x) => x.descripcion.trim() == descripcionGuardada,
        );

        if (index != -1) {
          checklist[index].realizado = realizado;
        }
      }

      presionCtrl.text = ejecucion['presion_refrigerante']?.toString() ?? '';
      amperajeCtrl.text = ejecucion['amperaje_compresor']?.toString() ?? '';
      observacionCtrl.text = ejecucion['observacion_tecnica']?.toString() ?? '';
      recomendacionCtrl.text =
          ejecucion['recomendacion_correctiva']?.toString() ?? '';

      final evidenciasServidor = await mantenimientoService.listarEvidencias(
        mantenimientoId: widget.mantenimiento.id,
      );

      for (final evidencia in evidenciasServidor) {
        final tipo = evidencia['tipo_evidencia']?.toString() ?? '';
        final observacion = evidencia['observacion']?.toString() ?? '';

        if (tipo != 'checklist') continue;

        final index = checklist.indexWhere(
          (item) => observacion.startsWith(item.descripcion),
        );

        if (index != -1) {
          checklist[index].evidenciasServidor.add(evidencia);
        }
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('ERROR CARGANDO EJECUCIÓN: $e');
    } finally {
      if (mounted) {
        setState(() {
          cargandoEjecucion = false;
        });
      }
    }
  }

  Future<void> _abrirChecklistPets() async {
    if (ejecucionIdActual == null || ejecucionIdActual! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Primero debe guardar la ejecución para generar el ID del trabajo.',
          ),
        ),
      );
      return;
    }
  
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChecklistPetsPage(
          ejecucionId: ejecucionIdActual!,
          usuarioRegistro: 'admin',
        ),
      ),
    );
  
    if (resultado == true && mounted) {
      setState(() {
        petsCompletado = true;
      });
    }
  }
  
  Future<void> _abrirChecklistEpp() async {
    if (ejecucionIdActual == null || ejecucionIdActual! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Primero debe guardar la ejecución para generar el ID del trabajo.',
          ),
        ),
      );
      return;
    }

    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChecklistEppPage(
          ejecucionId: ejecucionIdActual!,
          usuarioRegistro: 'admin',
        ),
      ),
    );

    if (mounted) {
      await _cargarEstadoSeguridad(ejecucionIdActual!);
    }
  }

  List<ChecklistMantenimiento> _generarChecklist(String fase) {
    final faseLower = fase.toLowerCase();

    final evaporador = [
      'Limpieza y desinfección de filtros',
      'Limpieza profunda de serpentín evaporador',
      'Limpieza de turbina',
      'Revisión de drenaje',
      'Revisión de bandeja de condensado',
      'Ajuste de conexiones eléctricas internas',
    ];

    final condensador = [
      'Limpieza profunda de serpentín condensador',
      'Lavado con presión controlada',
      'Medición de presión del refrigerante',
      'Medición de amperaje del compresor',
      'Revisión de ventilador',
      'Revisión de contactores',
      'Inspección de tuberías',
      'Inspección de aislamiento',
    ];

    final items = <String>[];

    if (faseLower == 'evaporador') {
      items.addAll(evaporador);
    } else if (faseLower == 'condensador') {
      items.addAll(condensador);
    } else {
      items.addAll(evaporador);
      items.addAll(condensador);
    }

    return items
        .map(
          (e) => ChecklistMantenimiento(
            descripcion: e,
            realizado: false,
            evidencias: [],
          ),
        )
        .toList();
  }

  Future<void> _seleccionarEvidencia(ImageSource source) async {
    try {
      final XFile? foto = await picker.pickImage(
        source: source,
        imageQuality: 55,
        maxWidth: 1280,
        maxHeight: 1280,
      );

      if (foto == null) return;

      setState(() {
        evidencias.add(foto);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo seleccionar la evidencia: $e'),
        ),
      );
    }
  }

  Future<void> _seleccionarEvidenciaChecklist({
    required int index,
    required ImageSource source,
  }) async {
    try {
      final XFile? foto = await picker.pickImage(
        source: source,
        imageQuality: 60,
        maxWidth: 1280,
        maxHeight: 1280,
      );

      if (foto == null) return;

      setState(() {
        checklist[index].evidencias.add(foto);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo seleccionar la evidencia: $e'),
        ),
      );
    }
  }

  void _mostrarOpcionesEvidencia() {
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
                  _seleccionarEvidencia(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Seleccionar de galería'),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarEvidencia(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _preguntarCompletarSeguridad(int ejecucionId) async {
    final continuar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Controles de seguridad'),
          content: const Text(
            'Para cerrar correctamente la intervención debe completar el Checklist PETS y el Checklist EPP.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: const Text(
                      'Para cerrar correctamente la intervención debe completar primero el Checklist PETS y luego el Checklist EPP.',
                    ),
                  ),
                );
              },
              child: const Text('Obligatorio'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.health_and_safety_outlined),
              label: const Text('Completar ahora'),
            ),
          ],
        );
      },
    );

    if (continuar != true) return;

    final petsOk = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChecklistPetsPage(
          ejecucionId: ejecucionId,
          usuarioRegistro: 'admin',
        ),
      ),
    );

    if (petsOk == true && mounted) {
      setState(() {
        petsCompletado = true;
      });
    }

    final eppOk = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChecklistEppPage(
          ejecucionId: ejecucionId,
          usuarioRegistro: 'admin',
        ),
      ),
    );

    if (eppOk == true && mounted) {
      setState(() {
        eppCompletado = true;
      });
    }
  }

  Future<void> _guardarEjecucion() async {
    final total = checklist.length;
    final completados = checklist.where((x) => x.realizado).length;

    final tieneObservaciones = observacionCtrl.text.trim().isNotEmpty ||
        recomendacionCtrl.text.trim().isNotEmpty ||
        completados < total;

    final nuevoEstado = tieneObservaciones ? 'Observado' : 'Realizado';

    setState(() {
      guardando = true;
    });

    try {
      final checklistJson = checklist.map((item) {
        return {
          'descripcion': item.descripcion,
          'realizado': item.realizado ? 1 : 0,
        };
      }).toList();

      final response = await mantenimientoService.guardarEjecucion(
        mantenimientoId: widget.mantenimiento.id,
        presionRefrigerante: presionCtrl.text.trim(),
        amperajeCompresor: amperajeCtrl.text.trim(),
        observacionTecnica: observacionCtrl.text.trim(),
        recomendacionCorrectiva: recomendacionCtrl.text.trim(),
        estadoResultado: nuevoEstado,
        usuarioRegistro: 'admin',
        checklist: checklistJson,
      );

      final ejecucionIdRespuesta =
          int.tryParse(response['ejecucion_id'].toString()) ?? 0;

      final ejecucionIdParaSeguridad =
          (ejecucionIdActual != null && ejecucionIdActual! > 0)
              ? ejecucionIdActual!
              : ejecucionIdRespuesta;

      if (ejecucionIdActual == null || ejecucionIdActual! <= 0) {
        if (ejecucionIdRespuesta > 0) {
          ejecucionIdActual = ejecucionIdRespuesta;
        }
      }

      if (evidencias.isNotEmpty && ejecucionIdParaSeguridad > 0) {
        for (int i = 0; i < evidencias.length; i++) {
          await mantenimientoService.subirEvidencia(
            mantenimientoId: widget.mantenimiento.id,
            ejecucionId: ejecucionIdParaSeguridad,
            foto: evidencias[i],
            tipoEvidencia: 'foto',
            observacion: 'Evidencia ${i + 1}',
          );
        }
      }

      if (ejecucionIdParaSeguridad  > 0) {
        for (final item in checklist) {
          if (item.evidencias.isEmpty) continue;

          for (int i = 0; i < item.evidencias.length; i++) {
            await mantenimientoService.subirEvidencia(
              mantenimientoId: widget.mantenimiento.id,
              ejecucionId: ejecucionIdParaSeguridad,
              foto: item.evidencias[i],
              tipoEvidencia: 'checklist',
              observacion: '${item.descripcion} - Evidencia ${i + 1}',
            );
          }
        }
      }

      final mantenimientoData =
          Map<String, dynamic>.from(response['mantenimiento'] ?? {});

      final actualizado = widget.mantenimiento.copyWith(
        estado: mantenimientoData['estado']?.toString() ?? nuevoEstado,
        checklistCompletado: int.tryParse(
              mantenimientoData['checklist_completado'].toString(),
            ) ??
            completados,
        checklistTotal: int.tryParse(
              mantenimientoData['checklist_total'].toString(),
            ) ??
            total,
        fotos: evidencias.length,
        observacion: mantenimientoData['observacion']?.toString() ??
            'Mantenimiento registrado correctamente.',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cumplimiento y evidencias guardadas correctamente.'),
        ),
      );
      
      if (ejecucionIdParaSeguridad > 0) {
        setState(() {
          ejecucionIdActual = ejecucionIdParaSeguridad;
          guardando = false;
        });

        await _cargarEstadoSeguridad(ejecucionIdParaSeguridad);

        if (!mounted) return;

        if (!petsCompletado || !eppCompletado) {
          await _preguntarCompletarSeguridad(ejecucionIdParaSeguridad);
          await _cargarEstadoSeguridad(ejecucionIdParaSeguridad);
        }

        if (!mounted) return;

        if (!petsCompletado || !eppCompletado) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Debe completar PETS y EPP para cerrar la intervención.',
              ),
            ),
          );
          return;
        }
      }
      
      if (!mounted) return;
      
      Navigator.pop(
        context,
        ResultadoEjecucionMantenimiento(
          mantenimiento: actualizado,
          evidencias: List<XFile>.from(evidencias),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          guardando = false;
        });
      }
    }
  }

  Widget _seguridadCard() {
    const Color sefAccent = Color(0xFFF97316);

    Widget item({
      required String titulo,
      required String subtitulo,
      required bool completado,
      required IconData icono,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: completado ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: completado ? const Color(0xFF16A34A) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icono,
                color: completado ? const Color(0xFF16A34A) : sefAccent,
                size: 28,
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
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(
                  completado ? 'Completo' : 'Pendiente',
                  style: TextStyle(
                    color: completado ? const Color(0xFF16A34A) : Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                backgroundColor:
                    completado ? const Color(0xFFDCFCE7) : const Color(0xFFE5E7EB),
                side: BorderSide.none,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Seguridad y control PETS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
            const SizedBox(height: 10),
            item(
              titulo: 'Checklist PETS',
              subtitulo: 'Coordinación, IPERC, delimitación, LOTO y autorización.',
              completado: petsCompletado,
              icono: Icons.health_and_safety_outlined,
              onTap: _abrirChecklistPets,
            ),
            item(
              titulo: 'Checklist EPP',
              subtitulo: 'Casco, lentes, guantes, zapatos, mascarilla y otros.',
              completado: eppCompletado,
              icono: Icons.construction_outlined,
              onTap: _abrirChecklistEpp,
            ),
            item(
              titulo: 'Reportar incidente',
              subtitulo: 'Fuga, cortocircuito, sobrecalentamiento, daño estructural o riesgo eléctrico.',
              completado: incidenteRegistrado,
              icono: Icons.report_problem_outlined,
              onTap: _abrirIncidente,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color sefPrimary = Color(0xFF1F2937);
    const Color sefAccent = Color(0xFFF97316);

    final mantenimiento = widget.mantenimiento;
    final completados = checklist.where((x) => x.realizado).length;
    final avance = checklist.isEmpty ? 0.0 : completados / checklist.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Registrar ejecución'),
        backgroundColor: sefPrimary,
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
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${mantenimiento.equipoCodigo} · ${mantenimiento.equipoMarca}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${mantenimiento.area} · ${mantenimiento.ubicacion}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${mantenimiento.tipo} · ${mantenimiento.fase}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
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
                    'Avance del checklist',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: avance,
                      minHeight: 9,
                      backgroundColor: const Color(0xFFE5E7EB),
                      color: sefAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$completados/${checklist.length} actividades marcadas',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  if (cargandoEjecucion) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'Cargando última ejecución...',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _seguridadCard(),
          const SizedBox(height: 14),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Checklist técnico',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  for (int i = 0; i < checklist.length; i++)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: checklist[i].realizado
                            ? const Color(0xFFFFF7ED)
                            : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: checklist[i].realizado
                              ? sefAccent.withOpacity(0.35)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: checklist[i].realizado,
                                activeColor: sefAccent,
                                onChanged: (value) {
                                  setState(() {
                                    checklist[i].realizado = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  checklist[i].descripcion,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: checklist[i].tieneEvidencia
                                    ? '${checklist[i].totalEvidencias} evidencia(s) cargada(s)'
                                    : 'Agregar evidencia',
                                onPressed: () =>
                                    _mostrarOpcionesEvidenciaChecklist(i),
                                icon: Badge(
                                  isLabelVisible:
                                      checklist[i].tieneEvidencia,
                                  label: Text(
                                    '${checklist[i].totalEvidencias}',
                                  ),
                                  child: Icon(
                                    checklist[i].tieneEvidencia
                                        ? Icons.photo_camera
                                        : Icons.add_a_photo_outlined,
                                    color: checklist[i].tieneEvidencia
                                        ? const Color(0xFF16A34A)
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (checklist[i].tieneEvidencia)
                            Padding(
                              padding: const EdgeInsets.only(left: 48, top: 2),
                              child: Text(
                                '${checklist[i].totalEvidencias} evidencia(s) cargada(s)',
                                style: const TextStyle(
                                  color: Color(0xFF16A34A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.only(left: 48, top: 2),
                              child: Text(
                                'Sin evidencia cargada',
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          if (checklist[i].evidenciasServidor.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 72,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    checklist[i].evidenciasServidor.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, fotoIndex) {
                                  final evidencia =
                                      checklist[i].evidenciasServidor[fotoIndex];
                                  final url =
                                      evidencia['url']?.toString() ?? '';

                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              VistaFotoServidorPage(
                                            url: url,
                                            titulo:
                                                'Evidencia guardada ${fotoIndex + 1}',
                                          ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        url,
                                        width: 72,
                                        height: 72,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) {
                                          return Container(
                                            width: 72,
                                            height: 72,
                                            color: const Color(0xFFE5E7EB),
                                            child: const Icon(
                                              Icons.broken_image_outlined,
                                              color: Colors.black38,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          if (checklist[i].evidencias.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 72,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: checklist[i].evidencias.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, fotoIndex) {
                                  final foto =
                                      checklist[i].evidencias[fotoIndex];

                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(foto.path),
                                          width: 72,
                                          height: 72,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 3,
                                        right: 3,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              checklist[i]
                                                  .evidencias
                                                  .removeAt(fotoIndex);
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
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _MedicionesCard(
            presionCtrl: presionCtrl,
            amperajeCtrl: amperajeCtrl,
          ),
          const SizedBox(height: 14),
          _ObservacionesCard(
            observacionCtrl: observacionCtrl,
            recomendacionCtrl: recomendacionCtrl,
          ),
          const SizedBox(height: 14),
          _EvidenciasSelectorCard(
            evidencias: evidencias,
            onAgregar: _mostrarOpcionesEvidencia,
            onEliminar: (index) {
              setState(() {
                evidencias.removeAt(index);
              });
            },
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: guardando ? null : _guardarEjecucion,
              style: ElevatedButton.styleFrom(
                backgroundColor: sefAccent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: sefAccent.withOpacity(0.55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
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
                guardando ? 'Guardando...' : 'Guardar cumplimiento',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicionesCard extends StatelessWidget {
  final TextEditingController presionCtrl;
  final TextEditingController amperajeCtrl;

  const _MedicionesCard({
    required this.presionCtrl,
    required this.amperajeCtrl,
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
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mediciones técnicas',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: presionCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Presión de refrigerante',
                hintText: 'Ejemplo: 65 PSI',
                prefixIcon: const Icon(Icons.speed_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: amperajeCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amperaje del compresor',
                hintText: 'Ejemplo: 7.5 A',
                prefixIcon: const Icon(Icons.electric_bolt_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObservacionesCard extends StatelessWidget {
  final TextEditingController observacionCtrl;
  final TextEditingController recomendacionCtrl;

  const _ObservacionesCard({
    required this.observacionCtrl,
    required this.recomendacionCtrl,
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
        child: Column(
          children: [
            TextField(
              controller: observacionCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Observaciones técnicas',
                hintText: 'Detalle fallas, condiciones o hallazgos',
                prefixIcon: const Icon(Icons.notes_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: recomendacionCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Recomendaciones correctivas',
                hintText: 'Indicar recomendaciones si aplican',
                prefixIcon: const Icon(Icons.tips_and_updates_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EvidenciasSelectorCard extends StatelessWidget {
  final List<XFile> evidencias;
  final VoidCallback onAgregar;
  final Function(int index) onEliminar;

  const _EvidenciasSelectorCard({
    required this.evidencias,
    required this.onAgregar,
    required this.onEliminar,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Evidencias fotográficas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onAgregar,
                  icon: const Icon(Icons.add_a_photo_outlined),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (evidencias.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Aún no se han agregado evidencias.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: evidencias.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final foto = evidencias[index];

                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(foto.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () => onEliminar(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class EvidenciasMantenimientoPage extends StatefulWidget {
  final MantenimientoProgramado mantenimiento;

  const EvidenciasMantenimientoPage({
    super.key,
    required this.mantenimiento,
  });

  @override
  State<EvidenciasMantenimientoPage> createState() =>
      _EvidenciasMantenimientoPageState();
}

class _EvidenciasMantenimientoPageState
    extends State<EvidenciasMantenimientoPage> {
  final MantenimientoService mantenimientoService = MantenimientoService();

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
      final data = await mantenimientoService.listarEvidencias(
        mantenimientoId: widget.mantenimiento.id,
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

  Future<void> _eliminarEvidencia(Map<String, dynamic> evidencia) async {
    final id = int.tryParse(evidencia['id'].toString()) ?? 0;

    if (id <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID de evidencia inválido.'),
        ),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar evidencia'),
        content: const Text(
          '¿Deseas eliminar esta evidencia? Esta acción también eliminará la imagen del servidor.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await mantenimientoService.eliminarEvidencia(
        evidenciaId: id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evidencia eliminada correctamente.'),
        ),
      );

      await _cargarEvidencias();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color sefPrimary = Color(0xFF1F2937);

    final mantenimiento = widget.mantenimiento;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Evidencias'),
        backgroundColor: sefPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: cargando ? null : _cargarEvidencias,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).padding.bottom + 80,
        ),
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${mantenimiento.equipoCodigo} · ${mantenimiento.equipoMarca}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${mantenimiento.area} · ${mantenimiento.ubicacion}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${mantenimiento.tipo} · ${mantenimiento.fase}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (cargando)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: CircularProgressIndicator(
                  color: Color(0xFFF97316),
                ),
              ),
            )
          else if (error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else if (evidencias.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: 54,
                    color: Colors.black38,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No hay evidencias registradas para este mantenimiento.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: evidencias.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final evidencia = evidencias[index];

                final url = evidencia['url']?.toString() ?? '';
                final tipo = evidencia['tipo_evidencia']?.toString() ?? '';
                final obs = evidencia['observacion']?.toString() ?? '';

                return ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VistaFotoServidorPage(
                                url: url,
                                titulo: 'Evidencia ${index + 1}',
                              ),
                            ),
                          );
                        },
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: Colors.white,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                size: 45,
                                color: Colors.black38,
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap: () => _eliminarEvidencia(evidencia),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.90),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
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
                                Colors.black.withOpacity(0.72),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          child: Text(
                            obs.isNotEmpty
                                ? obs
                                : 'Evidencia ${index + 1} · $tipo',
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
                );
              },
            ),
        ],
      ),
    );
  }
}

class VistaFotoServidorPage extends StatelessWidget {
  final String url;
  final String titulo;

  const VistaFotoServidorPage({
    super.key,
    required this.url,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    const Color sefPrimary = Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: sefPrimary,
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

class VistaFotoPage extends StatelessWidget {
  final XFile foto;
  final String titulo;

  const VistaFotoPage({
    super.key,
    required this.foto,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    const Color sefPrimary = Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: sefPrimary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(
            File(foto.path),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}