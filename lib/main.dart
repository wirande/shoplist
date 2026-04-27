import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:home_widget/home_widget.dart';
import 'services/shopping_provider.dart';
import 'services/widget_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WidgetService.init();
  runApp(const ShopListApp());
}

class ShopListApp extends StatelessWidget {
  const ShopListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShoppingProvider(),
      child: MaterialApp(
        title: 'ShopList',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2D6A4F),
            background: const Color(0xFFF5F0EB),
          ),
          useMaterial3: true,
        ),
        home: const _WidgetCallbackHandler(),
      ),
    );
  }
}

class _WidgetCallbackHandler extends StatefulWidget {
  const _WidgetCallbackHandler();

  @override
  State<_WidgetCallbackHandler> createState() => _WidgetCallbackHandlerState();
}

class _WidgetCallbackHandlerState extends State<_WidgetCallbackHandler> {
  @override
  void initState() {
    super.initState();
    // Listen for widget interactions
    HomeWidget.widgetClicked.listen(_handleWidgetCallback);
  }

  void _handleWidgetCallback(Uri? uri) {
    if (uri?.host == 'toggle') {
      final itemId = uri?.queryParameters['id'];
      if (itemId != null) {
        context.read<ShoppingProvider>().toggleItem(itemId);
      }
    }
  }

  @override
  Widget build(BuildContext context) => const HomeScreen();
}
