import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A glass-morphism card with backdrop blur and gradient background
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool enableHoverEffect;
  final double borderRadius;
  final double blurSigma;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.enableHoverEffect = true,
    this.borderRadius = 20,
    this.blurSigma = 20,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enableHoverEffect && widget.onTap != null) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enableHoverEffect && widget.onTap != null) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.enableHoverEffect && widget.onTap != null) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _scaleAnimation.value),
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: Container(
          margin: widget.margin,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.blurSigma,
                sigmaY: widget.blurSigma,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                padding:
                    widget.padding ?? const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.glass50,
                      AppColors.glassDark50,
                    ],
                  ),
                  border: Border.all(
                    color: _isPressed
                        ? AppColors.borderVisible
                        : AppColors.borderSubtle,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A simpler glass container without the hover effects (for backgrounds)
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;
  final Color? borderColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blurSigma = 20,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding ?? const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.glass50,
                  AppColors.glassDark50,
                ],
              ),
              border: Border.all(
                color: borderColor ?? AppColors.borderSubtle,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
