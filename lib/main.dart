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
            builder: (e) {
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

class Dock<T extends Object> extends StatefulWidget {
  // T extends Object
  const Dock({super.key, this.items = const [], required this.builder});

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}
class _DockState<T extends Object> extends State<Dock<T>> {
  late final List<T> _items = widget.items.toList();

  T? _draggedItem; // Store the dragged item
  int? _hoveredIndex; // Track the index of the hovered item
  int? _draggedIndex; // Track the index of the dragged item
  double dragOffset = 20; // Maximum height increase for dragged item

  @override
  Widget build(BuildContext context) {
    const double baseSize = 50;
    const int affectedItemsCount = 4; // Number of items to affect on each side
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: _items.asMap().entries.map((entry) {
          int index = entry.key;
          T item = entry.value;

          // Calculate height offset based on hover position and drag offset
          double offset = 0;
          if (_hoveredIndex != null) {
            int distance = (_hoveredIndex! - index).abs();
            if (distance > 0 && distance <= affectedItemsCount) {
              offset = dragOffset - 8 * (distance - 1); // Linear decrement
            } else if (_hoveredIndex == index) {
              offset = dragOffset; // Full height increase for the dragged item
            }
          } else if (_hoveredIndex == index) {
            offset = 10; // Hover effect offset
          }

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) {
              if (_draggedIndex == null) {
                setState(() {
                  _hoveredIndex = index;
                });
              }
            },
            onExit: (_) {
              if (_hoveredIndex == index) {
                setState(() {
                  _hoveredIndex = null;
                });
              }
            },
            child: DragTarget<T>(
              onMove: (DragTargetDetails<T> details) {
                  int hoverIndex = (details.offset.dx / baseSize).floor();
             final int movingIndex =  hoverIndex.clamp(0, _items.length - 1);
                if (_hoveredIndex != movingIndex) {
                  setState(() {
                    _hoveredIndex = movingIndex;
                  });
                }
              },
              onAcceptWithDetails: (details) {
                setState(() {
                  if (_draggedItem != null && _draggedIndex != null) {
                    int newIndex = index >= _draggedIndex! ? index : index + 1;
                    newIndex = newIndex.clamp(0, _items.length);

                    _items.insert(newIndex, _draggedItem!);
                    _draggedItem = null;
                    _draggedIndex = null;
                  }
                });
              },
              onWillAcceptWithDetails: (details) => true,
              builder: (context, candidateData, rejectedData) {
                return Draggable<T>(
                  data: item,
                  feedback: Material(
                    color: Colors.transparent,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: baseSize + dragOffset,
                      width: baseSize + dragOffset,
                      child: widget.builder(item),
                    ),
                  ),
                  onDragStarted: () {
                    if (_items.length - 1 != index) {
                      setState(() {
                        _draggedItem = item;
                        _draggedIndex = index;
                        _items.removeAt(index);
                      });
                    }
                  },
                  onDragUpdate: (details) {
                    setState(() {}); // maybe use this to calculate change in y upon 
                  },
                  onDragCompleted: () {
                    setState(() {
                      _draggedItem = null;
                      _draggedIndex = null;
                    });
                  },
                  onDraggableCanceled: (Velocity velocity, Offset offset) {
                    Future<void>.delayed(const Duration(seconds: 1));
                    setState(() {
                      if (_draggedIndex != null && _draggedItem != null) {
                        _items.insert(_draggedIndex!, _draggedItem!);
                        _draggedItem = null;
                        _draggedIndex = null;
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: baseSize + offset,
                    width: baseSize + offset,
                    child: widget.builder(item),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

}
