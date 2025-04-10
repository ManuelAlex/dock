import 'dart:ui';
import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (IconData e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T extends Object> extends StatefulWidget {
  const Dock({super.key, this.items = const [], required this.builder});

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T extends Object> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();
  int? _hoveredIndex;
  // Aesthetic using getters and setters for setstates that are occuring in multiply places
  int? get hoveredIndex => _hoveredIndex;
  set hoveredIndex(int? value) => setState(() => _hoveredIndex = value);
  int? _draggedIndex;

  /// Calculates the vertical offset (Y position) for an item in a list based on hover interaction.
  ///
  /// - [index]: The index of the current item.
  /// - [initVal]: The default Y offset when no item is hovered.
  /// - [maxVal]: The maximum Y offset when the item is hovered directly.
  /// - [nonHoverMaxVal]: The Y offset for items near the hovered item but not directly adjacent.
  ///
  /// Behavior:
  /// - If no item is hovered, returns [initVal].
  /// - If the current item is the hovered one (distance 0), returns [maxVal].
  /// - If it's adjacent (distance 1), returns a value between [initVal] and [maxVal].
  /// - If it's two steps away (distance 2), returns a smaller lerp between [initVal] and [maxVal].
  /// - If within 3 items of the hovered one, returns a slight offset toward [nonHoverMaxVal].
  /// - Otherwise, returns [initVal].
  ///
  /// This creates a smooth hover animation effect that emphasizes the hovered item and subtly shifts nearby items.

  double itemYOffset({
    required int index,
    required double initVal,
    required double maxVal,
    required double nonHoverMaxVal,
  }) {
    if (_hoveredIndex == null) {
      return initVal;
    }

    final int distance = (_hoveredIndex! - index).abs();
    final int itemsAffected = _items.length;

    return switch (distance) {
      0 => maxVal,
      1 => lerpDouble(initVal, maxVal, 0.75)!,
      2 => lerpDouble(initVal, maxVal, 0.5)!,
      final d when d < 3 && d <= itemsAffected =>
        lerpDouble(initVal, nonHoverMaxVal, 0.25)!,
      _ => initVal,
    };
  }

  @override
  Widget build(BuildContext context) {
    const double scale = 1.2;
    // Half of the iconSize + icon Padding * a scale of 1.2
    // This  is give on the left and right during draging
    const double itemMarging = (24 + 8) * scale;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            _items.asMap().entries.map((MapEntry<int, T> entry) {
              final int index = entry.key;
              final T item = entry.value;

              final bool isHovered = hoveredIndex == index;
              final bool isDragging = _draggedIndex != null;
              final bool isLastItem = index == _items.length - 1;

              final double yOffSet = itemYOffset(
                index: index,
                initVal: 0,
                maxVal: -15,
                nonHoverMaxVal: -4,
              );

              // Handles the drop action when an item is dragged onto this target.
              // - Removes the dragged item from its original position.
              // - Inserts it at the current target index.
              // - Resets the dragged index to null after the drop.
              void onAcceptWithDetails(DragTargetDetails<T> droppedItem) {
                setState(() {
                  final int draggedIndex = _items.indexOf(droppedItem.data);
                  if (draggedIndex != -1) {
                    _items.removeAt(draggedIndex);
                    _items.insert(index, droppedItem.data);
                  }
                  _draggedIndex = null;
                });
              }

              bool onWillAcceptWithDetails(DragTargetDetails<T> droppedItem) {
                setState(() {
                  _hoveredIndex = index;
                  _draggedIndex = _items.indexOf(droppedItem.data);
                });
                return true;
              }

              void onLeave(T? item) {
                setState(() {
                  _hoveredIndex = null;
                  _draggedIndex = null;
                });
              }

              return DragTarget<T>(
                onAcceptWithDetails: onAcceptWithDetails,
                onWillAcceptWithDetails: onWillAcceptWithDetails,
                onLeave: onLeave,
                builder: (
                  BuildContext context,
                  List<T?> candidateData,
                  List rejectedData,
                ) {
                  return Draggable<T>(
                    data: item,
                    feedback: Material(
                      color: Colors.transparent,
                      child: Transform.scale(
                        scale: scale,
                        child: widget.builder(item),
                      ),
                    ),
                    childWhenDragging: const SizedBox(),
                    child: MouseRegion(
                      onEnter: (_) => hoveredIndex = index,
                      onExit: (_) => hoveredIndex = null,
                      child: InkWell(
                        onHover: (_) => _hoveredIndex = index,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.bounceOut,
                          transform:
                              Matrix4.identity()..translate(0.0, yOffSet, 0.0),
                          margin: EdgeInsets.only(
                            left: isDragging && isHovered ? itemMarging : 0,
                            right:
                                isDragging && isHovered && isLastItem
                                    ? itemMarging
                                    : 0,
                          ),
                          child: widget.builder(item),
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
      ),
    );
  }
}
