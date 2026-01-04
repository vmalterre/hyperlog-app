import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyperlog/session_state.dart';
import 'package:hyperlog/services/auth_service.dart';
import 'package:hyperlog/services/error_service.dart';
import 'package:hyperlog/utils/validator.dart';
import 'package:hyperlog/theme/app_colors.dart';
import 'package:hyperlog/theme/app_typography.dart';
import 'package:hyperlog/widgets/glass_card.dart';
import 'package:hyperlog/widgets/app_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String? _errorMessage;
  bool _isLoading = false;

  // Animation controllers
  late AnimationController _gridPulseController;
  late AnimationController _floatController;
  late Animation<double> _gridOpacity;

  @override
  void initState() {
    super.initState();

    // Grid pulse animation (8 second cycle)
    _gridPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _gridOpacity = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _gridPulseController, curve: Curves.easeInOut),
    );

    // Float animation for nodes (20 second cycle)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  Future<void> _signUp() async {
    if (_isLoading) return;

    String email = _emailController.text;
    String password = _passwordController.text;

    String? emailError = Validator.validateEmail(email);
    String? passwordError = Validator.validatePassword(password);

    if (emailError != null || passwordError != null) {
      setState(() {
        _errorMessage = emailError ?? passwordError;
      });
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        var user = await _authService.signUp(email, password);
        if (user != null && mounted) {
          await Provider.of<SessionState>(context, listen: false)
              .logIn(email: email);
        } else {
          try {
            throw Exception('abnormal error 001 on sign up');
          } catch (e, stackTrace) {
            Map<String, dynamic> metadata = {
              'email': email,
              'passwordLength': password.length,
            };
            ErrorService().reporter.reportError(e, stackTrace,
                message: 'abnormal_error_001', metadata: metadata);
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = e.toString();
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _signIn() async {
    if (_isLoading) return;

    String email = _emailController.text;
    String password = _passwordController.text;

    String? emailError = Validator.validateEmail(email);
    String? passwordError = Validator.validatePassword(password);

    if (emailError != null || passwordError != null) {
      setState(() {
        _errorMessage = emailError ?? passwordError;
      });
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        var user = await _authService.signIn(email, password);
        if (user != null && mounted) {
          await Provider.of<SessionState>(context, listen: false)
              .logIn(email: email);
        } else {
          try {
            throw Exception('abnormal error 002 on sign in');
          } catch (e, stackTrace) {
            Map<String, dynamic> metadata = {
              'email': email,
              'passwordLength': password.length,
            };
            ErrorService().reporter.reportError(e, stackTrace,
                message: 'abnormal_error_002', metadata: metadata);
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = e.toString();
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _alphaTestLogin() async {
    await _alphaLogin('test@hyperlog.aero', 'TEST-PILOT-001');
  }

  Future<void> _alphaDemoLogin() async {
    await _alphaLogin('demo@hyperlog.aero', 'DEMO-PILOT-001');
  }

  Future<void> _alphaLogin(String email, String license) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    const password = 'alphatest123';
    try {
      dynamic user;

      // Try sign in first
      try {
        user = await _authService.signIn(email, password);
      } catch (_) {
        // Sign in failed, try sign up
        user = await _authService.signUp(email, password);
      }

      if (user != null && mounted) {
        await Provider.of<SessionState>(context, listen: false)
            .logIn(email: email);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
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
      backgroundColor: AppColors.nightRider,
      body: Stack(
        children: [
          // Animated pulsing grid background with gradient fades
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _gridOpacity,
              builder: (context, child) => Opacity(
                opacity: _gridOpacity.value,
                child: CustomPaint(
                  painter: _GridPainter(),
                ),
              ),
            ),
          ),

          // Top gradient fade (matches website hero-bg)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.nightRider,
                    AppColors.nightRider.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          // Bottom gradient fade (matches website hero-bg)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.nightRider,
                    AppColors.nightRider.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          // Floating blockchain nodes
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) => CustomPaint(
                painter: _FloatingNodesPainter(
                  progress: _floatController.value,
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // Logo
                    Image.asset(
                      "assets/icon/hyperlog_logo.png",
                      width: 120,
                      height: 120,
                    ),
                    const SizedBox(height: 16),

                    // App name
                    Text(
                      'HYPERLOG',
                      style: AppTypography.h3.copyWith(
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tagline
                    Text(
                      'TRUST IN EVERY ENTRY',
                      style: AppTypography.label.copyWith(
                        color: AppColors.denimLight,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Login form in glass card
                    GlassContainer(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome',
                            style: AppTypography.h4,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to your pilot logbook',
                            style: AppTypography.bodySmall,
                          ),
                          const SizedBox(height: 32),

                          // Email field
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: AppTypography.body
                                .copyWith(color: AppColors.white),
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppColors.whiteDarker,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Password field
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: AppTypography.body
                                .copyWith(color: AppColors.white),
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: AppColors.whiteDarker,
                              ),
                            ),
                          ),

                          // Error message
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      const Color(0xFFEF4444).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Color(0xFFEF4444),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: const Color(0xFFEF4444),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 32),

                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: SecondaryButton(
                                  label: 'Sign Up',
                                  onPressed: _isLoading ? null : _signUp,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: PrimaryButton(
                                  label: 'Sign In',
                                  onPressed: _isLoading ? null : _signIn,
                                  isLoading: _isLoading,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Alpha Test section
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: AppColors.borderVisible),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Alpha Testing',
                            style: AppTypography.caption,
                          ),
                        ),
                        Expanded(
                          child: Divider(color: AppColors.borderVisible),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Alpha test pilots row
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            label: 'Test Pilot',
                            icon: Icons.person_outline,
                            borderColor: AppColors.denim,
                            textColor: AppColors.denim,
                            onPressed: _isLoading ? null : _alphaTestLogin,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SecondaryButton(
                            label: 'Demo Pilot',
                            icon: Icons.flight,
                            borderColor: AppColors.endorsedGreen,
                            textColor: AppColors.endorsedGreen,
                            onPressed: _isLoading ? null : _alphaDemoLogin,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Test: empty logbook  •  Demo: 200 flights',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.whiteDarker,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gridPulseController.dispose();
    _floatController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

/// Subtle grid background painter with denim blue tint
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.denim.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    const spacing = 60.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Floating blockchain nodes painter
class _FloatingNodesPainter extends CustomPainter {
  final double progress;

  _FloatingNodesPainter({required this.progress});

  // Node positions (relative to screen size)
  static const List<_NodeConfig> _nodes = [
    _NodeConfig(0.10, 0.20, 0.0),   // top-left area
    _NodeConfig(0.85, 0.60, 0.25),  // right side
    _NodeConfig(0.20, 0.80, 0.5),   // bottom-left
    _NodeConfig(0.70, 0.30, 0.75),  // top-right area
    _NodeConfig(0.50, 0.70, 0.4),   // center-bottom
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final node in _nodes) {
      // Calculate animated position with offset based on delay
      final adjustedProgress = (progress + node.delay) % 1.0;
      final offset = _calculateFloatOffset(adjustedProgress);

      final baseX = node.x * size.width;
      final baseY = node.y * size.height;

      final nodeX = baseX + offset.dx;
      final nodeY = baseY + offset.dy;

      // Draw connecting line (gradient fading out) - 200px to match website
      final linePaint = Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.denim.withValues(alpha: 0.2),
            AppColors.denim.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromPoints(
          Offset(nodeX, nodeY),
          Offset(nodeX + 200, nodeY),
        ))
        ..strokeWidth = 1;

      canvas.drawLine(
        Offset(nodeX, nodeY),
        Offset(nodeX + 200, nodeY),
        linePaint,
      );

      // Draw node (blue dot)
      final nodePaint = Paint()
        ..color = AppColors.denim.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(nodeX, nodeY), 4, nodePaint);
    }
  }

  Offset _calculateFloatOffset(double t) {
    // Smooth floating motion matching the CSS keyframes
    // 0%: (0, 0), 25%: (20, -30), 50%: (-10, 20), 75%: (30, 10), 100%: (0, 0)
    double x, y;

    if (t < 0.25) {
      final localT = t / 0.25;
      x = lerpDouble(0, 20, localT)!;
      y = lerpDouble(0, -30, localT)!;
    } else if (t < 0.5) {
      final localT = (t - 0.25) / 0.25;
      x = lerpDouble(20, -10, localT)!;
      y = lerpDouble(-30, 20, localT)!;
    } else if (t < 0.75) {
      final localT = (t - 0.5) / 0.25;
      x = lerpDouble(-10, 30, localT)!;
      y = lerpDouble(20, 10, localT)!;
    } else {
      final localT = (t - 0.75) / 0.25;
      x = lerpDouble(30, 0, localT)!;
      y = lerpDouble(10, 0, localT)!;
    }

    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant _FloatingNodesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Configuration for a floating node
class _NodeConfig {
  final double x;
  final double y;
  final double delay;

  const _NodeConfig(this.x, this.y, this.delay);
}
