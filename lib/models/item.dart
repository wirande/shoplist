class CatalogItem {
  final String id;
  final String name;
  final String? emoji;
  final String? category;
  int useCount;

  CatalogItem({
    required this.id,
    required this.name,
    this.emoji,
    this.category,
    this.useCount = 1,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'category': category,
        'use_count': useCount,
      };

  factory CatalogItem.fromMap(Map<String, dynamic> m) => CatalogItem(
        id: m['id'],
        name: m['name'],
        emoji: m['emoji'],
        category: m['category'],
        useCount: m['use_count'] ?? 1,
      );
}

class ShoppingItem {
  final String id;
  final String name;
  final String? emoji;
  bool checked;
  final String? quantity;

  ShoppingItem({
    required this.id,
    required this.name,
    this.emoji,
    this.checked = false,
    this.quantity,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'checked': checked ? 1 : 0,
        'quantity': quantity,
      };

  factory ShoppingItem.fromMap(Map<String, dynamic> m) => ShoppingItem(
        id: m['id'],
        name: m['name'],
        emoji: m['emoji'],
        checked: m['checked'] == 1,
        quantity: m['quantity'],
      );

  ShoppingItem copyWith({bool? checked}) => ShoppingItem(
        id: id,
        name: name,
        emoji: emoji,
        checked: checked ?? this.checked,
        quantity: quantity,
      );
}
