import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import '../models/item.dart';

class WidgetService {
  static const _appGroupId = 'com.shoplist.app';
  static const _widgetName = 'ShopListWidget';

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
    HomeWidget.registerBackgroundCallback(backgroundCallback);
  }

  static Future<void> syncToWidget(List<ShoppingItem> items) async {
    final pending = items.where((i) => !i.checked).toList();
    final checked = items.where((i) => i.checked).toList();

    final data = [
      ...pending.map((i) => {'id': i.id, 'name': i.name, 'emoji': i.emoji ?? '', 'checked': false}),
      ...checked.map((i) => {'id': i.id, 'name': i.name, 'emoji': i.emoji ?? '', 'checked': true}),
    ];

    await HomeWidget.saveWidgetData<String>('shopping_list', jsonEncode(data));
    await HomeWidget.saveWidgetData<int>('pending_count', pending.length);
    await HomeWidget.updateWidget(
      androidName: _widgetName,
      iOSName: _widgetName,
    );
  }
}

@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  // Handle widget tap callbacks (toggle item from widget)
  // This runs in background isolate
  if (uri?.host == 'toggle') {
    final itemId = uri?.queryParameters['id'];
    if (itemId != null) {
      // Signal to app to toggle item
      await HomeWidget.saveWidgetData<String>('pending_toggle', itemId);
    }
  }
}
