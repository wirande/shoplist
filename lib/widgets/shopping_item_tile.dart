import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/item.dart';

class ShoppingItemTile extends StatelessWidget {
  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const ShoppingItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.2,
          children: [
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: const Color(0xFFE74C3C),
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          elevation: item.checked ? 0 : 2,
          shadowColor: Colors.black12,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Emoji
                  if (item.emoji != null && item.emoji!.isNotEmpty)
                    Text(item.emoji!, style: const TextStyle(fontSize: 24)),
                  if (item.emoji == null || item.emoji!.isEmpty)
                    const Icon(Icons.shopping_basket_outlined,
                        size: 24, color: Color(0xFF2D6A4F)),
                  const SizedBox(width: 12),
                  // Name
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: item.checked
                            ? const Color(0xFFAAAAAA)
                            : const Color(0xFF1A1A2E),
                        decoration:
                            item.checked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  // Checkbox
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.checked
                          ? const Color(0xFF2D6A4F)
                          : Colors.transparent,
                      border: Border.all(
                        color: item.checked
                            ? const Color(0xFF2D6A4F)
                            : const Color(0xFFCCCCCC),
                        width: 2,
                      ),
                    ),
                    child: item.checked
                        ? const Icon(Icons.check,
                            size: 16, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
