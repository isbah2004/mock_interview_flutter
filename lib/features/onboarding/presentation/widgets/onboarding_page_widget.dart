import 'package:flutter/material.dart';
import 'package:mock_interview/features/onboarding/domain/entities/onboarding_page.dart';
import 'package:mock_interview/core/theme/colorpalette/app_colors.dart';

class OnboardingPageWidget extends StatefulWidget {
  final OnboardingPage page;
  final bool isActive;
  final int pageIndex;

  const OnboardingPageWidget({
    super.key,
    required this.page,
    this.isActive = false,
    required this.pageIndex,
  });

  @override
  State<OnboardingPageWidget> createState() => _OnboardingPageWidgetState();
}

class _OnboardingPageWidgetState extends State<OnboardingPageWidget>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  late Animation<double> _iconAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _iconController.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (!mounted) return;
          _textController.forward();
        });
      });
    }
  }

  @override
  void didUpdateWidget(OnboardingPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      if (mounted) _iconController.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        _textController.forward();
      });
    } else if (!widget.isActive && oldWidget.isActive) {
      _iconController.reverse();
      _textController.reverse();
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _iconAnimation,
                      _pulseAnimation,
                    ]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale:
                            widget.isActive
                                ? _iconAnimation.value * _pulseAnimation.value
                                : 0.8,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Animated particle rings
                            ...List.generate(3, (index) {
                              return AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale:
                                        1.0 +
                                        (index * 0.1) +
                                        (_pulseAnimation.value - 1.0) *
                                            (index + 1),
                                    child: Container(
                                      width: 140 + (index * 20),
                                      height: 140 + (index * 20),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: (widget.page.iconColor ??
                                                  AppColors.primaryPurple)
                                              .withOpacity(
                                                0.1 - (index * 0.03),
                                              ),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),

                            // Outer glow effect with enhanced gradient
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    (widget.page.iconColor ??
                                            AppColors.primaryPurple)
                                        .withOpacity(0.3),
                                    (widget.page.iconColor ??
                                            AppColors.primaryPurple)
                                        .withOpacity(0.1),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                            // Main icon container with glassmorphism effect
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    colorScheme.surface.withOpacity(0.9),
                                    colorScheme.surface.withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(60),
                                border: Border.all(
                                  color:
                                      widget.page.iconColor ??
                                      AppColors.primaryPurple,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (widget.page.iconColor ??
                                            AppColors.primaryPurple)
                                        .withOpacity(0.4),
                                    blurRadius: 25,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(-5, -5),
                                  ),
                                ],
                              ),
                              child: Transform.scale(
                                scale: _iconAnimation.value,
                                child: Icon(
                                  widget.page.icon,
                                  size: 60,
                                  color:
                                      widget.page.iconColor ??
                                      AppColors.primaryPurple,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 48),

                  AnimatedBuilder(
                    animation: _textAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - _textAnimation.value)),
                        child: Opacity(
                          opacity: _textAnimation.value.clamp(0.0, 1.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.surface.withOpacity(0.9),
                                  colorScheme.surface.withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: (widget.page.iconColor ??
                                        AppColors.primaryPurple)
                                    .withOpacity(0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (widget.page.iconColor ??
                                          AppColors.primaryPurple)
                                      .withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ShaderMask(
                              shaderCallback:
                                  (bounds) => LinearGradient(
                                    colors: [
                                      widget.page.iconColor ??
                                          AppColors.primaryPurple,
                                      (widget.page.iconColor ??
                                              AppColors.primaryPurple)
                                          .withOpacity(0.8),
                                    ],
                                  ).createShader(bounds),
                              child: Text(
                                widget.page.title,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.2,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  AnimatedBuilder(
                    animation: _textAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - _textAnimation.value)),
                        child: Opacity(
                          opacity: (_textAnimation.value * 0.9).clamp(0.0, 1.0),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colorScheme.surface.withOpacity(0.8),
                                  colorScheme.surface.withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: colorScheme.outline.withOpacity(0.1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.page.description,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.8),
                                height: 1.6,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                  AnimatedBuilder(
                    animation: _textAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 40 * (1 - _textAnimation.value)),
                        child: Opacity(
                          opacity: (_textAnimation.value * 0.7).clamp(0.0, 1.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: (widget.page.iconColor ??
                                          AppColors.primaryPurple)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: (widget.page.iconColor ??
                                            AppColors.primaryPurple)
                                        .withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.swipe_left,
                                      size: 16,
                                      color:
                                          widget.page.iconColor ??
                                          AppColors.primaryPurple,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Swipe to explore',
                                      style: TextStyle(
                                        color:
                                            widget.page.iconColor ??
                                            AppColors.primaryPurple,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ), // Column
            ), // ConstrainedBox
          ); // SingleChildScrollView (returned from builder)
        },
      ), // LayoutBuilder
    ); // Padding
  }
}
