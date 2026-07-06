import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/leyenda.dart';
import '../models/comentario.dart';
import '../models/quiz_data.dart';
import '../services/leyenda_service.dart';
import '../services/share_service.dart';
import 'login_screen.dart';
import 'crear_leyenda_screen.dart';

class DetalleScreen extends StatefulWidget {
  final Leyenda leyenda;

  const DetalleScreen({
    super.key,
    required this.leyenda,
  });

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  // Avistamientos
  bool _sightingReported = false;
  int _sightingsCount = 0;

  // Quiz
  bool _quizUnlocked = false;
  int _quizStep = -1; // -1: no iniciado, 0..N: pregunta actual, 100: fallido
  int _selectedAnswerIndex = -1;
  bool _answerSubmitted = false;
  int _correctAnswersCount = 0;

  // Favoritos y Calificación
  bool _isFavorited = false;
  double _userRating = 0.0;
  bool _ratingSubmitted = false;

  // Comentarios
  final _commentController = TextEditingController();
  final _leyendaService = LeyendaService();
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final sightingKey = 'sighting_${widget.leyenda.id}';
    final quizKey = 'quiz_unlocked_${widget.leyenda.id}';
    final ratingKey = 'rating_${widget.leyenda.id}';
    final favoritesList = prefs.getStringList('favoritos_ids') ?? [];

    // Generar un número base estable de avistamientos basado en el hash del título
    final baseCount = 0;
    final reported = prefs.getBool(sightingKey) ?? false;
    final rating = prefs.getDouble(ratingKey) ?? 0.0;

    setState(() {
      _sightingReported = reported;
      _sightingsCount = baseCount + (reported ? 1 : 0);
      _quizUnlocked = prefs.getBool(quizKey) ?? false;
      _isFavorited = favoritesList.contains(widget.leyenda.id);
      _userRating = rating;
      _ratingSubmitted = rating > 0;
    });
  }

  Future<void> _reportSighting() async {
    if (_sightingReported) return;
    final prefs = await SharedPreferences.getInstance();
    final sightingKey = 'sighting_${widget.leyenda.id}';
    await prefs.setBool(sightingKey, true);
    setState(() {
      _sightingReported = true;
      _sightingsCount += 1;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '¡Avistamiento registrado! Tu reporte se ha sumado al registro folclórico.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF9E4F2E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Debes iniciar sesión para agregar a favoritos',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFC84B31),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          action: SnackBarAction(
            label: 'Ingresar',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              ).then((value) {
                if (value == true) {
                  _loadInitialData();
                }
              });
            },
          ),
        ),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final favoritesList = prefs.getStringList('favoritos_ids') ?? [];
    setState(() {
      if (_isFavorited) {
        favoritesList.remove(widget.leyenda.id);
        _isFavorited = false;
      } else {
        favoritesList.add(widget.leyenda.id);
        _isFavorited = true;
      }
    });
    await prefs.setStringList('favoritos_ids', favoritesList);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorited 
                ? 'Agregada a tus leyendas favoritas ❤️' 
                : 'Eliminada de tus favoritos 💔',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF2F6B5F),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  Future<void> _submitRating(double rating) async {
    if (_ratingSubmitted) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('rating_${widget.leyenda.id}', rating);
    setState(() {
      _userRating = rating;
      _ratingSubmitted = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Gracias por calificar con ${rating.toInt()} estrellas! ⭐',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF2F6B5F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  Future<void> _navegarAEditar() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearLeyendaScreen(leyendaAEditar: widget.leyenda),
      ),
    );
    if (result == true) {
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _confirmarEliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar leyenda?'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta leyenda? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _leyendaService.eliminarLeyenda(widget.leyenda.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Leyenda eliminada exitosamente'),
              backgroundColor: Color(0xFF2F6B5F),
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildTerrorSkulls(int level) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Opacity(
          opacity: index < level ? 1.0 : 0.2,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.0),
            child: Text(
              '💀',
              style: TextStyle(fontSize: 13),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuizSection(List<QuizPregunta> questions, String amuletName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2420), // Fondo misterioso oscuro
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD39A52).withOpacity(0.4),
          width: 1,
        ),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  color: Color(0xFFD39A52),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test de Valentía',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _quizUnlocked 
                            ? 'Amuleto obtenido' 
                            : 'Demuestra tu conocimiento y obtén protección',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_quizUnlocked)
              _buildUnlockedQuizView(amuletName)
            else if (_quizStep == -1)
              _buildStartQuizView(questions.length)
            else if (_quizStep >= 0 && _quizStep < questions.length)
              _buildQuestionQuizView(questions[_quizStep], _quizStep, questions.length)
            else if (_quizStep == 100)
              _buildFailedQuizView()
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockedQuizView(String amuletName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3D37), // Verde místico
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2F6B5F), width: 1),
      ),
      child: Column(
        children: [
          const Text(
            '🛡️',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 8),
          const Text(
            '¡INMUNIDAD CONSEGUIDA!',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFFD39A52),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amuletName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Este amuleto se ha registrado en tu diario y te protege contra la maldición de ${widget.leyenda.titulo}.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _quizStep = 0;
                _quizUnlocked = false;
                _selectedAnswerIndex = -1;
                _answerSubmitted = false;
                _correctAnswersCount = 0;
              });
            },
            child: const Text(
              'Volver a realizar el test',
              style: TextStyle(
                color: Color(0xFFD39A52),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartQuizView(int totalQuestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Conoces a fondo el relato de ${widget.leyenda.titulo}? Responde correctamente las $totalQuestions preguntas de la trivia para desbloquear tu Amuleto de Protección digital y registrar tu valentía.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _quizStep = 0;
                _selectedAnswerIndex = -1;
                _answerSubmitted = false;
                _correctAnswersCount = 0;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD39A52),
              foregroundColor: const Color(0xFF2E2420),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Iniciar Test de Valentía',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionQuizView(QuizPregunta question, int step, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PREGUNTA ${step + 1} DE $total',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD39A52),
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'Aciertos: $_correctAnswersCount',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          question.pregunta,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(question.opciones.length, (index) {
          final optionText = question.opciones[index];
          final isCorrectOption = index == question.respuestaCorrectaIndex;
          final isSelectedOption = index == _selectedAnswerIndex;

          Color btnColor = Colors.white.withOpacity(0.06);
          Color textColor = Colors.white.withOpacity(0.9);
          Border? border;

          if (_answerSubmitted) {
            if (isCorrectOption) {
              btnColor = const Color(0xFF1E3D37); // Verde para correcto
              textColor = const Color(0xFF4CAF50);
              border = Border.all(color: const Color(0xFF4CAF50), width: 1.5);
            } else if (isSelectedOption) {
              btnColor = const Color(0xFF3D231E); // Rojo para incorrecto seleccionado
              textColor = const Color(0xFFF44336);
              border = Border.all(color: const Color(0xFFF44336), width: 1.5);
            } else {
              textColor = Colors.white.withOpacity(0.4);
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _answerSubmitted
                    ? null
                    : () {
                        setState(() {
                          _selectedAnswerIndex = index;
                          _answerSubmitted = true;
                          if (isCorrectOption) {
                            _correctAnswersCount += 1;
                          }
                        });
                      },
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: btnColor,
                    borderRadius: BorderRadius.circular(14),
                    border: border ?? Border.all(color: Colors.white.withOpacity(0.12), width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          optionText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (_answerSubmitted && isCorrectOption)
                        const Icon(Icons.check_circle_outline, color: Color(0xFF4CAF50), size: 20)
                      else if (_answerSubmitted && isSelectedOption && !isCorrectOption)
                        const Icon(Icons.cancel_outlined, color: Color(0xFFF44336), size: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        if (_answerSubmitted) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFFD39A52), size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Explicación',
                      style: TextStyle(
                        color: Color(0xFFD39A52),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  question.explicacion,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                if (step + 1 < total) {
                  setState(() {
                    _quizStep += 1;
                    _selectedAnswerIndex = -1;
                    _answerSubmitted = false;
                  });
                } else {
                  // Finalizar
                  if (_correctAnswersCount == total) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('quiz_unlocked_${widget.leyenda.id}', true);
                    setState(() {
                      _quizUnlocked = true;
                    });
                  } else {
                    setState(() {
                      _quizStep = 100; // Estado fallido
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD39A52),
                foregroundColor: const Color(0xFF2E2420),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    step + 1 < total ? 'Siguiente Pregunta' : 'Finalizar Test',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFailedQuizView() {
    return Column(
      children: [
        const Text(
          '💔',
          style: TextStyle(fontSize: 48),
        ),
        const SizedBox(height: 8),
        const Text(
          'TEST FALLIDO',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFFC84B31),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Has obtenido $_correctAnswersCount respuestas correctas. Para conseguir el amuleto debes superar todo el test sin cometer errores.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _quizStep = 0;
                _selectedAnswerIndex = -1;
                _answerSubmitted = false;
                _correctAnswersCount = 0;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC84B31),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Volver a intentarlo',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4A37).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFD39A52)),
              const SizedBox(width: 10),
              const Text(
                'Calificación y reseñas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2F241F),
                ),
              ),
              const Spacer(),
              Text(
                (3.5 + (widget.leyenda.titulo.hashCode % 15) / 10.0).toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F241F),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, color: Color(0xFFD39A52), size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _ratingSubmitted 
                ? '¡Gracias por calificar!' 
                : '¿Qué te pareció este relato? Califica con estrellas:',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6E5C52)),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1.0;
              final isFilled = starValue <= _userRating;
              return IconButton(
                onPressed: _ratingSubmitted ? null : () => _submitRating(starValue),
                icon: Icon(
                  isFilled ? Icons.star : Icons.star_border,
                  color: const Color(0xFFD39A52),
                  size: 36,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(User? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4A37).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.comment_outlined, color: Color(0xFF2F6B5F)),
              SizedBox(width: 10),
              Text(
                'Comentarios de la Comunidad',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2F241F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Lista de comentarios con StreamBuilder
          StreamBuilder<List<Comentario>>(
            stream: _leyendaService.streamComentarios(widget.leyenda.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(
                  'Error al cargar comentarios: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              final comentarios = snapshot.data ?? [];
              if (comentarios.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'No hay comentarios todavía. ¡Sé el primero en comentar!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF6E5C52), fontSize: 12),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comentarios.length,
                itemBuilder: (context, index) {
                  final comentario = comentarios[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F1E8).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                comentario.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: Color(0xFF7A4A33),
                                ),
                              ),
                              Text(
                                '${comentario.createdAt.day}/${comentario.createdAt.month} ${comentario.createdAt.hour}:${comentario.createdAt.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: const Color(0xFF6E5C52).withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            comentario.texto,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF2F241F),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          // Formulario para agregar comentario
          if (user == null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2F6B5F).withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, color: Color(0xFF2F6B5F), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Inicia sesión para poder comentar.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2F6B5F),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'ENTRAR',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9E4F2E),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un comentario...',
                      hintStyle: TextStyle(color: const Color(0xFF6E5C52).withOpacity(0.5)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: const Color(0xFF6E5C52).withOpacity(0.2)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _enviarComentario(user),
                  ),
                ),
                const SizedBox(width: 10),
                _isSubmittingComment
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF2F6B5F)),
                        onPressed: () => _enviarComentario(user),
                      ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _enviarComentario(User user) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSubmittingComment = true;
    });

    try {
      final name = user.displayName ?? user.email?.split('@')[0] ?? 'Anónimo';
      await _leyendaService.agregarComentario(
        leyendaId: widget.leyenda.id,
        userId: user.uid,
        userName: name,
        texto: text,
      );
      _commentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar comentario: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingComment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizQuestions = quizPorLeyenda[widget.leyenda.id];
    final amuletName = amuletosPorLeyenda[widget.leyenda.id];
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F1E8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF2F6B5F),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorited ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
              if (currentUser != null && widget.leyenda.userId == currentUser.uid) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  tooltip: 'Editar leyenda',
                  onPressed: _navegarAEditar,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  tooltip: 'Eliminar leyenda',
                  onPressed: _confirmarEliminar,
                ),
              ],
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: 20,
                bottom: 20,
                end: 20,
              ),
              title: Text(
                widget.leyenda.titulo,
                maxLines: 2,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2F6B5F),
                      Color(0xFF9E4F2E),
                      Color(0xFFD39A52),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 88, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          widget.leyenda.departamento.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          widget.leyenda.imagen,
                          style: const TextStyle(fontSize: 108),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Cuadrícula de estadísticas míticas (2x2) ──
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _InfoPanel(
                              icon: Icons.place_outlined,
                              label: 'DEPARTAMENTO',
                              child: Text(
                                widget.leyenda.departamento.replaceAll('_', ' ').toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF2F241F),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoPanel(
                              icon: Icons.warning_amber_outlined,
                              label: 'PELIGRO / TERROR',
                              child: _buildTerrorSkulls(widget.leyenda.nivelDeTerror),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoPanel(
                              icon: Icons.access_time_outlined,
                              label: 'HORA ACTIVA',
                              child: Text(
                                widget.leyenda.horaAparicion,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF2F241F),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoPanel(
                              icon: Icons.forest_outlined,
                              label: 'HÁBITAT',
                              child: Text(
                                widget.leyenda.habitat,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF2F241F),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Sección de la Historia ──
                  _StorySection(
                    title: 'La historia',
                    icon: Icons.auto_stories_outlined,
                    child: Text(
                      widget.leyenda.descripcionLarga,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.7,
                            color: const Color(0xFF4C3E36),
                          ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Guía de Supervivencia (Ritual de protección) ──
                  _SurvivalGuideSection(
                    content: widget.leyenda.ritualDeProteccion,
                  ),
                  const SizedBox(height: 20),

                  // ── Origen ──
                  _StorySection(
                    title: 'Origen',
                    icon: Icons.public,
                    child: Text(
                      widget.leyenda.origen,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF4C3E36),
                            height: 1.6,
                          ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Botón contador de avistamientos ──
                  _SightingCounterCard(
                    count: _sightingsCount,
                    reported: _sightingReported,
                    onReport: _reportSighting,
                  ),
                  const SizedBox(height: 20),

                  // ── Calificación con Estrellas ──
                  _buildRatingSection(),
                  const SizedBox(height: 20),                  // ── Comentarios de la Comunidad ──
                  _buildCommentsSection(currentUser),
                  const SizedBox(height: 20),

                  // ── Compartir ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showShareBottomSheet(context),
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Compartir leyenda'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showShareBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF7F1E8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Handle ──
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBBA898),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                // ── Título ──
                const Row(
                  children: [
                    Icon(Icons.share_outlined,
                        color: Color(0xFF2F6B5F), size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Compartir Leyenda',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2F241F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Elige cómo quieres compartir esta leyenda',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7A6B5E),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // ── Opciones ──
                _ShareOptionTile(
                  icon: Icons.textsms_outlined,
                  color: const Color(0xFF2F6B5F),
                  title: 'Compartir como texto',
                  subtitle: 'Envía la leyenda completa como mensaje',
                  onTap: () => _executeShare(
                    context,
                    ctx,
                    () => ShareService.shareAsText(widget.leyenda),
                  ),
                ),
                const SizedBox(height: 10),
                _ShareOptionTile(
                  icon: Icons.picture_as_pdf_outlined,
                  color: const Color(0xFF9E4F2E),
                  title: 'Compartir como PDF',
                  subtitle: 'Genera un documento PDF con diseño',
                  onTap: () => _executeShare(
                    context,
                    ctx,
                    () => ShareService.shareAsPdf(widget.leyenda),
                  ),
                ),
                const SizedBox(height: 10),
                _ShareOptionTile(
                  icon: Icons.image_outlined,
                  color: const Color(0xFFD39A52),
                  title: 'Compartir como imagen',
                  subtitle: 'Crea una tarjeta visual para redes sociales',
                  onTap: () => _executeShare(
                    context,
                    ctx,
                    () => ShareService.shareAsImage(widget.leyenda, context),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _executeShare(
    BuildContext pageContext,
    BuildContext sheetContext,
    Future<void> Function() shareAction,
  ) async {
    Navigator.pop(sheetContext);

    // Mostrar indicador de carga
    showDialog(
      context: pageContext,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF2F6B5F),
                ),
                SizedBox(height: 16),
                Text(
                  'Preparando...',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2F241F),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      await shareAction();
    } catch (e) {
      if (pageContext.mounted) {
        ScaffoldMessenger.of(pageContext).showSnackBar(
          SnackBar(
            content: Text('Error al compartir: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (pageContext.mounted) {
        Navigator.of(pageContext).pop(); // Cerrar loading dialog
      }
    }
  }
}

/// Tile de opción para el bottom sheet de compartir
class _ShareOptionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ShareOptionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2F241F),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7A6B5E),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: color.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _InfoPanel({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4A37).withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2F6B5F), size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6E5C52),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

class _StorySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _StorySection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF9E4F2E)),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2F241F),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SightingCounterCard extends StatelessWidget {
  final int count;
  final bool reported;
  final VoidCallback onReport;

  const _SightingCounterCard({
    required this.count,
    required this.reported,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4A37).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1E2D0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.visibility_outlined,
                  color: Color(0xFF9E4F2E),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Registro de Presencias',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2F241F),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$count personas reportan haber sentido su presencia.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6E5C52),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: reported ? null : onReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9E4F2E),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFD3C5BC),
                disabledForegroundColor: const Color(0xFF7A6B5E),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(reported ? Icons.check_circle : Icons.front_hand, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    reported ? '¡Presencia Registrada!' : '¡Yo viví un avistamiento!',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SurvivalGuideSection extends StatelessWidget {
  final String content;

  const _SurvivalGuideSection({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF7F0), // Color pergamino cálido
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD39A52).withOpacity(0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: Color(0xFF9E4F2E),
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'Guía de Supervivencia',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Color(0xFF7A4A33),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              fontStyle: FontStyle.italic,
              color: Color(0xFF5D4037),
            ),
          ),
        ],
      ),
    );
  }
}


