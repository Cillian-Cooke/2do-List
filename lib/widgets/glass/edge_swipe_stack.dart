import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../../design.dart';
import '../../models/timeline_entry.dart';
import 'glass_pane.dart';
import 'sticker_field.dart';

enum GlassLayer { mine, partner, group }

/// Glass sheets live off-screen until you press their edge, which peeks
/// them in. Opening is still an edge swipe; dismissing the top sheet can
/// start anywhere except the other sheets' reveal edges.
class EdgeSwipeStack extends StatefulWidget {
  const EdgeSwipeStack({
    super.key,
    required this.child,
    required this.mineTodos,
    required this.partnerTodos,
    required this.groupTodos,
    required this.onToggle,
    required this.onDelete,
    required this.onEdited,
    required this.onAddTodo,
  });

  final Widget child;
  final List<TimelineEntry> mineTodos;
  final List<TimelineEntry> partnerTodos;
  final List<TimelineEntry> groupTodos;
  final void Function(TimelineEntry entry) onToggle;
  final void Function(TimelineEntry entry) onDelete;
  final VoidCallback onEdited;
  final void Function(EntryOwner owner) onAddTodo;

  @override
  State<EdgeSwipeStack> createState() => _EdgeSwipeStackState();
}

class _EdgeSwipeStackState extends State<EdgeSwipeStack>
    with TickerProviderStateMixin {
  static final _spring = SpringDescription(mass: 0.8, stiffness: 240, damping: 22);

  late final AnimationController _mine = AnimationController.unbounded(vsync: this);
  late final AnimationController _partner = AnimationController.unbounded(vsync: this);
  late final AnimationController _group = AnimationController.unbounded(vsync: this);

  GlassLayer? _active;
  bool _didHaptic = false;
  double _startValue = 0;

  @override
  void dispose() {
    _mine.dispose();
    _partner.dispose();
    _group.dispose();
    super.dispose();
  }

  AnimationController _controller(GlassLayer layer) => switch (layer) {
    GlassLayer.mine => _mine,
    GlassLayer.partner => _partner,
    GlassLayer.group => _group,
  };

  GlassLayer? get _topmost {
    if (_group.value > 0.02) return GlassLayer.group;
    if (_partner.value > 0.02) return GlassLayer.partner;
    if (_mine.value > 0.02) return GlassLayer.mine;
    return null;
  }

  bool _canControl(GlassLayer layer) {
    if (_active != null) return _active == layer;
    final top = _topmost;
    if (top == null || top == layer) return true;
    return _controller(layer).value <= 0.02;
  }

  void _begin(GlassLayer layer) {
    if (_active == layer) return;
    if (!_canControl(layer)) {
      _active = null;
      return;
    }
    _active = layer;
    _didHaptic = false;
    _startValue = _controller(layer).value;
    _controller(layer).stop();
  }

  void _peek(GlassLayer layer) {
    if (_active != layer) return;
    final controller = _controller(layer);
    if (controller.value < AppDesign.glassPeek) {
      controller.value = AppDesign.glassPeek;
    }
  }

  void _applyDelta(GlassLayer layer, double delta, double extent) {
    if (_active != layer) return;
    final openingDelta = switch (layer) {
      GlassLayer.mine => delta,
      GlassLayer.partner => -delta,
      GlassLayer.group => delta,
    };
    final controller = _controller(layer);
    final next = (controller.value + openingDelta / (extent * 0.88)).clamp(0.0, 1.12);
    if (!_didHaptic && (controller.value - 0.5) * (next - 0.5) <= 0 && next > 0.04) {
      HapticFeedback.selectionClick();
      _didHaptic = true;
    }
    controller.value = next;
  }

  void _snap(GlassLayer layer, double velocity, double extent) {
    if (_active != layer) return;
    final controller = _controller(layer);
    final openingVelocity = switch (layer) {
      GlassLayer.mine => velocity,
      GlassLayer.partner => -velocity,
      GlassLayer.group => velocity,
    };
    final units = extent == 0 ? 0.0 : openingVelocity / extent;
    final peeledClosed =
        _startValue >= 0.9 && controller.value < _startValue - 0.02 && units <= 0.35;
    final open = peeledClosed
        ? false
        : units > 0.85
        ? true
        : units < -0.85
        ? false
        : controller.value >= 0.38;
    if ((open && controller.value < 0.95) || (!open && controller.value > 0.05)) {
      HapticFeedback.mediumImpact();
    }
    controller
        .animateWith(
          SpringSimulation(_spring, controller.value, open ? 1.0 : 0.0, units),
        )
        .whenComplete(() {
          if (!mounted) return;
          final settled = _controller(layer);
          if (settled.value < 0.03) settled.value = 0;
          if (settled.value > 0.97) settled.value = 1;
        });
    _active = null;
  }

  void _cancel(GlassLayer layer, double extent) {
    if (_active != layer) return;
    if (_startValue >= 0.85 && _controller(layer).value < _startValue) {
      final closingVelocity = switch (layer) {
        GlassLayer.mine => -2500.0,
        GlassLayer.partner => 2500.0,
        GlassLayer.group => -2500.0,
      };
      _snap(layer, closingVelocity, extent);
      return;
    }
    _snap(layer, 0, extent);
  }

  void _pressEdge(GlassLayer layer) {
    _begin(layer);
    _peek(layer);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);

    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: Listenable.merge([_mine, _partner, _group]),
          builder: (context, _) {
            return Stack(
              fit: StackFit.expand,
              children: [
                _sheet(
                  layer: GlassLayer.mine,
                  color: AppDesign.meColor,
                  title: 'Your to-dos',
                  emptyLabel: 'Nothing stuck up for you',
                  todos: widget.mineTodos,
                  size: size,
                  pad: pad,
                  owner: EntryOwner.me,
                ),
                _sheet(
                  layer: GlassLayer.partner,
                  color: AppDesign.partnerColor,
                  title: "Partner's to-dos",
                  emptyLabel: 'They have a clear day',
                  todos: widget.partnerTodos,
                  size: size,
                  pad: pad,
                  owner: EntryOwner.partner,
                ),
                _sheet(
                  layer: GlassLayer.group,
                  color: AppDesign.sharedColor,
                  title: 'Group to-dos',
                  emptyLabel: 'No shared to-dos today',
                  todos: widget.groupTodos,
                  size: size,
                  pad: pad,
                  owner: EntryOwner.shared,
                ),
              ],
            );
          },
        ),
        MediaQuery(
          data: MediaQuery.of(context).copyWith(
            gestureSettings: const DeviceGestureSettings(touchSlop: 4),
          ),
          child: Stack(
            children: [
              Positioned(
                key: const Key('edge-left'),
                left: 0,
                top: 0,
                bottom: 0,
                width: AppDesign.edgeHit,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragDown: (_) => _pressEdge(GlassLayer.mine),
                  onHorizontalDragUpdate: (details) =>
                      _applyDelta(GlassLayer.mine, details.delta.dx, size.width),
                  onHorizontalDragEnd: (details) =>
                      _snap(GlassLayer.mine, details.velocity.pixelsPerSecond.dx, size.width),
                  onHorizontalDragCancel: () => _cancel(GlassLayer.mine, size.width),
                ),
              ),
              Positioned(
                key: const Key('edge-right'),
                right: 0,
                top: 0,
                bottom: 0,
                width: AppDesign.edgeHit,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragDown: (_) => _pressEdge(GlassLayer.partner),
                  onHorizontalDragUpdate: (details) =>
                      _applyDelta(GlassLayer.partner, details.delta.dx, size.width),
                  onHorizontalDragEnd: (details) =>
                      _snap(GlassLayer.partner, details.velocity.pixelsPerSecond.dx, size.width),
                  onHorizontalDragCancel: () => _cancel(GlassLayer.partner, size.width),
                ),
              ),
              Positioned(
                key: const Key('edge-top'),
                left: AppDesign.edgeHit,
                right: AppDesign.edgeHit,
                top: 0,
                height: AppDesign.edgeHit + pad.top,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragDown: (_) => _pressEdge(GlassLayer.group),
                  onVerticalDragUpdate: (details) =>
                      _applyDelta(GlassLayer.group, details.delta.dy, size.height),
                  onVerticalDragEnd: (details) =>
                      _snap(GlassLayer.group, details.velocity.pixelsPerSecond.dy, size.height),
                  onVerticalDragCancel: () => _cancel(GlassLayer.group, size.height),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sheet({
    required GlassLayer layer,
    required Color color,
    required String title,
    required String emptyLabel,
    required List<TimelineEntry> todos,
    required Size size,
    required EdgeInsets pad,
    required EntryOwner owner,
  }) {
    final controller = _controller(layer);
    final t = controller.value;
    if (t <= 0.03 && _active != layer) return const SizedBox.shrink();

    final paintT = t.clamp(0.0, 1.0);
    final offset = switch (layer) {
      GlassLayer.mine => Offset(-size.width * (1 - paintT), 0),
      GlassLayer.partner => Offset(size.width * (1 - paintT), 0),
      GlassLayer.group => Offset(0, -size.height * (1 - paintT)),
    };
    final isTop = _topmost == layer;
    final canAdd = owner != EntryOwner.partner;
    final openEnough = paintT > 0.35;

    Widget pane = GlassPane(
      color: color,
      child: Stack(
        fit: StackFit.expand,
        children: [
          StickerField(
            entries: todos,
            progress: paintT,
            emptyLabel: emptyLabel,
            onToggle: widget.onToggle,
            onDelete: widget.onDelete,
            onEdited: widget.onEdited,
            viewPadding: pad,
          ),
          Positioned(
            top: (pad.top - AppDesign.glassInset).clamp(0.0, 80.0),
            left: 0,
            right: 0,
            child: GlassHeader(title: title, color: color, progress: paintT),
          ),
          if (canAdd)
            Positioned(
              top: pad.top + AppDesign.edgeHit + 4,
              right: AppDesign.edgeHit + 8,
              child: Opacity(
                opacity: paintT,
                child: IconButton.filledTonal(
                  tooltip: 'Add to-do',
                  onPressed: () => widget.onAddTodo(owner),
                  icon: const Icon(Icons.add),
                ),
              ),
            ),
          if (isTop && paintT > 0.5)
            switch (layer) {
              GlassLayer.mine => const Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: SheetHandle(color: AppDesign.meColor, axis: Axis.vertical),
              ),
              GlassLayer.partner => const Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: SheetHandle(color: AppDesign.partnerColor, axis: Axis.vertical),
              ),
              GlassLayer.group => Positioned(
                top: pad.top + 8,
                left: 0,
                right: 0,
                child: const SheetHandle(
                  color: AppDesign.sharedColor,
                  axis: Axis.horizontal,
                ),
              ),
            },
        ],
      ),
    );

    // Dismiss from anywhere on the top sheet. Reveal edges sit above this
    // in the parent stack, so they still open the other glasses.
    if (isTop && openEnough) {
      pane = switch (layer) {
        GlassLayer.mine || GlassLayer.partner => GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragDown: (_) => _begin(layer),
          onHorizontalDragUpdate: (details) =>
              _applyDelta(layer, details.delta.dx, size.width),
          onHorizontalDragEnd: (details) =>
              _snap(layer, details.velocity.pixelsPerSecond.dx, size.width),
          onHorizontalDragCancel: () => _cancel(layer, size.width),
          child: pane,
        ),
        GlassLayer.group => GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragDown: (_) => _begin(layer),
          onVerticalDragUpdate: (details) =>
              _applyDelta(layer, details.delta.dy, size.height),
          onVerticalDragEnd: (details) =>
              _snap(layer, details.velocity.pixelsPerSecond.dy, size.height),
          onVerticalDragCancel: () => _cancel(layer, size.height),
          child: pane,
        ),
      };
    }

    return Transform.translate(
      key: Key('glass-${layer.name}'),
      offset: offset,
      child: IgnorePointer(
        ignoring: paintT <= 0.04,
        child: pane,
      ),
    );
  }
}
