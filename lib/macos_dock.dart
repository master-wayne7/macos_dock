import 'dart:math';
import 'package:flutter/material.dart';

/// A widget that creates a macOS-style dock with scaling and bouncing animations.
///
/// The dock displays a row of icons that scale up when hovered over and translate
/// upward based on their scale factor. The scaling effect spreads to neighboring
/// icons with a smooth falloff.
///
/// Example:
/// ```dart
/// MacosDock(
///   children: (scale) => [
///     Image.asset('assets/app1.png'),
///     Image.asset('assets/app2.png'),
///     Image.asset('assets/app3.png'),
///   ],
///   iconSize: 50,
///   scaleFactor: 1.5,
///   translateFactor: 1.0,
/// )
/// ```
class MacosDock extends StatefulWidget {
  /// Function that returns a list of widgets to be displayed in the dock.
  /// The function receives the current scale factor as a parameter, allowing
  /// widgets to adapt to their scaled size.
  final List<Widget> Function(double scale) children;

  /// The base size of each icon in the dock.
  final double iconSize;

  /// The horizontal spacing between icons.
  final double iconSpacing;

  /// Controls how much the icons scale up when hovered over.
  /// A value of 1.0 means normal scaling, while higher values increase the effect.
  final double scaleFactor;

  /// Controls how much the icons move upward when scaled.
  /// A value of 1.0 means normal translation, while higher values increase the effect.
  final double translateFactor;

  /// Controls the radius of influence for the hover effect.
  /// A larger value means the scaling effect spreads to more neighboring icons.
  final double radiusFactor;

  /// The maximum scale factor that can be applied to an icon.
  final double defaultMaxScale;

  /// The maximum upward translation when an icon is fully scaled.
  final double defaultMaxTranslate;

  /// Duration for the scaling and translation animations.
  final Duration animationDuration;

  /// Whether the dock items can be reordered by dragging
  final bool enableReordering;

  /// Callback function when items are reordered
  /// The function receives the old and new index of the reordered item
  final void Function(int oldIndex, int newIndex)? onReorder;

  /// Creates a macOS-style dock.
  ///
  /// The [children] parameter is required and should return a list of widgets to
  /// display in the dock. Each widget will typically be an image or icon.
  const MacosDock({
    super.key,
    required this.children,
    this.iconSize = 40,
    this.iconSpacing = 8,
    this.scaleFactor = 1,
    this.translateFactor = 1,
    this.radiusFactor = 1,
    this.defaultMaxScale = 2.5,
    this.defaultMaxTranslate = -30,
    this.animationDuration = const Duration(milliseconds: 200),
    this.enableReordering = false,
    this.onReorder,
  }) : assert(
          !enableReordering || onReorder != null,
          'onReorder must be provided when enableReordering is true',
        );

  @override
  State<MacosDock> createState() => MacosDockState();
}

class MacosDockState extends State<MacosDock> with TickerProviderStateMixin {
  Offset? _mousePosition;
  bool _isHovering = false;
  bool _isDragging = false;

  // Calculate hover radius based on spread factor
  double get _hoverRadius => widget.radiusFactor * widget.iconSize;

  // Remove the late final to allow updates
  late Duration _animationDuration;

  // AnimationController for bounce effect
  late List<AnimationController> _bounceControllers;
  late List<Animation<double>> _bounceAnimations;

  late AnimationController _reorderAnimationController;
  late Animation<double> _reorderAnimation;

  @override
  void initState() {
    super.initState();
    _animationDuration = widget.animationDuration;

    // Add reorder animation controller
    _reorderAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _reorderAnimation = CurvedAnimation(
      parent: _reorderAnimationController,
      curve: Curves.easeInOutCubic,
    );

    // Initialize a bounce controller and animation for each icon
    _bounceControllers = List.generate(
      widget.children(0).length,
      (index) {
        return AnimationController(
          duration: const Duration(milliseconds: 500),
          vsync: this,
        );
      },
    );

    _bounceAnimations = List.generate(
      widget.children(0).length,
      (index) {
        return Tween<double>(begin: 0, end: -40).animate(
          CurvedAnimation(
            parent: _bounceControllers[index],
            curve: Curves.easeInOut,
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(MacosDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update animation duration when the prop changes
    if (oldWidget.animationDuration != widget.animationDuration) {
      setState(() {
        _animationDuration = widget.animationDuration;
      });
    }
  }

  @override
  void dispose() {
    _reorderAnimationController.dispose();
    for (var controller in _bounceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> dockItems = [
      for (int i = 0; i < widget.children(0).length; i++)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.iconSpacing / 2),
          child: TweenAnimationBuilder<double>(
            duration: _animationDuration,
            curve: Curves.easeOutCubic,
            tween: Tween<double>(
              begin: 1.0,
              end: _getScaleFactor(i),
            ),
            builder: (context, scale, child) {
              return AnimatedBuilder(
                animation: _bounceAnimations[i],
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                        0, _getTranslation(scale) + _bounceAnimations[i].value),
                    child: AnimatedContainer(
                      duration: _animationDuration,
                      curve: Curves.easeOutCubic,
                      width: _isDragging
                          ? widget.iconSize
                          : widget.iconSize * scale,
                      height: _isDragging
                          ? widget.iconSize
                          : widget.iconSize * scale,
                      child: widget.children(scale)[i],
                    ),
                  );
                },
              );
            },
          ),
        ),
    ];

    Widget dockContent = widget.enableReordering
        ? SizedBox(
            height: _isHovering && !_isDragging
                ? (widget.iconSize *
                        widget.defaultMaxScale *
                        widget.scaleFactor) +
                    (widget.defaultMaxTranslate.abs() * widget.translateFactor)
                : widget.iconSize,
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              buildDefaultDragHandles: false,
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: Curves.easeOutCubic.transform(animation.value),
                      child: child,
                    );
                  },
                  child: child,
                );
              },
              itemCount: dockItems.length,
              itemBuilder: (context, index) {
                return ReorderableDragStartListener(
                  key: ValueKey(index),
                  index: index,
                  child: AnimatedBuilder(
                    animation: _reorderAnimation,
                    builder: (context, child) {
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: child,
                      );
                    },
                    child: dockItems[index],
                  ),
                );
              },
              onReorderStart: (index) {
                setState(() {
                  _isDragging = true;
                  _mousePosition = null;
                });
                _reorderAnimationController.forward();
              },
              onReorderEnd: (index) {
                setState(() {
                  _mousePosition = null;
                  _isDragging = false;
                });
                _reorderAnimationController.reverse();
              },
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                widget.onReorder?.call(oldIndex, newIndex);
              },
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: dockItems,
          );

    return MouseRegion(
      onEnter: (_) {
        if (!_isDragging) {
          setState(() {
            _isHovering = true;
          });
        }
      },
      onHover: (event) {
        if (!_isDragging) {
          setState(() {
            _mousePosition = event.localPosition;
          });
        }
      },
      onExit: (_) {
        setState(() {
          _isHovering = false;
          _mousePosition = null;
        });
      },
      child: dockContent,
    );
  }

  double _getScaleFactor(int index) {
    if (_isDragging || _mousePosition == null) return 1.0;

    double position = 0;
    for (int i = 0; i < index; i++) {
      double prevIconScale = _calculateBaseScale(i);
      position += (widget.iconSize * prevIconScale + widget.iconSpacing);
    }

    double currentIconScale = _calculateBaseScale(index);
    position += (widget.iconSize * currentIconScale) / 2;

    double distance = (_mousePosition!.dx - position).abs();
    double normalizedDistance = distance / _hoverRadius;

    // Base influence with smoother falloff
    double influence =
        max(0, (1 - pow(normalizedDistance * 1.5, 2).toDouble()));

    // Enhance center effect without causing shrinkage
    if (normalizedDistance < 0.5) {
      double centerFactor = 1 - (normalizedDistance / 0.5);
      influence = max(influence, centerFactor);
    }

    // Apply scale factor independently
    return 1 + ((widget.defaultMaxScale - 1) * influence * widget.scaleFactor);
  }

  double _calculateBaseScale(int index) {
    if (_mousePosition == null) return 1.0;

    double iconCenterX =
        index * (widget.iconSize + widget.iconSpacing) + (widget.iconSize);
    double distance = (_mousePosition!.dx - iconCenterX).abs();
    double normalizedDistance = distance / _hoverRadius;

    // Base influence with smoother falloff
    double influence =
        max(0, (1 - pow(normalizedDistance * 1.5, 2).toDouble()));

    // Enhance center effect without causing shrinkage
    if (normalizedDistance < 0.5) {
      double centerFactor = 1 - (normalizedDistance / 0.5);
      influence = max(influence, centerFactor);
    }

    // Apply scale factor independently
    return 1 + ((widget.defaultMaxScale - 1) * influence * widget.scaleFactor);
  }

  double _getTranslation(double scaleFactor) {
    if (_mousePosition == null) return 0.0;

    // Calculate translation based on scale but independent of scale factor
    double baseScale = (scaleFactor - 1) / (widget.defaultMaxScale - 1);
    // Apply translation factor independently
    return widget.defaultMaxTranslate * baseScale * widget.translateFactor;
  }
}
