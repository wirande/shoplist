import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/shopping_provider.dart';
import '../models/item.dart';

class AddItemSheet extends StatefulWidget {
  const AddItemSheet({super.key});

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () => _focus.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _addCustom(ShoppingProvider provider) {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    provider.addItem(name);
    Navigator.pop(context);
  }

  void _addFromCatalog(ShoppingProvider provider, CatalogItem item) {
    if (provider.isInList(item.name)) return;
    provider.addItem(item.name, emoji: item.emoji, catalogId: item.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShoppingProvider>();
    final query = _controller.text;
    final catalog = provider.catalog;
    final showCatalog = catalog.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F0EB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Adicionar item',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 16),

          // Search field
          TextField(
            controller: _controller,
            focusNode: _focus,
            onChanged: (v) {
              provider.searchCatalog(v);
              setState(() {});
            },
            onSubmitted: (_) => _addCustom(provider),
            decoration: InputDecoration(
              hintText: 'Buscar ou digitar novo item...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF6B6B80)),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _controller.clear();
                        provider.searchCatalog('');
                        setState(() {});
                      },
                    )
                  : null,
            ),
          ),

          // "Add custom" button when typing something new
          if (query.isNotEmpty && !provider.isInList(query)) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _addCustom(provider),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D6A4F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2D6A4F).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline,
                        color: Color(0xFF2D6A4F), size: 20),
                    const SizedBox(width: 10),
                    Text('Adicionar "$query"',
                        style: const TextStyle(
                            color: Color(0xFF2D6A4F),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],

          // Catalog suggestions
          if (showCatalog) ...[
            const SizedBox(height: 12),
            Text(
              query.isEmpty ? 'Sugestões frequentes' : 'Do catálogo',
              style: const TextStyle(
                  color: Color(0xFF6B6B80),
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: catalog.length > 20 ? 20 : catalog.length,
                itemBuilder: (_, i) {
                  final item = catalog[i];
                  final inList = provider.isInList(item.name);
                  return ListTile(
                    dense: true,
                    leading: Text(item.emoji ?? '🛒',
                        style: const TextStyle(fontSize: 20)),
                    title: Text(item.name,
                        style: TextStyle(
                            color: inList ? Colors.grey : const Color(0xFF1A1A2E),
                            decoration: inList ? TextDecoration.lineThrough : null)),
                    trailing: inList
                        ? const Icon(Icons.check, color: Color(0xFF2D6A4F), size: 18)
                        : const Icon(Icons.add, color: Color(0xFF2D6A4F), size: 18),
                    onTap: inList ? null : () => _addFromCatalog(provider, item),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
