import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/departamento.dart';
import '../models/leyenda.dart';
import '../services/leyenda_service.dart';

class CrearLeyendaScreen extends StatefulWidget {
  final Leyenda? leyendaAEditar;

  const CrearLeyendaScreen({super.key, this.leyendaAEditar});

  @override
  State<CrearLeyendaScreen> createState() => _CrearLeyendaScreenState();
}

class _CrearLeyendaScreenState extends State<CrearLeyendaScreen> {
  final _leyendaService = LeyendaService();
  final _tituloController = TextEditingController();
  final _descripcionCortaController = TextEditingController();
  final _descripcionLargaController = TextEditingController();
  final _imagenController = TextEditingController();
  final _origenController = TextEditingController();
  final _personajeController = TextEditingController();
  final _horaAparicionController = TextEditingController();
  final _habitatController = TextEditingController();
  final _ritualController = TextEditingController();
  double _nivelDeTerror = 3.0;

  String? _departamentoSeleccionado;
  List<String> _personajes = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.leyendaAEditar != null) {
      final l = widget.leyendaAEditar!;
      _tituloController.text = l.titulo;
      _departamentoSeleccionado = l.departamento;
      _descripcionCortaController.text = l.descripcionCorta;
      _descripcionLargaController.text = l.descripcionLarga;
      _imagenController.text = l.imagen;
      _origenController.text = l.origen;
      _personajes = List.from(l.personajes);
      _horaAparicionController.text = l.horaAparicion;
      _habitatController.text = l.habitat;
      _ritualController.text = l.ritualDeProteccion;
      _nivelDeTerror = l.nivelDeTerror.toDouble();
    } else {
      _departamentoSeleccionado = 'cochabamba';
      _horaAparicionController.text = 'Durante la noche';
      _habitatController.text = 'Desconocido';
      _ritualController.text = 'No se conoce un ritual específico de protección. Mantente alerta.';
      _nivelDeTerror = 3.0;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionCortaController.dispose();
    _descripcionLargaController.dispose();
    _imagenController.dispose();
    _origenController.dispose();
    _personajeController.dispose();
    _horaAparicionController.dispose();
    _habitatController.dispose();
    _ritualController.dispose();
    super.dispose();
  }



  Future<void> _crearLeyenda() async {
    if (_tituloController.text.isEmpty ||
        _descripcionCortaController.text.isEmpty ||
        _descripcionLargaController.text.isEmpty ||
        _imagenController.text.isEmpty ||
        _origenController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor completa todos los campos';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw 'Usuario no autenticado';
      }

      final hora = _horaAparicionController.text.trim().isEmpty ? 'Durante la noche' : _horaAparicionController.text.trim();
      final habitat = _habitatController.text.trim().isEmpty ? 'Desconocido' : _habitatController.text.trim();
      final ritual = _ritualController.text.trim().isEmpty ? 'No se conoce un ritual específico de protección. Mantente alerta.' : _ritualController.text.trim();

      if (widget.leyendaAEditar != null) {
        await _leyendaService.actualizarLeyenda(
          id: widget.leyendaAEditar!.id,
          titulo: _tituloController.text.trim(),
          departamento: _departamentoSeleccionado!,
          descripcionCorta: _descripcionCortaController.text.trim(),
          descripcionLarga: _descripcionLargaController.text.trim(),
          imagen: _imagenController.text.trim(),
          origen: _origenController.text.trim(),
          nivelDeTerror: _nivelDeTerror.toInt(),
          horaAparicion: hora,
          habitat: habitat,
          ritualDeProteccion: ritual,
        );
      } else {
        await _leyendaService.crearLeyenda(
          userId: user.uid,
          titulo: _tituloController.text.trim(),
          departamento: _departamentoSeleccionado!,
          descripcionCorta: _descripcionCortaController.text.trim(),
          descripcionLarga: _descripcionLargaController.text.trim(),
          imagen: _imagenController.text.trim(),
          origen: _origenController.text.trim(),
          nivelDeTerror: _nivelDeTerror.toInt(),
          horaAparicion: hora,
          habitat: habitat,
          ritualDeProteccion: ritual,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.leyendaAEditar != null
                ? 'Leyenda actualizada exitosamente'
                : 'Leyenda creada exitosamente'),
            backgroundColor: const Color(0xFF2F6B5F),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.leyendaAEditar != null ? 'Editar leyenda' : 'Nueva leyenda',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF2E5D2),
              Color(0xFFF7F1E8),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2F6B5F),
                      Color(0xFF9E4F2E),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.leyendaAEditar != null
                          ? 'Edita tu historia'
                          : 'Crea una historia memorable',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.leyendaAEditar != null
                          ? 'Corrige detalles, personajes u origen para mantener la leyenda precisa.'
                          : 'Comparte personajes, origen y una version corta y completa para que otros puedan descubrirla.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            height: 1.45,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBE5E0),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Color(0xFF8A3D2C)),
                        ),
                      ),
                    _FieldLabel(
                      title: 'Titulo',
                      subtitle: 'El nombre con el que se recordara la leyenda.',
                    ),
                    TextField(
                      controller: _tituloController,
                      decoration: const InputDecoration(
                        labelText: 'Titulo de la leyenda',
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _FieldLabel(
                      title: 'Departamento',
                      subtitle: 'Ubica la historia en la region donde nace.',
                    ),
                    DropdownButtonFormField<String>(
                      value: _departamentoSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Departamento',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      items: departamentos
                          .map(
                            (dept) => DropdownMenuItem(
                              value: dept.id,
                              child: Text(dept.nombre),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _departamentoSeleccionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 18),
                    _FieldLabel(
                      title: 'Simbolo',
                      subtitle: 'Usa un emoji que represente la historia.',
                    ),
                    TextField(
                      controller: _imagenController,
                      maxLength: 2,
                      decoration: const InputDecoration(
                        labelText: 'Emoji o simbolo',
                        prefixIcon: Icon(Icons.emoji_emotions_outlined),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 18),
                    _FieldLabel(
                      title: 'Resumen corto',
                      subtitle: 'Aparece en la tarjeta principal.',
                    ),
                    TextField(
                      controller: _descripcionCortaController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Descripcion corta',
                        prefixIcon: Icon(Icons.short_text),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _FieldLabel(
                      title: 'Historia completa',
                      subtitle: 'Cuenta el relato con mas detalle.',
                    ),
                    TextField(
                      controller: _descripcionLargaController,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Descripcion completa',
                        prefixIcon: Icon(Icons.menu_book_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _FieldLabel(
                      title: 'Origen',
                      subtitle: 'Menciona la tradicion o comunidad de donde proviene.',
                    ),
                    TextField(
                      controller: _origenController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Origen o tradicion',
                        prefixIcon: Icon(Icons.public),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _FieldLabel(
                      title: 'Nivel de Terror (1 al 5)',
                      subtitle: '¿Qué tan aterradora es esta leyenda?',
                    ),
                    Row(
                      children: [
                        const Text('💀', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Slider(
                            value: _nivelDeTerror,
                            min: 1.0,
                            max: 5.0,
                            divisions: 4,
                            activeColor: const Color(0xFF9E4F2E),
                            inactiveColor: const Color(0xFFF1E2D0),
                            label: _nivelDeTerror.toInt().toString(),
                            onChanged: (value) {
                              setState(() {
                                _nivelDeTerror = value;
                              });
                            },
                          ),
                        ),
                        Text(
                          _nivelDeTerror.toInt().toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _FieldLabel(
                      title: 'Hora de aparición',
                      subtitle: 'Momento del día en el que se manifiesta.',
                    ),
                    TextField(
                      controller: _horaAparicionController,
                      decoration: const InputDecoration(
                        labelText: 'Ej. A la medianoche, Durante noches de tormenta',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _FieldLabel(
                      title: 'Hábitat',
                      subtitle: 'Lugar geográfico donde suele aparecer.',
                    ),
                    TextField(
                      controller: _habitatController,
                      decoration: const InputDecoration(
                        labelText: 'Ej. Senderos rurales, Minas profundas, Bosques nublados',
                        prefixIcon: Icon(Icons.forest_outlined),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _FieldLabel(
                      title: 'Ritual de protección / Guía de supervivencia',
                      subtitle: 'Qué hacer para salvarse si te encuentras con este ser.',
                    ),
                    TextField(
                      controller: _ritualController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Instrucciones de supervivencia...',
                        prefixIcon: Icon(Icons.shield_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _crearLeyenda,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.auto_stories),
                      label: Text(_isLoading
                          ? 'Guardando...'
                          : (widget.leyendaAEditar != null
                              ? 'Guardar cambios'
                              : 'Publicar leyenda')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String title;
  final String subtitle;

  const _FieldLabel({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF2F241F),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF6E5C52),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
