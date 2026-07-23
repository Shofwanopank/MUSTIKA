import 'package:flutter/material.dart';
import '../theme/bakery_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Mimic network call
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Layers
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    BakeryTheme.background,
                    BakeryTheme.surfaceContainerLow,
                    Color(0x33FFDBC9),
                  ],
                ),
              ),
            ),
          ),
          // Floating Blur Elements
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BakeryTheme.primary.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BakeryTheme.tertiary.withOpacity(0.05),
              ),
            ),
          ),
          // Main Scrollable Area
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Branding Header
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: BakeryTheme.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bakery_dining_outlined,
                        color: BakeryTheme.onPrimaryContainer,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Roti Mustika',
                      style: textTheme.headlineLarge?.copyWith(
                        color: BakeryTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'BAKERY ADMIN PORTAL',
                      style: textTheme.labelLarge?.copyWith(
                        color: BakeryTheme.secondary.withOpacity(0.8),
                        letterSpacing: 3.0,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Login Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome Back',
                                style: textTheme.headlineMedium?.copyWith(
                                  color: BakeryTheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Please enter your credentials to manage the bakery.',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: BakeryTheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Username Field
                              Text(
                                'Username or Email',
                                style: textTheme.labelLarge?.copyWith(
                                  color: BakeryTheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _usernameController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  hintText: 'admin@rotimustika.com',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Username/Email is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // Password Field
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Password',
                                    style: textTheme.labelLarge?.copyWith(
                                      color: BakeryTheme.secondary,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Password reset link sent to registered email.'),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: BakeryTheme.tertiary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: '••••••••',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (value.length < 4) {
                                    return 'Password must be at least 4 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Remember Me
                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      activeColor: BakeryTheme.primary,
                                      onChanged: (val) {
                                        setState(() {
                                          _rememberMe = val ?? false;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Stay logged in for 30 days',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: BakeryTheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  child: _isLoading
                                      ? const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: BakeryTheme.onPrimary,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text('Authenticating...'),
                                          ],
                                        )
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('Login to Dashboard'),
                                            SizedBox(width: 8),
                                            Icon(Icons.arrow_forward),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Help Link
                              Center(
                                child: RichText(
                                  text: TextSpan(
                                    style: textTheme.labelSmall?.copyWith(
                                      color: BakeryTheme.onSurfaceVariant,
                                    ),
                                    children: const [
                                      TextSpan(text: 'Need assistance? '),
                                      TextSpan(
                                        text: 'Contact System Admin',
                                        style: TextStyle(
                                          color: BakeryTheme.tertiary,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Image/Brand Context Cards (Drawn in layout for aesthetics)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildImageContextCard(
                          context,
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuD0ztW3PMLKNqacQqiDaUCxQ6tJF1FoRAdO_nBxOAegKtYr3PudvFERVosZd3QSiZtihq3k3gZuXEM1-Mc1-pjOzww8oFM9cDob9KZwu3cIr-GY6yNmjMTjQUmH5u1kXbV5luxrLbVAlT5cXwU5reqW86I2sLzAbf2ENjypno1hhOg3HVcxJVxkUomlz7SxIUSxFMmafQUYRaR2PM1-99Fn1GsTX1PC15lS1za8KPcZlDWkLB9xs4tlNp_lpv16_A6I3eOycidA',
                          'Sourdough',
                        ),
                        const SizedBox(width: 16),
                        _buildImageContextCard(
                          context,
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBZ2xadN2261eG-fgbVD5VQYXDvGJM5p24LLMByClJZWCaDYqC5KGhc6i8HROP95Kgg3ZVXhbnXH7HDOYo4kzB2gBgK_rhXBmTDu2zUH1ucYqtA-I8uP3XlDHU_ZugAoQRe5wcjjSdpe_FrnRg3uyVwHTPHLu8un7X8uhPCp1Vt7Rh8ahRLAlH7tsIzZj2iftpnltKzLp6VKHZyOY1afHv4RvAYuy3XQkH_HBu7cOnA5isKwQnYkHVj_zRVDxCEs_1j5nBS6xpJ',
                          'Kitchen',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '© 2024 Roti Mustika',
                          style: textTheme.labelSmall?.copyWith(
                            color: BakeryTheme.onSurfaceVariant.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: BakeryTheme.outlineVariant.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Version 2.4.0 (Stable)',
                          style: textTheme.labelSmall?.copyWith(
                            color: BakeryTheme.onSurfaceVariant.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContextCard(BuildContext context, String url, String label) {
    return Container(
      width: 120,
      height: 48,
      decoration: BoxDecoration(
        color: BakeryTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BakeryTheme.outlineVariant.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: BakeryTheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
            );
          },
        ),
      ),
    );
  }
}
