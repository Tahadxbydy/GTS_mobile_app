import 'dart:ui';
import 'package:flutter/material.dart';

class CustomAnimatedButton extends StatefulWidget {
  final String text;
  final Color? textColor;
  final VoidCallback? onTap;
  final List<Color>? gradientColors;
  final double borderWidth;
  final double blurRadius;

  const CustomAnimatedButton({
    super.key,
    required this.text,
    required this.onTap,
    this.gradientColors,
    this.textColor,
    this.borderWidth = 2.0,
    this.blurRadius = 12.0, // Configurable blur radius
  });

  @override
  State<CustomAnimatedButton> createState() => _CustomAnimatedButtonState();
}

class _CustomAnimatedButtonState extends State<CustomAnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null;
    final defaultGradient = [
      Theme.of(context).primaryColor,
      Colors.purpleAccent,
      Colors.cyan,
      Theme.of(context).primaryColor,
    ];

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onTap?.call();
            },
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // 1. Blurred Ambient Glow Underneath
                if (!isDisabled)
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: SweepGradient(
                        transform: GradientRotation(
                          _rotationController.value * 2 * 3.14159,
                        ),
                        colors: widget.gradientColors ?? defaultGradient,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.gradientColors ?? defaultGradient)[0]
                              .withOpacity(0.5),
                          blurRadius: widget.blurRadius,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),

                // 2. Foreground Rotating Border & Frosted Glass Core
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: SweepGradient(
                        transform: GradientRotation(
                          _rotationController.value * 2 * 3.14159,
                        ),
                        colors: isDisabled
                            ? [Colors.grey, Colors.grey]
                            : (widget.gradientColors ?? defaultGradient),
                      ),
                    ),
                    padding: EdgeInsets.all(widget.borderWidth),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        14 - widget.borderWidth,
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: widget.blurRadius,
                          sigmaY: widget.blurRadius,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).scaffoldBackgroundColor.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(
                              14 - widget.borderWidth,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.text,
                            style: TextStyle(
                              color: isDisabled
                                  ? Colors.grey
                                  : (widget.textColor ??
                                        Theme.of(context).primaryColor),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
