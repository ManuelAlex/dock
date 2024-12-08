import 'package:flutter/material.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

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

/// Dock of the reorderable [items].
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T extends Object> extends State<Dock<T>> {
  late final List<T> _items = widget.items.toList();
  //Aesthetics 
  int? _dragItemIndex;
   int? get dragItemIndex=>_dragItemIndex; 
  set dragItemIndex(int? index)=>setState(() =>_dragItemIndex=index);
  bool _isOutBound= false;
  bool get isOutBound=>_isOutBound;
  set  isOutBound (bool value)=>setState(() =>_isOutBound=value);
  int? _hoveredIndex;
  int? get hoveredIndex=>_hoveredIndex; 
  set hoveredIndex(int? index)=>setState(() =>_hoveredIndex=index);

 



  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const double itemSize = 48; // Item size for the dragging area derived from predefined dock size
    const double padding = 8.0; 
    double offset = 0;// offsets at hover, this gets re-assigned dynamically
    double dragOffset = padding; // Maximum height increase for dragged item
    const int affectedItemsCount = 3; // Number of items to affect on each side during hover

    // Called when a drag starts, set the index of the item being dragged
    void onDragStart(int index) => dragItemIndex = index;
    
    // get each hover position from global offset
 int getHoverPosition(BuildContext context, double itemSize, Offset position) { 
    final double containerWidth = _items.length * (itemSize+(padding/2));
    final double containerLeft = (screenSize.width - containerWidth) / 2;

    final double relativeX = position.dx - containerLeft;
    final int hoverIndex = (relativeX ~/ itemSize).clamp(0, _items.length - 1);
    return hoverIndex;
  }
void checkBounds(T item, Offset position) {
  const double tolerance =padding;//due to the displacsement upon hover
  final double screenHeight = MediaQuery.of(context).size.height;
  final double regionStartY = (screenHeight / 2) - (itemSize / 2) + (padding / 2);
  final double regionEndY = (screenHeight / 2) + (itemSize / 2) - (padding / 2)-tolerance;

  final bool isOut = position.dy < regionStartY || position.dy > regionEndY;
  
  if (_isOutBound != isOut) {
     isOutBound = isOut;
  }
}

    // Updates the hover preview and swaps items
    void shouldUpdatePreview(Offset position) {
      int hoverIndex = getHoverPosition(context, itemSize, position);

      if (_dragItemIndex != hoverIndex) {
        setState(() {
          final T draggedItem = _items.removeAt(_dragItemIndex!);
          _items.insert(hoverIndex, draggedItem);
          _dragItemIndex = hoverIndex;
        });
      }
      
    }
    return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    color: Colors.black12,
  ),
  padding: const EdgeInsets.all(4),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: _items.map((T item) {
      int index = _items.indexOf(item);     

    // Calculate height offset and curve effect based on hover position and drag offset
if (_hoveredIndex != null) {
  int distance = (_hoveredIndex! - index).abs();
  if (distance <= affectedItemsCount) {
    // Create a curve effect  => quadratic decrement
    offset = dragOffset * (1 - (distance / affectedItemsCount).clamp(0.0, 1.0));
  }
}

// Apply transformation to create a "curve" effect
  Widget child = Transform.translate(
  offset: Offset(0, -offset), // Move items upwards based on calculated offset
  child: Transform.scale(
    scale: 1 + (offset / dragOffset * 0.05), // Slightly scale for hover effect
    child: widget.builder(item),
  ),
    );

      if (_dragItemIndex != null && _items[_dragItemIndex!] == item) {
        child = Opacity(
         opacity: 0,
          child: child,
        );
         if (_isOutBound ) {
        child= const SizedBox.shrink(); // Hide item when out of bounds
      }
      }
      return MouseRegion(
         cursor: SystemMouseCursors.click,
           onEnter: (_) {
              if (_dragItemIndex == null) {
                  hoveredIndex = index;      
              }
            },
            onExit: (_) {
              if (_hoveredIndex == index) {         
                 hoveredIndex = null;   
              }
            },
        child: DropRegion(
          formats: Formats.standardFormats,
          onDropOver: (DropOverEvent event) {
            shouldUpdatePreview(event.position.global);
             checkBounds(item, event.position.global);
            return DropOperation.copy;
          },
          onDropEnded: (event) {     
              dragItemIndex = null;
              isOutBound=false;  
          },
          onPerformDrop: (PerformDropEvent event) async { 
          
          },
          child: Draggable<T>(
            data: item,
            feedback: child,
            child: DockDragableWidget(
              data: index,
              onDragStart: () => onDragStart(_items.indexOf(item)),
              child: child,
            ),
          ),
        ),
      );
    }).toList(),
  ),
);

  }


}



class DockDragableWidget extends StatelessWidget {
  const DockDragableWidget({super.key,required this.child,required this.data,required this.onDragStart,});
  final int data;
  final VoidCallback onDragStart;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DragItemWidget(dragItemProvider: (DragItemRequest p0) {
      onDragStart();
      final DragItem dragItem=DragItem(localData: data);
      return dragItem;
    },
    allowedOperations: ()=>[DropOperation.copy],
    dragBuilder: (context, child) => child,
    
    child: DraggableWidget(
     
      child: child),
    );
    
  }
}