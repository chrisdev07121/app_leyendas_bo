import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/leyenda.dart';
import '../models/departamento.dart';
import '../services/leyenda_service.dart';
import '../services/auth_service.dart';
import 'detalle_screen.dart';
import 'crear_leyenda_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String departamentoSeleccionado;
  final _leyendaService = LeyendaService();
  final _authService = AuthService();
  final _searchController = TextEditingController();
  List<Leyenda> _leyendasFirebase = [];
  bool _cargandoFirebase = false;
  String _searchQuery = '';
  List<String> _favoritasIds = [];
  String _vistaGlobal = 'explorar'; // 'explorar', 'favoritos', 'mis_leyendas'

  @override
  void initState() {
    super.initState();
    departamentoSeleccionado = 'todos';
    _cargarLeyendasDeFirebase();
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoritasIds = prefs.getStringList('favoritos_ids') ?? [];
    });
  }

  Future<void> _toggleFavorito(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoritasIds.contains(id)) {
        _favoritasIds.remove(id);
      } else {
        _favoritasIds.add(id);
      }
      prefs.setStringList('favoritos_ids', _favoritasIds);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarLeyendasDeFirebase() async {
    setState(() {
      _cargandoFirebase = true;
    });
    try {
      final leyendas = await _leyendaService.obtenerTodasLasLeyendas();
      setState(() {
        _leyendasFirebase = leyendas;
      });
    } catch (e) {
      debugPrint('Error cargando de Firebase: $e');
    } finally {
      setState(() {
        _cargandoFirebase = false;
      });
    }
  }

  List<Leyenda> obtenerLeyendasFiltradas() {
    final todasLeyendas = [..._leyendasFirebase, ...leyendasEjemplo];
    final mapa = <String, Leyenda>{};
    for (var leyenda in todasLeyendas) {
      mapa[leyenda.id] = leyenda;
    }
    var resultado = mapa.values.toList();

    // 1. Filtrar por vista global (Mis Favoritas o Mis Leyendas)
    if (_vistaGlobal == 'favoritos') {
      resultado = resultado.where((leyenda) => _favoritasIds.contains(leyenda.id)).toList();
    } else if (_vistaGlobal == 'mis_leyendas') {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        resultado = resultado.where((leyenda) => leyenda.userId == user.uid).toList();
      }
    }

    // 2. Filtrar por departamento (si no es 'todos')
    if (departamentoSeleccionado != 'todos') {
      resultado = resultado.where((leyenda) => leyenda.departamento == departamentoSeleccionado).toList();
    }

    // 3. Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      resultado = resultado.where((leyenda) {
        return leyenda.titulo.toLowerCase().contains(query) ||
            leyenda.descripcionCorta.toLowerCase().contains(query) ||
            leyenda.descripcionLarga.toLowerCase().contains(query) ||
            leyenda.origen.toLowerCase().contains(query);
      }).toList();
    }

    return resultado;
  }

  Future<void> _navegarACrearLeyenda() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      if (result == true) {
        if (!mounted) return;
        setState(() {});
        final authUser = FirebaseAuth.instance.currentUser;
        if (authUser != null) {
          final createResult = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CrearLeyendaScreen()),
          );
          if (createResult == true) {
            _cargarLeyendasDeFirebase();
          }
        }
      }
    } else {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CrearLeyendaScreen()),
      );
      if (result == true) {
        _cargarLeyendasDeFirebase();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final leyendasFiltradas = obtenerLeyendasFiltradas();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Leyendas Bolivianas',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'Miénteme',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.auto_stories, size: 50, color: Color(0xFF2F6B5F)),
                children: [
                  const Text('Desarrollador: Chris'),
                  const SizedBox(height: 8),
                  const Text('Correo: chris.dev.0712@gmail.com'),
                  const SizedBox(height: 8),
                  const Text('Cel: 75949161'),
                ],
              );
            },
          ),
          if (user != null)
            PopupMenuButton<String>(
              icon: CircleAvatar(
                backgroundColor: const Color(0xFF9E4F2E),
                child: Text(
                  (user.displayName ?? user.email ?? 'U')
                      .trim()
                      .substring(0, 1)
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onSelected: (value) async {
                if (value == 'logout') {
                  await _authService.signOut();
                  if (mounted) {
                    setState(() {
                      _vistaGlobal = 'explorar';
                    });
                  }
                }
              },
              itemBuilder: (context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'profile',
                  enabled: false,
                  child: Text(user.displayName ?? user.email ?? 'Usuario'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: const Row(
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text('Cerrar sesion'),
                    ],
                  ),
                ),
              ],
            )
          else
            TextButton.icon(
              onPressed: _navegarACrearLeyenda,
              icon: const Icon(Icons.login),
              label: const Text('Entrar'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarLeyendasDeFirebase,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: _HeroSection(
                  user: user,
                  totalLeyendas: leyendasFiltradas.length,
                  onCreate: _navegarACrearLeyenda,
                ),
              ),
            ),
            // ── Barra de búsqueda ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: _SearchBar(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onClear: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  hasQuery: _searchQuery.isNotEmpty,
                ),
              ),
            ),
            // ── Sección de Filtros Globales (Biblioteca / Exploración) ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Explorar todo 🌎'),
                        selected: _vistaGlobal == 'explorar',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _vistaGlobal = 'explorar';
                            });
                          }
                        },
                        avatar: Icon(
                          _vistaGlobal == 'explorar' ? Icons.explore : Icons.explore_outlined,
                          size: 18,
                          color: _vistaGlobal == 'explorar' ? Colors.white : const Color(0xFF7A5C4D),
                        ),
                        backgroundColor: Colors.white.withOpacity(0.75),
                        selectedColor: const Color(0xFF2F6B5F),
                        labelStyle: TextStyle(
                          color: _vistaGlobal == 'explorar' ? Colors.white : const Color(0xFF3B2C25),
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text('Favoritas ❤️'),
                        selected: _vistaGlobal == 'favoritos',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _vistaGlobal = 'favoritos';
                            });
                          }
                        },
                        avatar: Icon(
                          _vistaGlobal == 'favoritos' ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: _vistaGlobal == 'favoritos' ? Colors.white : const Color(0xFFE57373),
                        ),
                        backgroundColor: Colors.white.withOpacity(0.75),
                        selectedColor: const Color(0xFFC84B31),
                        labelStyle: TextStyle(
                          color: _vistaGlobal == 'favoritos' ? Colors.white : const Color(0xFF3B2C25),
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      if (user != null) ...[
                        const SizedBox(width: 10),
                        ChoiceChip(
                          label: const Text('Mis leyendas ✍️'),
                          selected: _vistaGlobal == 'mis_leyendas',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _vistaGlobal = 'mis_leyendas';
                              });
                            }
                          },
                          avatar: Icon(
                            _vistaGlobal == 'mis_leyendas' ? Icons.edit_document : Icons.edit_note,
                            size: 18,
                            color: _vistaGlobal == 'mis_leyendas' ? Colors.white : const Color(0xFF7A5C4D),
                          ),
                          backgroundColor: Colors.white.withOpacity(0.75),
                          selectedColor: const Color(0xFF9E4F2E),
                          labelStyle: TextStyle(
                            color: _vistaGlobal == 'mis_leyendas' ? Colors.white : const Color(0xFF3B2C25),
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SectionTitle(
                  title: 'Explora por departamento',
                  subtitle: 'Elige una region y descubre sus historias vivas.',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 62,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  scrollDirection: Axis.horizontal,
                  itemCount: departamentos.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isSelected = departamentoSeleccionado == 'todos';
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: const Text('Toda Bolivia 🇧🇴'),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                departamentoSeleccionado = 'todos';
                              });
                            }
                          },
                          avatar: Icon(
                            isSelected ? Icons.map : Icons.map_outlined,
                            size: 18,
                            color: isSelected ? Colors.white : const Color(0xFF7A5C4D),
                          ),
                          backgroundColor: Colors.white.withOpacity(0.75),
                          selectedColor: const Color(0xFF9E4F2E),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF3B2C25),
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      );
                    }

                    final dept = departamentos[index - 1];
                    final isSelected = dept.id == departamentoSeleccionado;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(dept.nombre),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              departamentoSeleccionado = dept.id;
                            }
                          });
                        },
                        avatar: Icon(
                          isSelected ? Icons.auto_stories : Icons.location_on_outlined,
                          size: 18,
                          color: isSelected ? Colors.white : const Color(0xFF7A5C4D),
                        ),
                        backgroundColor: Colors.white.withOpacity(0.75),
                        selectedColor: const Color(0xFF9E4F2E),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF3B2C25),
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _InfoBanner(
                        icon: _searchQuery.isNotEmpty 
                            ? Icons.public 
                            : (_vistaGlobal == 'favoritos'
                                ? Icons.favorite
                                : (_vistaGlobal == 'mis_leyendas'
                                    ? Icons.edit_document
                                    : (departamentoSeleccionado == 'todos'
                                        ? Icons.map
                                        : Icons.place_outlined))),
                        title: _searchQuery.isNotEmpty 
                            ? 'Buscando en Bolivia' 
                            : (_vistaGlobal == 'favoritos'
                                ? 'Mis Favoritas'
                                : (_vistaGlobal == 'mis_leyendas'
                                    ? 'Mis Publicaciones'
                                    : (departamentoSeleccionado == 'todos'
                                        ? 'Toda Bolivia'
                                        : _nombreDepartamento(departamentoSeleccionado)))),
                        subtitle: '${leyendasFiltradas.length} relatos encontrados',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoBanner(
                        icon: user != null ? Icons.edit_note : Icons.lock_outline,
                        title: user != null ? 'Modo creador' : 'Modo lector',
                        subtitle: user != null
                            ? 'Puedes publicar nuevas leyendas'
                            : 'Ingresa para compartir historias',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_cargandoFirebase)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (leyendasFiltradas.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: const Icon(
                            Icons.menu_book_outlined,
                            size: 42,
                            color: Color(0xFF9E4F2E),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Todavia no hay leyendas aqui',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2F241F),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Prueba con otro departamento o agrega una nueva historia.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF6E5C52),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final leyenda = leyendasFiltradas[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: LeyendaCard(
                          leyenda: leyenda,
                          isFavorited: _favoritasIds.contains(leyenda.id),
                          onFavoriteToggle: () => _toggleFavorito(leyenda.id),
                          onTap: () async {
                            final refreshed = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetalleScreen(leyenda: leyenda),
                              ),
                            );
                            _cargarFavoritos();
                            if (refreshed == true) {
                              _cargarLeyendasDeFirebase();
                            }
                          },
                        ),
                      );
                    },
                    childCount: leyendasFiltradas.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navegarACrearLeyenda,
        backgroundColor: const Color(0xFF2F6B5F),
        foregroundColor: Colors.white,
        icon: Icon(user != null ? Icons.auto_stories : Icons.login),
        label: Text(user != null ? 'Nueva leyenda' : 'Entrar y crear'),
      ),
    );
  }

  String _nombreDepartamento(String id) {
    if (id == 'todos') return 'Toda Bolivia';
    return departamentos.firstWhere((dept) => dept.id == id).nombre;
  }
}

class _HeroSection extends StatelessWidget {
  final User? user;
  final int totalLeyendas;
  final VoidCallback onCreate;

  const _HeroSection({
    required this.user,
    required this.totalLeyendas,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2F6B5F),
            Color(0xFF9E4F2E),
            Color(0xFFD39A52),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9E4F2E).withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Archivo vivo de mitos bolivianos',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            user != null
                ? 'Bienvenido, ${user!.displayName ?? 'guardian de historias'}'
                : 'Viaja por relatos, simbolos y memorias del pais',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            user != null
                ? 'Explora, filtra y suma nuevas leyendas desde tu cuenta.'
                : 'Descubre leyendas por departamento y entra para publicar las tuyas.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  value: '$totalLeyendas',
                  label: 'Historias en vista',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeroMetric(
                  value: user != null ? 'Activo' : 'Invitado',
                  label: user != null ? 'Estado de cuenta' : 'Modo actual',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: onCreate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2F241F),
            ),
            icon: Icon(user != null ? Icons.add_circle_outline : Icons.login),
            label: Text(user != null ? 'Compartir una leyenda' : 'Entrar para publicar'),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String value;
  final String label;

  const _HeroMetric({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.86),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2F241F),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6E5C52),
                ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool hasQuery;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.hasQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4A37).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF2F241F),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar leyendas, personajes, lugares...',
          hintStyle: TextStyle(
            color: const Color(0xFF6E5C52).withOpacity(0.5),
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          prefixIcon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              hasQuery ? Icons.search : Icons.search_outlined,
              key: ValueKey(hasQuery),
              color: hasQuery
                  ? const Color(0xFF2F6B5F)
                  : const Color(0xFF9E4F2E).withOpacity(0.5),
              size: 22,
            ),
          ),
          suffixIcon: hasQuery
              ? IconButton(
                  onPressed: onClear,
                  icon: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9E4F2E).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xFF9E4F2E),
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoBanner({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF1E2D0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF9E4F2E), size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2F241F),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6E5C52),
                    fontSize: 11,
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

class LeyendaCard extends StatelessWidget {
  final Leyenda leyenda;
  final VoidCallback onTap;
  final bool isFavorited;
  final VoidCallback onFavoriteToggle;

  const LeyendaCard({
    super.key,
    required this.leyenda,
    required this.onTap,
    required this.isFavorited,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFCF8),
              Color(0xFFF2E5D2),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B4A37).withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      leyenda.imagen,
                      style: const TextStyle(fontSize: 38),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F6B5F).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            leyenda.departamento.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF2F6B5F),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          leyenda.titulo,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF2F241F),
                                height: 1.1,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                leyenda.descripcionCorta,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5C4A41),
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Color(0xFF9E4F2E)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      leyenda.departamento.replaceAll('_', ' '),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6E5C52),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: isFavorited ? const Color(0xFFC84B31) : const Color(0xFF6E5C52),
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF9E4F2E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
