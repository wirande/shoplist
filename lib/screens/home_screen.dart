import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import '../services/shopping_provider.dart';
import '../models/item.dart';
import '../widgets/add_item_sheet.dart';
import '../widgets/shopping_item_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShoppingProvider>().load();
    });
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddItemSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShoppingProvider>();
    final pending = provider.pendingItems;
    final checked = provider.checkedItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0EB),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lista de Compras',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            Text(
              '${pending.length} item${pending.length != 1 ? 's' : ''} pendente${pending.length != 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B6B80),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          if (checked.isNotEmpty)
            TextButton.icon(
              onPressed: () => _confirmClearChecked(context, provider),
              icon: const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF6B6B80)),
              label: const Text('Limpar marcados',
                  style: TextStyle(color: Color(0xFF6B6B80), fontSize: 13)),
            ),
        ],
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : _buildList(pending, checked, provider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        backgroundColor: const Color(0xFF2D6A4F),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Adicionar', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildList(
    List pending,
    List checked,
    ShoppingProvider provider,
  ) {
    if (pending.isEmpty && checked.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🛒', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('Lista vazia!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 8),
            Text('Toque em + para adicionar itens',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        ...pending.map((item) => ShoppingItemTile(
              item: item,
              onToggle: () => provider.toggleItem(item.id),
              onDelete: () => provider.removeItem(item.id),
            )),
        if (checked.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Já no carrinho',
                    style: TextStyle(color: Color(0xFF6B6B80), fontSize: 12)),
              ),
              Expanded(child: Divider()),
            ]),
          ),
          ...checked.map((item) => ShoppingItemTile(
                item: item,
                onToggle: () => provider.toggleItem(item.id),
                onDelete: () => provider.removeItem(item.id),
              )),
        ],
      ],
    );
  }

  void _confirmClearChecked(BuildContext context, ShoppingProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Limpar marcados?'),
        content: const Text('Os itens marcados serão removidos da lista.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              provider.clearChecked();
              Navigator.pop(context);
            },
            child: const Text('Limpar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
