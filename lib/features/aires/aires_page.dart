import 'package:flutter/material.dart';

import '../../data/models/mantenimiento_model.dart';
import 'aires_service.dart';
import '../informes/historial_mediciones_page.dart';

class AiresPage extends StatefulWidget {
  const AiresPage({super.key});

  @override
  State<AiresPage> createState() => _AiresPageState();
}

class _AiresPageState extends State<AiresPage> {
  final AiresService airesService = AiresService();
  final TextEditingController buscarCtrl = TextEditingController();

  List<AireEquipo> equipos = [];
  List<AireEquipo> filtrados = [];

  bool cargando = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _cargarEquipos();
  }

  @override
  void dispose() {
    buscarCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarEquipos() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final data = await airesService.listarAires();

      if (!mounted) return;

      setState(() {
        equipos = data;
        filtrados = data;
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

  void _filtrar(String value) {
    final query = value.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filtrados = equipos;
        return;
      }

      filtrados = equipos.where((e) {
        return e.codigo.toLowerCase().contains(query) ||
            e.area.toLowerCase().contains(query) ||
            e.ubicacion.toLowerCase().contains(query) ||
            e.marca.toLowerCase().contains(query) ||
            e.modelo.toLowerCase().contains(query) ||
            e.serie.toLowerCase().contains(query) ||
            e.capacidadBtu.toLowerCase().contains(query) ||
            e.tipoEquipo.toLowerCase().contains(query) ||
            e.observacion.toLowerCase().contains(query);
      }).toList();
    });
  }

  String _valor(String value) {
    final v = value.trim();

    if (v.isEmpty || v.toLowerCase() == 'null') {
      return 'No registrado';
    }

    return v;
  }

  Color _estadoColor(int estado) {
    return estado == 1 ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
  }

  String _estadoTexto(int estado) {
    return estado == 1 ? 'Activo' : 'Inactivo';
  }

  void _verDetalle(AireEquipo equipo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetalleAireSheet(equipo: equipo),
    );
  }

  void _abrirFormulario({AireEquipo? equipo}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return AireFormModal(
          equipo: equipo,
          onGuardado: () async {
            await _cargarEquipos();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color sefPrimary = Color(0xFF1F2937);
    const Color sefAccent = Color(0xFFF97316);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Inventario AA'),
        backgroundColor: sefPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: cargando ? null : _cargarEquipos,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Equipos registrados',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${filtrados.length} de ${equipos.length} equipos de aire acondicionado',
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => _abrirFormulario(),
                        child: Ink(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF97316),
                                Color(0xFFFB923C),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF97316).withOpacity(0.40),
                                blurRadius: 14,
                                offset: const Offset(0, 7),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: buscarCtrl,
                  onChanged: _filtrar,
                  decoration: InputDecoration(
                    hintText: 'Buscar por código, área, marca o ubicación',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: buscarCtrl.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              buscarCtrl.clear();
                              _filtrar('');
                            },
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: cargando
                ? const Center(
                    child: CircularProgressIndicator(
                      color: sefAccent,
                    ),
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
                                onPressed: _cargarEquipos,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : filtrados.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay equipos registrados.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _cargarEquipos,
                            color: sefAccent,
                            child: ListView.builder(
                              padding: EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                MediaQuery.of(context).padding.bottom + 110,
                              ),
                              itemCount: filtrados.length,
                              itemBuilder: (context, index) {
                                final e = filtrados[index];
                                final estadoColor = _estadoColor(e.estado);

                                return Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.only(bottom: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(22),
                                    onTap: () => _verDetalle(e),
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
                                                  color: const Color(0xFFE0F2FE),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
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
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${e.codigo} · ${_valor(e.marca)}',
                                                      style: const TextStyle(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      '${_valor(e.modelo)} · ${_valor(e.capacidadBtu)} BTU',
                                                      style: const TextStyle(
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuButton<String>(
                                                onSelected: (value) {
                                                  if (value == 'detalle') {
                                                    _verDetalle(e);
                                                  } else if (value == 'editar') {
                                                    _abrirFormulario(equipo: e);
                                                  }
                                                  else if (value == 'historial') {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => HistorialMedicionesPage(
                                                          equipoCodigo: e.codigo,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                itemBuilder: (_) => const [
                                                  PopupMenuItem(
                                                    value: 'detalle',
                                                    child: Text('Ver detalle'),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'editar',
                                                    child: Text('Editar'),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'historial',
                                                    child: Text('Historial técnico'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 14),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              _InfoChip(
                                                icon: Icons.business,
                                                text: _valor(e.area),
                                              ),
                                              _InfoChip(
                                                icon:
                                                    Icons.location_on_outlined,
                                                text: _valor(e.ubicacion),
                                              ),
                                              _InfoChip(
                                                icon: Icons.category_outlined,
                                                text: _valor(e.tipoEquipo),
                                              ),
                                              Chip(
                                                avatar: Icon(
                                                  Icons.circle,
                                                  size: 12,
                                                  color: estadoColor,
                                                ),
                                                label: Text(
                                                  _estadoTexto(e.estado),
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
                                          const Divider(height: 24),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _FechaItem(
                                                  titulo: 'Compra',
                                                  valor: _valor(e.fechaCompra),
                                                ),
                                              ),
                                              Expanded(
                                                child: _FechaItem(
                                                  titulo: 'Instalación',
                                                  valor: _valor(
                                                    e.fechaInstalacion,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (e.observacion
                                              .trim()
                                              .isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            Text(
                                              e.observacion,
                                              style: const TextStyle(
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _DetalleAireSheet extends StatelessWidget {
  final AireEquipo equipo;

  const _DetalleAireSheet({
    required this.equipo,
  });

  String _valor(String value) {
    final v = value.trim();

    if (v.isEmpty || v.toLowerCase() == 'null') {
      return 'No registrado';
    }

    return v;
  }

  @override
  Widget build(BuildContext context) {
    const Color sefPrimary = Color(0xFF1F2937);
    final estadoColor =
        equipo.estado == 1 ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF3F4F6),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              18,
              12,
              18,
              MediaQuery.of(context).padding.bottom + 30,
            ),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.ac_unit,
                      color: Color(0xFF0891B2),
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          equipo.codigo,
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: sefPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${_valor(equipo.marca)} · ${_valor(equipo.modelo)}',
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    avatar: Icon(
                      Icons.circle,
                      size: 12,
                      color: estadoColor,
                    ),
                    label: Text(
                      equipo.estado == 1 ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        color: estadoColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: estadoColor.withOpacity(0.10),
                    side: BorderSide.none,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _DetalleCard(
                title: 'Datos del equipo',
                children: [
                  _DetalleRow(label: 'Código', value: equipo.codigo),
                  _DetalleRow(label: 'Marca', value: _valor(equipo.marca)),
                  _DetalleRow(label: 'Modelo', value: _valor(equipo.modelo)),
                  _DetalleRow(label: 'Serie', value: _valor(equipo.serie)),
                  _DetalleRow(
                    label: 'Capacidad BTU',
                    value: _valor(equipo.capacidadBtu),
                  ),
                  _DetalleRow(
                    label: 'Tipo de equipo',
                    value: _valor(equipo.tipoEquipo),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _DetalleCard(
                title: 'Ubicación',
                children: [
                  _DetalleRow(label: 'Área', value: _valor(equipo.area)),
                  _DetalleRow(
                    label: 'Ubicación',
                    value: _valor(equipo.ubicacion),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _DetalleCard(
                title: 'Fechas',
                children: [
                  _DetalleRow(
                    label: 'Fecha de compra',
                    value: _valor(equipo.fechaCompra),
                  ),
                  _DetalleRow(
                    label: 'Fecha de instalación',
                    value: _valor(equipo.fechaInstalacion),
                  ),
                  _DetalleRow(
                    label: 'Fecha de registro',
                    value: _valor(equipo.fechaRegistro),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _DetalleCard(
                title: 'Observación',
                children: [
                  Text(
                    _valor(equipo.observacion),
                    style: const TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetalleCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetalleCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetalleRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetalleRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty ? 'No registrado' : value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
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
      avatar: Icon(
        icon,
        size: 16,
      ),
      label: Text(text.trim().isEmpty ? 'No registrado' : text),
      backgroundColor: const Color(0xFFF3F4F6),
      side: BorderSide.none,
    );
  }
}

class _FechaItem extends StatelessWidget {
  final String titulo;
  final String valor;

  const _FechaItem({
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final texto = valor.trim().isEmpty || valor.toLowerCase() == 'null'
        ? 'No registrado'
        : valor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.black45,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          texto,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class AireFormModal extends StatefulWidget {
  final AireEquipo? equipo;
  final Future<void> Function() onGuardado;

  const AireFormModal({
    super.key,
    this.equipo,
    required this.onGuardado,
  });

  @override
  State<AireFormModal> createState() => _AireFormModalState();
}

class _AireFormModalState extends State<AireFormModal> {
  final _formKey = GlobalKey<FormState>();
  final AiresService airesService = AiresService();

  late TextEditingController codigoCtrl;
  late TextEditingController areaCtrl;
  late TextEditingController ubicacionCtrl;
  late TextEditingController marcaCtrl;
  late TextEditingController modeloCtrl;
  late TextEditingController serieCtrl;
  late TextEditingController capacidadCtrl;
  late TextEditingController fechaCompraCtrl;
  late TextEditingController fechaInstalacionCtrl;
  late TextEditingController observacionCtrl;
  String frecuenciaMantenimiento = 'Trimestral';

  String tipoEquipo = 'No registrado';
  int estado = 1;
  bool guardando = false;

  @override
  void initState() {
    super.initState();

    final e = widget.equipo;

    codigoCtrl = TextEditingController(text: e?.codigo ?? '');
    areaCtrl = TextEditingController(text: e?.area ?? '');
    ubicacionCtrl = TextEditingController(text: e?.ubicacion ?? '');
    marcaCtrl = TextEditingController(text: e?.marca ?? '');
    modeloCtrl = TextEditingController(text: e?.modelo ?? '');
    serieCtrl = TextEditingController(text: e?.serie ?? '');
    capacidadCtrl = TextEditingController(text: e?.capacidadBtu ?? '');
    fechaCompraCtrl = TextEditingController(text: e?.fechaCompra ?? '');
    fechaInstalacionCtrl =
        TextEditingController(text: e?.fechaInstalacion ?? '');
    observacionCtrl = TextEditingController(text: e?.observacion ?? '');

    tipoEquipo = _normalizarTipo(e?.tipoEquipo ?? 'No registrado');
        frecuenciaMantenimiento = _normalizarFrecuencia(
      e?.frecuenciaMantenimiento ?? 'Trimestral',
    );
    estado = e?.estado ?? 1;
  }

  String _normalizarFrecuencia(String value) {
    final v = value.trim();

    const opciones = [
      'Mensual',
      'Bimestral',
      'Trimestral',
      'Semestral',
      'Anual',
    ];

    if (opciones.contains(v)) return v;

    return 'Trimestral';
  }

  String _normalizarTipo(String value) {
    final v = value.trim();

    const opciones = [
      'No registrado',
      'Split',
      'Piso techo',
      'Cassette',
      'Ventana',
      'Central',
    ];

    if (opciones.contains(v)) return v;

    return 'No registrado';
  }

  @override
  void dispose() {
    codigoCtrl.dispose();
    areaCtrl.dispose();
    ubicacionCtrl.dispose();
    marcaCtrl.dispose();
    modeloCtrl.dispose();
    serieCtrl.dispose();
    capacidadCtrl.dispose();
    fechaCompraCtrl.dispose();
    fechaInstalacionCtrl.dispose();
    observacionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      guardando = true;
    });

    try {
     await airesService.guardarAire(
      id: widget.equipo?.id ?? 0,
      codigo: codigoCtrl.text.trim(),
      area: areaCtrl.text.trim(),
      ubicacion: ubicacionCtrl.text.trim(),
      marca: marcaCtrl.text.trim(),
      modelo: modeloCtrl.text.trim(),
      serie: serieCtrl.text.trim(),
      capacidadBtu: capacidadCtrl.text.trim(),
      tipoEquipo: tipoEquipo,
      frecuenciaMantenimiento: frecuenciaMantenimiento,
      fechaCompra: fechaCompraCtrl.text.trim(),
      fechaInstalacion: fechaInstalacionCtrl.text.trim(),
      observacion: observacionCtrl.text.trim(),
      estado: estado,
    );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.equipo == null
                ? 'Equipo registrado correctamente.'
                : 'Equipo actualizado correctamente.',
          ),
        ),
      );

      await widget.onGuardado();

      if (!mounted) return;
      Navigator.pop(context);
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
          guardando = false;
        });
      }
    }
  }

  Future<void> _seleccionarFecha(TextEditingController controller) async {
    final ahora = DateTime.now();

    final fecha = await showDatePicker(
      context: context,
      initialDate: ahora,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (fecha == null) return;

    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();

    controller.text = '$dia/$mes/$anio';
  }

  @override
  Widget build(BuildContext context) {
    const Color sefAccent = Color(0xFFF97316);

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.65,
      maxChildSize: 0.96,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF9FAFB),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.only(
              left: 18,
              right: 18,
              top: 18,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.equipo == null ? 'Registrar equipo' : 'Editar equipo',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _CampoTexto(
                      controller: codigoCtrl,
                      label: 'Código',
                      icon: Icons.qr_code,
                      requerido: true,
                    ),
                    _CampoTexto(
                      controller: areaCtrl,
                      label: 'Área',
                      icon: Icons.business,
                      requerido: true,
                    ),
                    _CampoTexto(
                      controller: ubicacionCtrl,
                      label: 'Ubicación',
                      icon: Icons.location_on_outlined,
                      requerido: true,
                    ),
                    _CampoTexto(
                      controller: marcaCtrl,
                      label: 'Marca',
                      icon: Icons.sell_outlined,
                    ),
                    _CampoTexto(
                      controller: modeloCtrl,
                      label: 'Modelo',
                      icon: Icons.memory,
                    ),
                    _CampoTexto(
                      controller: serieCtrl,
                      label: 'Serie',
                      icon: Icons.confirmation_number_outlined,
                    ),
                    _CampoTexto(
                      controller: capacidadCtrl,
                      label: 'Capacidad BTU',
                      icon: Icons.ac_unit,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: tipoEquipo,
                      decoration: InputDecoration(
                        labelText: 'Tipo de equipo',
                        prefixIcon: const Icon(Icons.category_outlined),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'No registrado',
                          child: Text('No registrado'),
                        ),
                        DropdownMenuItem(value: 'Split', child: Text('Split')),
                        DropdownMenuItem(
                          value: 'Piso techo',
                          child: Text('Piso techo'),
                        ),
                        DropdownMenuItem(
                          value: 'Cassette',
                          child: Text('Cassette'),
                        ),
                        DropdownMenuItem(
                          value: 'Ventana',
                          child: Text('Ventana'),
                        ),
                        DropdownMenuItem(
                          value: 'Central',
                          child: Text('Central'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          tipoEquipo = value ?? 'No registrado';
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<int>(
                      value: estado,
                      decoration: InputDecoration(
                        labelText: 'Estado',
                        prefixIcon: const Icon(Icons.info_outline),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Activo')),
                        DropdownMenuItem(value: 0, child: Text('Inactivo')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          estado = value ?? 1;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
DropdownButtonFormField<String>(
  value: frecuenciaMantenimiento,
  decoration: InputDecoration(
    labelText: 'Frecuencia de mantenimiento',
    prefixIcon: const Icon(Icons.repeat),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),
  items: const [
    DropdownMenuItem(
      value: 'Mensual',
      child: Text('Mensual'),
    ),
    DropdownMenuItem(
      value: 'Bimestral',
      child: Text('Bimestral'),
    ),
    DropdownMenuItem(
      value: 'Trimestral',
      child: Text('Trimestral'),
    ),
    DropdownMenuItem(
      value: 'Semestral',
      child: Text('Semestral'),
    ),
    DropdownMenuItem(
      value: 'Anual',
      child: Text('Anual'),
    ),
  ],
  onChanged: (value) {
    setState(() {
      frecuenciaMantenimiento = value ?? 'Trimestral';
    });
  },
),
                    const SizedBox(height: 14),
                    _CampoTexto(
                      controller: fechaCompraCtrl,
                      label: 'Fecha de compra',
                      icon: Icons.event_available,
                      hint: 'dd/mm/aaaa',
                      readOnly: true,
                      onTap: () => _seleccionarFecha(fechaCompraCtrl),
                    ),
                    _CampoTexto(
                      controller: fechaInstalacionCtrl,
                      label: 'Fecha de instalación',
                      icon: Icons.event,
                      hint: 'dd/mm/aaaa',
                      readOnly: true,
                      onTap: () => _seleccionarFecha(fechaInstalacionCtrl),
                    ),
                    _CampoTexto(
                      controller: observacionCtrl,
                      label: 'Observación',
                      icon: Icons.notes,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: guardando ? null : _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: sefAccent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: sefAccent.withOpacity(0.50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: guardando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          guardando ? 'Guardando...' : 'Guardar equipo',
                          style: const TextStyle(
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
      },
    );
  }
}

class _CampoTexto extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final bool requerido;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;

  const _CampoTexto({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.requerido = false,
    this.maxLines = 1,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        validator: (value) {
          if (requerido && (value == null || value.trim().isEmpty)) {
            return 'Campo obligatorio';
          }
          return null;
        },
      ),
    );
  }
}