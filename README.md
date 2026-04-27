# ShopList — Lista de Compras com Widget Android

## Stack
- Flutter 3.x
- SQLite (sqflite) — dados locais
- home_widget — sincronização com widget Android
- Provider — state management

## Estrutura

```
lib/
  main.dart                    # Entry point + deep link handler
  models/item.dart             # CatalogItem + ShoppingItem
  services/
    database_service.dart      # SQLite (catálogo + lista)
    widget_service.dart        # Sync com home_widget
    shopping_provider.dart     # State management (Provider)
  screens/
    home_screen.dart           # Tela principal
  widgets/
    shopping_item_tile.dart    # Item da lista (swipe to delete)
    add_item_sheet.dart        # Bottom sheet de adição

android/app/src/main/
  kotlin/com/shoplist/app/
    ShopListWidget.kt          # AppWidgetProvider
    ShopListWidgetService.kt   # RemoteViewsService (lista no widget)
  res/
    layout/shop_list_widget.xml     # Layout do widget
    layout/widget_list_item.xml     # Item da lista no widget
    xml/shop_list_widget_info.xml   # Metadata do widget
    drawable/widget_background.xml  # Background arredondado
```

## Setup

### 1. Instalar dependências
```bash
flutter pub get
```

### 2. Configurar AndroidManifest.xml
Copiar o conteúdo de `android/MANIFEST_ADDITIONS.xml` para dentro
da tag `<application>` em `android/app/src/main/AndroidManifest.xml`.

Para a `<activity>` do MainActivity, adicionar também o intent-filter
do deep link (shoplist://).

### 3. Drawables necessários
Criar em `android/app/src/main/res/drawable/`:
- `ic_check_empty.xml` — círculo vazio (24dp)
- `ic_check_filled.xml` — círculo verde com check (24dp)

Exemplo ic_check_empty.xml:
```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <stroke android:width="2dp" android:color="#CCCCCC"/>
    <size android:width="22dp" android:height="22dp"/>
</shape>
```

Exemplo ic_check_filled.xml:
```xml
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item>
        <shape android:shape="oval">
            <solid android:color="#2D6A4F"/>
            <size android:width="22dp" android:height="22dp"/>
        </shape>
    </item>
    <item android:drawable="@android:drawable/checkbox_on_background"/>
</layer-list>
```

### 4. Strings (res/values/strings.xml)
Adicionar:
```xml
<string name="widget_description">Lista de compras interativa</string>
```

### 5. Compilar
```bash
flutter build apk --release
```
ou abrir no Android Studio e rodar diretamente.

## Como funciona o widget

1. Ao abrir o app ou modificar a lista → `WidgetService.syncToWidget()` salva o JSON via `home_widget`
2. O `ShopListWidget` (AppWidgetProvider) lê o JSON e popula o `ListView` via `RemoteViewsService`
3. Ao tocar num item no widget → broadcast `TOGGLE_ITEM` → abre o app com deep link `shoplist://toggle?id=XXX`
4. O app processa o deep link e faz o toggle → re-sincroniza o widget

## Funcionalidades

- ✅ Lista de compras com itens pendentes e marcados
- ✅ Catálogo interno que cresce com o uso
- ✅ Busca no catálogo ao adicionar
- ✅ Swipe para deletar item
- ✅ Widget na home screen com lista completa
- ✅ Marcar item como comprado direto no widget
- ✅ Contagem de itens pendentes no header do widget
- ✅ Catálogo pré-carregado com 20 itens comuns
