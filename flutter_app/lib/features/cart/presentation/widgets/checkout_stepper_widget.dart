import 'package:flutter/material.dart';

/// A production-ready checkout progress indicator.
///
/// The widget is intentionally UI-only. It does not perform navigation,
/// payment processing, order creation, or network requests.
///
/// Example:
///
/// ```dart
/// CheckoutStepperWidget(
///   step: 2,
/// )
/// ```
///
/// Recommended step mapping:
///
/// ```text
/// 1 = Cart
/// 2 = Checkout
/// 3 = Payment
/// 4 = Review
/// 5 = Complete
/// ```
class CheckoutStepperWidget extends StatelessWidget {
  const CheckoutStepperWidget({
    super.key,
    required this.step,
    this.totalSteps = 5,
    this.steps,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.cardElevation = 0,
    this.borderRadius = 16,
    this.completedColor,
    this.activeColor,
    this.inactiveColor,
    this.connectorColor,
    this.errorColor,
    this.textStyle,
    this.activeTextStyle,
    this.completedTextStyle,
    this.inactiveTextStyle,
    this.iconSize = 24,
    this.connectorThickness = 2,
    this.showLabels = true,
    this.showStepNumbers = false,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 350),
    this.animationCurve = Curves.easeOutCubic,
    this.allowTap = false,
    this.onStepTapped,
    this.compact = false,
    this.clipBehavior = Clip.none,
    this.semanticLabel,
  });

  /// Current checkout step.
  ///
  /// Uses 1-based indexing:
  ///
  /// ```text
  /// 1 = Cart
  /// 2 = Checkout
  /// 3 = Payment
  /// 4 = Review
  /// 5 = Complete
  /// ```
  final int step;

  /// Number of checkout steps.
  final int totalSteps;

  /// Optional custom step configuration.
  ///
  /// If null, [defaultSteps] are used.
  final List<CheckoutStepperItem>? steps;

  /// Outer margin.
  final EdgeInsetsGeometry margin;

  /// Inner card padding.
  final EdgeInsetsGeometry padding;

  /// Card background.
  final Color? backgroundColor;

  /// Card elevation.
  final double cardElevation;

  /// Card border radius.
  final double borderRadius;

  /// Completed step color.
  final Color? completedColor;

  /// Current step color.
  final Color? activeColor;

  /// Future step color.
  final Color? inactiveColor;

  /// Connector color.
  final Color? connectorColor;

  /// Error color for invalid state.
  final Color? errorColor;

  /// Default label style.
  final TextStyle? textStyle;

  /// Active label style.
  final TextStyle? activeTextStyle;

  /// Completed label style.
  final TextStyle? completedTextStyle;

  /// Inactive label style.
  final TextStyle? inactiveTextStyle;

  /// Step icon size.
  final double iconSize;

  /// Connector thickness.
  final double connectorThickness;

  /// Whether labels should be displayed.
  final bool showLabels;

  /// Whether numeric step indicators should be displayed.
  final bool showStepNumbers;

  /// Whether state changes should animate.
  final bool enableAnimation;

  /// Animation duration.
  final Duration animationDuration;

  /// Animation curve.
  final Curve animationCurve;

  /// Whether steps can be tapped.
  final bool allowTap;

  /// Called when a step is tapped.
  ///
  /// The callback receives a 1-based step index.
  final ValueChanged<int>? onStepTapped;

  /// Compact layout.
  final bool compact;

  /// Card clipping.
  final Clip clipBehavior;

  /// Optional semantic label for screen readers.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveSteps = _buildEffectiveSteps();

    final safeCurrentStep = _normalizeStep(step, effectiveSteps.length);

    final effectiveCompletedColor = completedColor ?? theme.colorScheme.primary;

    final effectiveActiveColor = activeColor ?? theme.colorScheme.primary;

    final effectiveInactiveColor = inactiveColor ?? theme.colorScheme.outline;

    final effectiveConnectorColor =
        connectorColor ?? theme.colorScheme.outlineVariant;

    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.surface;

    return Semantics(
      container: true,
      label:
          semanticLabel ??
          'Checkout progress. Step $safeCurrentStep of '
              '${effectiveSteps.length}: '
              '${effectiveSteps[safeCurrentStep - 1].label}.',
      child: Container(
        margin: margin,
        child: Card(
          elevation: cardElevation,
          color: effectiveBackgroundColor,
          clipBehavior: clipBehavior,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Padding(
            padding: padding,
            child: _ResponsiveStepper(
              steps: effectiveSteps,
              currentStep: safeCurrentStep,
              completedColor: effectiveCompletedColor,
              activeColor: effectiveActiveColor,
              inactiveColor: effectiveInactiveColor,
              connectorColor: effectiveConnectorColor,
              errorColor: errorColor ?? theme.colorScheme.error,
              textStyle: textStyle ?? theme.textTheme.labelMedium,
              activeTextStyle:
                  activeTextStyle ??
                  theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: effectiveActiveColor,
                  ),
              completedTextStyle:
                  completedTextStyle ??
                  theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: effectiveCompletedColor,
                  ),
              inactiveTextStyle:
                  inactiveTextStyle ??
                  theme.textTheme.labelMedium?.copyWith(
                    color: effectiveInactiveColor,
                  ),
              iconSize: iconSize,
              connectorThickness: connectorThickness,
              showLabels: showLabels,
              showStepNumbers: showStepNumbers,
              enableAnimation: enableAnimation,
              animationDuration: animationDuration,
              animationCurve: animationCurve,
              allowTap: allowTap,
              onStepTapped: onStepTapped,
              compact: compact,
            ),
          ),
        ),
      ),
    );
  }

  List<CheckoutStepperItem> _buildEffectiveSteps() {
    if (steps != null && steps!.isNotEmpty) {
      return List<CheckoutStepperItem>.unmodifiable(steps!);
    }

    return CheckoutStepperItem.defaultSteps(totalSteps);
  }

  int _normalizeStep(int value, int availableSteps) {
    if (availableSteps <= 0) {
      return 1;
    }

    if (value < 1) {
      return 1;
    }

    if (value > availableSteps) {
      return availableSteps;
    }

    return value;
  }
}

/// Configuration for one checkout step.
@immutable
class CheckoutStepperItem {
  const CheckoutStepperItem({
    required this.label,
    this.subtitle,
    this.icon,
    this.completedIcon,
    this.activeIcon,
    this.semanticLabel,
    this.enabled = true,
    this.hasError = false,
  });

  final String label;

  final String? subtitle;

  final IconData? icon;

  final IconData? completedIcon;

  final IconData? activeIcon;

  final String? semanticLabel;

  final bool enabled;

  final bool hasError;

  static List<CheckoutStepperItem> defaultSteps(int totalSteps) {
    final defaults = <CheckoutStepperItem>[
      const CheckoutStepperItem(
        label: 'Cart',
        subtitle: 'Your items',
        icon: Icons.shopping_cart_outlined,
        activeIcon: Icons.shopping_cart,
        completedIcon: Icons.check,
      ),
      const CheckoutStepperItem(
        label: 'Checkout',
        subtitle: 'Delivery',
        icon: Icons.local_shipping_outlined,
        activeIcon: Icons.local_shipping,
        completedIcon: Icons.check,
      ),
      const CheckoutStepperItem(
        label: 'Payment',
        subtitle: 'Pay securely',
        icon: Icons.payment_outlined,
        activeIcon: Icons.payment,
        completedIcon: Icons.check,
      ),
      const CheckoutStepperItem(
        label: 'Review',
        subtitle: 'Confirm order',
        icon: Icons.fact_check_outlined,
        activeIcon: Icons.fact_check,
        completedIcon: Icons.check,
      ),
      const CheckoutStepperItem(
        label: 'Complete',
        subtitle: 'Order placed',
        icon: Icons.done_all_outlined,
        activeIcon: Icons.done_all,
        completedIcon: Icons.check,
      ),
    ];

    if (totalSteps <= 0) {
      return const [];
    }

    if (totalSteps <= defaults.length) {
      return defaults.take(totalSteps).toList();
    }

    final result = List<CheckoutStepperItem>.from(defaults);

    for (var i = defaults.length; i < totalSteps; i++) {
      result.add(
        CheckoutStepperItem(
          label: 'Step ${i + 1}',
          icon: Icons.circle_outlined,
          activeIcon: Icons.circle,
          completedIcon: Icons.check,
        ),
      );
    }

    return result;
  }
}

enum _CheckoutStepState { completed, active, upcoming, error }

class _ResponsiveStepper extends StatelessWidget {
  const _ResponsiveStepper({
    required this.steps,
    required this.currentStep,
    required this.completedColor,
    required this.activeColor,
    required this.inactiveColor,
    required this.connectorColor,
    required this.errorColor,
    required this.textStyle,
    required this.activeTextStyle,
    required this.completedTextStyle,
    required this.inactiveTextStyle,
    required this.iconSize,
    required this.connectorThickness,
    required this.showLabels,
    required this.showStepNumbers,
    required this.enableAnimation,
    required this.animationDuration,
    required this.animationCurve,
    required this.allowTap,
    required this.onStepTapped,
    required this.compact,
  });

  final List<CheckoutStepperItem> steps;
  final int currentStep;

  final Color completedColor;
  final Color activeColor;
  final Color inactiveColor;
  final Color connectorColor;
  final Color errorColor;

  final TextStyle? textStyle;
  final TextStyle? activeTextStyle;
  final TextStyle? completedTextStyle;
  final TextStyle? inactiveTextStyle;

  final double iconSize;
  final double connectorThickness;

  final bool showLabels;
  final bool showStepNumbers;

  final bool enableAnimation;
  final Duration animationDuration;
  final Curve animationCurve;

  final bool allowTap;
  final ValueChanged<int>? onStepTapped;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final useCompact = compact || width < 420 || steps.length > 5;

        if (useCompact) {
          return _buildCompact(context);
        }

        return _buildExpanded(context);
      },
    );
  }

  Widget _buildExpanded(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final leftStep = (index ~/ 2) + 1;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: iconSize / 2),
              child: _Connector(
                active: leftStep < currentStep,
                activeColor: completedColor,
                inactiveColor: connectorColor,
                thickness: connectorThickness,
                enableAnimation: enableAnimation,
                animationDuration: animationDuration,
                animationCurve: animationCurve,
              ),
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final stepNumber = stepIndex + 1;
        final item = steps[stepIndex];

        return _StepNode(
          item: item,
          stepNumber: stepNumber,
          state: _stateFor(item, stepNumber),
          completedColor: completedColor,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          errorColor: errorColor,
          textStyle: textStyle,
          activeTextStyle: activeTextStyle,
          completedTextStyle: completedTextStyle,
          inactiveTextStyle: inactiveTextStyle,
          iconSize: iconSize,
          showLabel: showLabels,
          showStepNumber: showStepNumbers,
          enableAnimation: enableAnimation,
          animationDuration: animationDuration,
          animationCurve: animationCurve,
          allowTap: allowTap,
          onTap: onStepTapped == null ? null : () => onStepTapped!(stepNumber),
          compact: false,
        );
      }),
    );
  }

  Widget _buildCompact(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _StepNode(
              item: steps[currentStep - 1],
              stepNumber: currentStep,
              state: _stateFor(steps[currentStep - 1], currentStep),
              completedColor: completedColor,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
              errorColor: errorColor,
              textStyle: textStyle,
              activeTextStyle: activeTextStyle,
              completedTextStyle: completedTextStyle,
              inactiveTextStyle: inactiveTextStyle,
              iconSize: iconSize,
              showLabel: false,
              showStepNumber: showStepNumbers,
              enableAnimation: enableAnimation,
              animationDuration: animationDuration,
              animationCurve: animationCurve,
              allowTap: false,
              compact: true,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CompactText(
                item: steps[currentStep - 1],
                currentStep: currentStep,
                totalSteps: steps.length,
                style: activeTextStyle ?? textStyle,
              ),
            ),
          ],
        ),
        if (showLabels) ...[
          const SizedBox(height: 10),
          _ProgressBar(
            value: currentStep / steps.length,
            activeColor: activeColor,
            inactiveColor: connectorColor,
            enableAnimation: enableAnimation,
            animationDuration: animationDuration,
            animationCurve: animationCurve,
          ),
        ],
      ],
    );
  }

  _CheckoutStepState _stateFor(CheckoutStepperItem item, int stepNumber) {
    if (item.hasError) {
      return _CheckoutStepState.error;
    }

    if (stepNumber < currentStep) {
      return _CheckoutStepState.completed;
    }

    if (stepNumber == currentStep) {
      return _CheckoutStepState.active;
    }

    return _CheckoutStepState.upcoming;
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.item,
    required this.stepNumber,
    required this.state,
    required this.completedColor,
    required this.activeColor,
    required this.inactiveColor,
    required this.errorColor,
    required this.textStyle,
    required this.activeTextStyle,
    required this.completedTextStyle,
    required this.inactiveTextStyle,
    required this.iconSize,
    required this.showLabel,
    required this.showStepNumber,
    required this.enableAnimation,
    required this.animationDuration,
    required this.animationCurve,
    required this.allowTap,
    this.onTap,
    required this.compact,
  });

  final CheckoutStepperItem item;
  final int stepNumber;
  final _CheckoutStepState state;

  final Color completedColor;
  final Color activeColor;
  final Color inactiveColor;
  final Color errorColor;

  final TextStyle? textStyle;
  final TextStyle? activeTextStyle;
  final TextStyle? completedTextStyle;
  final TextStyle? inactiveTextStyle;

  final double iconSize;

  final bool showLabel;
  final bool showStepNumber;

  final bool enableAnimation;
  final Duration animationDuration;
  final Curve animationCurve;

  final bool allowTap;
  final VoidCallback? onTap;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = _color;

    final semanticState = switch (state) {
      _CheckoutStepState.completed => 'completed',
      _CheckoutStepState.active => 'current',
      _CheckoutStepState.upcoming => 'upcoming',
      _CheckoutStepState.error => 'has an error',
    };

    final semanticLabel =
        item.semanticLabel ?? '${item.label}, step $stepNumber, $semanticState';

    final content = Semantics(
      button: allowTap,
      enabled: item.enabled,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: allowTap && item.enabled ? onTap : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AnimatedStepCircle(
              item: item,
              state: state,
              stepNumber: stepNumber,
              color: effectiveColor,
              iconSize: iconSize,
              showStepNumber: showStepNumber,
              enableAnimation: enableAnimation,
              animationDuration: animationDuration,
              animationCurve: animationCurve,
            ),
            if (showLabel) ...[
              const SizedBox(height: 7),
              _StepLabel(
                item: item,
                state: state,
                textStyle: textStyle,
                activeTextStyle: activeTextStyle,
                completedTextStyle: completedTextStyle,
                inactiveTextStyle: inactiveTextStyle,
              ),
            ],
          ],
        ),
      ),
    );

    return compact
        ? content
        : ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 54),
            child: content,
          );
  }

  Color get _color {
    switch (state) {
      case _CheckoutStepState.completed:
        return completedColor;
      case _CheckoutStepState.active:
        return activeColor;
      case _CheckoutStepState.upcoming:
        return inactiveColor;
      case _CheckoutStepState.error:
        return errorColor;
    }
  }
}

class _AnimatedStepCircle extends StatelessWidget {
  const _AnimatedStepCircle({
    required this.item,
    required this.state,
    required this.stepNumber,
    required this.color,
    required this.iconSize,
    required this.showStepNumber,
    required this.enableAnimation,
    required this.animationDuration,
    required this.animationCurve,
  });

  final CheckoutStepperItem item;
  final _CheckoutStepState state;
  final int stepNumber;
  final Color color;
  final double iconSize;
  final bool showStepNumber;
  final bool enableAnimation;
  final Duration animationDuration;
  final Curve animationCurve;

  @override
  Widget build(BuildContext context) {
    final isActive = state == _CheckoutStepState.active;

    final isCompleted = state == _CheckoutStepState.completed;

    final isError = state == _CheckoutStepState.error;

    final icon = _resolveIcon();

    final circle = AnimatedContainer(
      duration: enableAnimation ? animationDuration : Duration.zero,
      curve: animationCurve,
      width: iconSize + 14,
      height: iconSize + 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? color.withValues(alpha: 0.12) : Colors.transparent,
        border: Border.all(color: color, width: isActive ? 2 : 1.5),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: enableAnimation ? animationDuration : Duration.zero,
          switchInCurve: Curves.easeOutBack,
          child: Icon(
            icon,
            key: ValueKey<String>('${state.name}-$stepNumber'),
            size: iconSize,
            color: color,
          ),
        ),
      ),
    );

    if (showStepNumber && !isCompleted && !isError && item.icon == null) {
      return _NumberCircle(
        number: stepNumber,
        color: color,
        size: iconSize + 14,
        active: isActive,
      );
    }

    return circle;
  }

  IconData _resolveIcon() {
    if (state == _CheckoutStepState.error) {
      return Icons.error_outline;
    }

    if (state == _CheckoutStepState.completed) {
      return item.completedIcon ?? Icons.check;
    }

    if (state == _CheckoutStepState.active) {
      return item.activeIcon ?? item.icon ?? Icons.circle;
    }

    return item.icon ?? Icons.circle_outlined;
  }
}

class _NumberCircle extends StatelessWidget {
  const _NumberCircle({
    required this.number,
    required this.color,
    required this.size,
    required this.active,
  });

  final int number;
  final Color color;
  final double size;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? color.withValues(alpha: 0.12) : Colors.transparent,
        border: Border.all(color: color, width: active ? 2 : 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  const _StepLabel({
    required this.item,
    required this.state,
    required this.textStyle,
    required this.activeTextStyle,
    required this.completedTextStyle,
    required this.inactiveTextStyle,
  });

  final CheckoutStepperItem item;
  final _CheckoutStepState state;

  final TextStyle? textStyle;
  final TextStyle? activeTextStyle;
  final TextStyle? completedTextStyle;
  final TextStyle? inactiveTextStyle;

  @override
  Widget build(BuildContext context) {
    final style = switch (state) {
      _CheckoutStepState.active => activeTextStyle ?? textStyle,
      _CheckoutStepState.completed => completedTextStyle ?? textStyle,
      _CheckoutStepState.upcoming => inactiveTextStyle ?? textStyle,
      _CheckoutStepState.error => activeTextStyle ?? textStyle,
    };

    return Text(
      item.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: style,
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    required this.thickness,
    required this.enableAnimation,
    required this.animationDuration,
    required this.animationCurve,
  });

  final bool active;

  final Color activeColor;
  final Color inactiveColor;

  final double thickness;

  final bool enableAnimation;
  final Duration animationDuration;
  final Curve animationCurve;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: AnimatedContainer(
        duration: enableAnimation ? animationDuration : Duration.zero,
        curve: animationCurve,
        height: thickness,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(thickness),
          color: active ? activeColor : inactiveColor,
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.value,
    required this.activeColor,
    required this.inactiveColor,
    required this.enableAnimation,
    required this.animationDuration,
    required this.animationCurve,
  });

  final double value;
  final Color activeColor;
  final Color inactiveColor;

  final bool enableAnimation;
  final Duration animationDuration;
  final Curve animationCurve;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
        duration: enableAnimation ? animationDuration : Duration.zero,
        curve: animationCurve,
        builder: (context, animatedValue, child) {
          return LinearProgressIndicator(
            minHeight: 4,
            value: animatedValue,
            backgroundColor: inactiveColor,
            valueColor: AlwaysStoppedAnimation<Color>(activeColor),
          );
        },
      ),
    );
  }
}

class _CompactText extends StatelessWidget {
  const _CompactText({
    required this.item,
    required this.currentStep,
    required this.totalSteps,
    required this.style,
  });

  final CheckoutStepperItem item;
  final int currentStep;
  final int totalSteps;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              style ??
              Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          item.subtitle ?? 'Step $currentStep of $totalSteps',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
