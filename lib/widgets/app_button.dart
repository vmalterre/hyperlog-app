import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Primary filled button with denim background
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _elevationAnimation = Tween<double>(begin: 0, end: -2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return MouseRegion(
      onEnter: (_) => isEnabled ? _controller.forward() : null,
      onExit: (_) => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _elevationAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _elevationAnimation.value),
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppColors.denim.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [],
          ),
          child: SizedBox(
            width: widget.fullWidth ? double.infinity : null,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isEnabled ? AppColors.denim : AppColors.nightRiderLight,
                foregroundColor: AppColors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(widget.label, style: AppTypography.button),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary outlined button
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;
  final Color? borderColor;
  final Color? textColor;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.fullWidth = false,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: BorderSide(
            color: borderColor ?? AppColors.nightRiderLight,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(label, style: AppTypography.button.copyWith(color: textColor)),
          ],
        ),
      ),
    );
  }
}

/// Tab/pill-shaped toggle button (for screen navigation)
class TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onPressed;

  const TabButton({
    super.key,
    required this.label,
    this.isActive = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: isActive ? AppColors.denim : Colors.transparent,
          foregroundColor: isActive ? AppColors.white : AppColors.whiteDarker,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: BorderSide(
              color: isActive ? AppColors.denim : AppColors.borderVisible,
              width: 1,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.navItem.copyWith(
            color: isActive ? AppColors.white : AppColors.whiteDarker,
          ),
        ),
      ),
    );
  }
}

/// Filter chip button (for filtering data, distinct from navigation tabs)
class MapFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onPressed;

  const MapFilterChip({
    super.key,
    required this.label,
    this.isActive = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: isActive
              ? AppColors.nightRiderLight.withValues(alpha: 0.5)
              : Colors.transparent,
          foregroundColor: isActive ? AppColors.white : AppColors.whiteDarker,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isActive
                  ? AppColors.whiteDarker.withValues(alpha: 0.3)
                  : AppColors.nightRiderLight.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.navItem.copyWith(
            fontSize: 12,
            color: isActive ? AppColors.white : AppColors.whiteDarker,
          ),
        ),
      ),
    );
  }
}

/// Danger/destructive button (for logout, delete, etc.)
class DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;

  const DangerButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    const dangerColor = Color(0xFFEF4444);

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: dangerColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: dangerColor, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: dangerColor),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTypography.button.copyWith(color: dangerColor),
            ),
          ],
        ),
      ),
    );
  }
}
