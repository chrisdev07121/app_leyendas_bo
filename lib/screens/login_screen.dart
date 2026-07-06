import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleAuthAction() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor completa todos los campos';
      });
      return;
    }

    if (!_isLogin && _nameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa tu nombre';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        await _authService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await _authService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );
      }

      if (mounted) {
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF285A55),
              Color(0xFFCD8A47),
              Color(0xFFF7F1E8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _AuthHeader(),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.88),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isLogin ? 'Inicia sesion' : 'Crea tu cuenta',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF2F241F),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLogin
                              ? 'Accede para guardar y compartir nuevas historias.'
                              : 'Registrate para convertirte en guardian de leyendas.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF6E5C52),
                                height: 1.4,
                              ),
                        ),
                        const SizedBox(height: 20),
                        if (!_isLogin)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre completo',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.alternate_email),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Contrasena',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
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
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleAuthAction,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(_isLogin ? 'Entrar ahora' : 'Crear cuenta'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                    _errorMessage = null;
                                    _nameController.clear();
                                    _emailController.clear();
                                    _passwordController.clear();
                                  });
                                },
                          child: Text(
                            _isLogin
                                ? 'No tienes cuenta? Registrate'
                                : 'Ya tienes cuenta? Inicia sesion',
                          ),
                        ),
                        if (_isLogin)
                          TextButton.icon(
                            onPressed: () async {
                              if (_emailController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ingresa tu email primero'),
                                  ),
                                );
                                return;
                              }
                              await _authService.resetPassword(_emailController.text.trim());
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Email de recuperacion enviado'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.mark_email_read_outlined),
                            label: const Text('Recuperar contrasena'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _AuthFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: const Text(
            '📜',
            style: TextStyle(fontSize: 38),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Leyendas de Bolivia',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          'Una coleccion de historias, simbolos y memorias para leer y compartir.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
                height: 1.45,
              ),
        ),
      ],
    );
  }
}

class _AuthFooter extends StatelessWidget {
  const _AuthFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.62),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_stories_outlined, color: Color(0xFF2F6B5F)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Lee libremente y entra cuando quieras aportar una nueva leyenda.',
              style: TextStyle(
                color: Color(0xFF51433B),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
