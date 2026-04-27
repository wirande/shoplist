import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/item.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'shoplist.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE catalog (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            emoji TEXT,
            category TEXT,
            use_count INTEGER DEFAULT 1
          )
        ''');
        await db.execute('''
          CREATE TABLE shopping_list (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            emoji TEXT,
            checked INTEGER DEFAULT 0,
            quantity TEXT
          )
        ''');
        await _insertDefaults(db);
      },
    );
  }

  static Future<void> _insertDefaults(Database db) async {
    final defaults = [
      {'id': '1', 'name': 'Leite', 'emoji': '🥛', 'category': 'Laticínios'},
      {'id': '2', 'name': 'Ovos', 'emoji': '🥚', 'category': 'Laticínios'},
      {'id': '3', 'name': 'Pão', 'emoji': '🍞', 'category': 'Padaria'},
      {'id': '4', 'name': 'Manteiga', 'emoji': '🧈', 'category': 'Laticínios'},
      {'id': '5', 'name': 'Frango', 'emoji': '🍗', 'category': 'Carnes'},
      {'id': '6', 'name': 'Arroz', 'emoji': '🍚', 'category': 'Grãos'},
      {'id': '7', 'name': 'Feijão', 'emoji': '🫘', 'category': 'Grãos'},
      {'id': '8', 'name': 'Macarrão', 'emoji': '🍝', 'category': 'Grãos'},
      {'id': '9', 'name': 'Tomate', 'emoji': '🍅', 'category': 'Hortifruti'},
      {'id': '10', 'name': 'Alface', 'emoji': '🥬', 'category': 'Hortifruti'},
      {'id': '11', 'name': 'Banana', 'emoji': '🍌', 'category': 'Frutas'},
      {'id': '12', 'name': 'Maçã', 'emoji': '🍎', 'category': 'Frutas'},
      {'id': '13', 'name': 'Detergente', 'emoji': '🧴', 'category': 'Limpeza'},
      {'id': '14', 'name': 'Papel higiênico', 'emoji': '🧻', 'category': 'Higiene'},
      {'id': '15', 'name': 'Café', 'emoji': '☕', 'category': 'Bebidas'},
      {'id': '16', 'name': 'Açúcar', 'emoji': '🍬', 'category': 'Mercearia'},
      {'id': '17', 'name': 'Sal', 'emoji': '🧂', 'category': 'Mercearia'},
      {'id': '18', 'name': 'Azeite', 'emoji': '🫙', 'category': 'Mercearia'},
      {'id': '19', 'name': 'Queijo', 'emoji': '🧀', 'category': 'Laticínios'},
      {'id': '20', 'name': 'Iogurte', 'emoji': '🥛', 'category': 'Laticínios'},
    ];
    for (final item in defaults) {
      await db.insert('catalog', {...item, 'use_count': 1});
    }
  }

  // CATALOG
  Future<List<CatalogItem>> getCatalog({String? query}) async {
    final d = await db;
    final rows = query != null && query.isNotEmpty
        ? await d.query('catalog',
            where: 'name LIKE ?',
            whereArgs: ['%$query%'],
            orderBy: 'use_count DESC')
        : await d.query('catalog', orderBy: 'use_count DESC');
    return rows.map(CatalogItem.fromMap).toList();
  }

  Future<void> addToCatalog(CatalogItem item) async {
    final d = await db;
    await d.insert('catalog', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> incrementCatalogUse(String id) async {
    final d = await db;
    await d.rawUpdate(
        'UPDATE catalog SET use_count = use_count + 1 WHERE id = ?', [id]);
  }

  // SHOPPING LIST
  Future<List<ShoppingItem>> getShoppingList() async {
    final d = await db;
    final rows = await d.query('shopping_list', orderBy: 'checked ASC, name ASC');
    return rows.map(ShoppingItem.fromMap).toList();
  }

  Future<void> addToShoppingList(ShoppingItem item) async {
    final d = await db;
    await d.insert('shopping_list', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> toggleItem(String id, bool checked) async {
    final d = await db;
    await d.update('shopping_list', {'checked': checked ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> removeItem(String id) async {
    final d = await db;
    await d.delete('shopping_list', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearChecked() async {
    final d = await db;
    await d.delete('shopping_list', where: 'checked = 1');
  }

  Future<void> clearAll() async {
    final d = await db;
    await d.delete('shopping_list');
  }
}
