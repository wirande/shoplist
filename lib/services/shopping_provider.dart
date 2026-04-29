import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:uuid/uuid.dart';
import '../models/item.dart';
import '../services/database_service.dart';
import '../services/widget_service.dart';

class ShoppingProvider extends ChangeNotifier {
  final _db = DatabaseService();
  final _uuid = const Uuid();

  List<ShoppingItem> _shoppingList = [];
  List<CatalogItem> _catalog = [];
  List<CatalogItem> _filteredCatalog = [];
  bool _loading = false;

  List<ShoppingItem> get shoppingList => _shoppingList;
  List<ShoppingItem> get pendingItems => _shoppingList.where((i) => !i.checked).toList();
  List<ShoppingItem> get checkedItems => _shoppingList.where((i) => i.checked).toList();
  List<CatalogItem> get catalog => _filteredCatalog.isNotEmpty ? _filteredCatalog : _catalog;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _shoppingList = await _db.getShoppingList();
    _catalog = await _db.getCatalog();
    _filteredCatalog = [];
    _loading = false;
    notifyListeners();
    await WidgetService.syncToWidget(_shoppingList);
  }

  Future<void> searchCatalog(String query) async {
    if (query.isEmpty) {
      _filteredCatalog = [];
    } else {
      _filteredCatalog = await _db.getCatalog(query: query);
    }
    notifyListeners();
  }

  Future<void> addItem(String name, {String? emoji, String? catalogId}) async {
    // Add to shopping list
    final item = ShoppingItem(
      id: _uuid.v4(),
      name: name,
      emoji: emoji,
    );
    await _db.addToShoppingList(item);

    // Add/increment in catalog
    if (catalogId != null) {
      await _db.incrementCatalogUse(catalogId);
    } else {
      final catalogItem = CatalogItem(
        id: _uuid.v4(),
        name: name,
        emoji: emoji,
      );
      await _db.addToCatalog(catalogItem);
    }

    await load();
  }

  Future<void> toggleItem(String id) async {
    final idx = _shoppingList.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    final item = _shoppingList[idx];
    await _db.toggleItem(id, !item.checked);
    _shoppingList[idx] = item.copyWith(checked: !item.checked);
    notifyListeners();
    await WidgetService.syncToWidget(_shoppingList);
  }

  Future<void> removeItem(String id) async {
    await _db.removeItem(id);
    _shoppingList.removeWhere((i) => i.id == id);
    notifyListeners();
    await WidgetService.syncToWidget(_shoppingList);
  }

  Future<void> clearChecked() async {
    await _db.clearChecked();
    _shoppingList.removeWhere((i) => i.checked);
    notifyListeners();
    await WidgetService.syncToWidget(_shoppingList);
  }

  Future<void> clearAll() async {
    await _db.clearAll();
    _shoppingList = [];
    notifyListeners();
    await WidgetService.syncToWidget(_shoppingList);
  }

  Future<void> flushWidgetPendingToggles() async {
    final raw = await HomeWidget.getWidgetData<String>('widget_pending_toggle');
    if (raw == null || raw.isEmpty) return;
    await HomeWidget.saveWidgetData<String>('widget_pending_toggle', '');
    await toggleItem(raw);
  }

  bool isInList(String name) =>
      _shoppingList.any((i) => i.name.toLowerCase() == name.toLowerCase());
}
