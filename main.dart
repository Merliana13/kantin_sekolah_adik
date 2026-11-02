import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider<CartProvider>(
      create: (_) => CartProvider(),
      builder: (context, _) => const KantinApp(),
    ),
  );
}

// --- DATA MODEL ---
class MenuModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;

  const MenuModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
  });
}

class CartItem {
  final MenuModel menu;
  int quantity;
  CartItem({required this.menu, required this.quantity});
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => _items;

  double get totalPrice => _items.fold(0, (sum, item) => sum + (item.menu.price * item.quantity));

  void addToCart(MenuModel menu, int quantity) {
    final existingIndex = _items.indexWhere((item) => item.menu.id == menu.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(menu: menu, quantity: quantity));
    }
    notifyListeners();
  }

  void removeFromCart(String id) {
    _items.removeWhere((item) => item.menu.id == id);
    notifyListeners();
  }
}

// --- APP SETUP ---
class KantinApp extends StatelessWidget {
  const KantinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B35),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// --- HOME PAGE ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<MenuModel> _allMenus = const [
    MenuModel(id: '1', name: 'Mi Ayam', price: 15000, description: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQeNFIdcBi9o6mCC1u4sUnHPL7W3L8mvZfEjtNpfzeUuKTwe3ruMsqbY_o74skQup8lD2j99_MJJch6fiAbaldjUncc2hGUEl7oN6kN491WKQ&s=10', imageUrl: 'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg'),
    MenuModel(id: '2', name: 'Batagor', price: 12000, description: 'Bakso tahu goreng dengan bumbu kacang.', imageUrl: 'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg'),
    MenuModel(id: '3', name: 'Es Teh Manis', price: 3000, description: 'Kesegaran teh dengan es batu.', imageUrl: 'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg'),
    MenuModel(id: '4', name: 'Nasi Goreng', price: 18000, description: 'Nasi digoreng dengan bumbu rempah.', imageUrl: 'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg'),
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _allMenus.where((m) => m.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Kantin Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari makanan...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filtered.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 16),
              itemBuilder: (ctx, i) => Card(
                child: ListTile(
                  leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(filtered[i].imageUrl, width: 50, height: 50, fit: BoxFit.cover)),
                  title: Text(filtered[i].name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Rp ${filtered[i].price.toInt()}'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(menu: filtered[i]))),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- DETAIL PAGE ---
class DetailPage extends StatefulWidget {
  final MenuModel menu;
  const DetailPage({super.key, required this.menu});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.menu.name)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Image.network(widget.menu.imageUrl, height: 200),
            const SizedBox(height: 20),
            Text(widget.menu.description),
            const Spacer(),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(onPressed: () => setState(() => _qty = _qty > 1 ? _qty - 1 : 1), icon: const Icon(Icons.remove)),
              Text('$_qty', style: const TextStyle(fontSize: 20)),
              IconButton(onPressed: () => setState(() => _qty++), icon: const Icon(Icons.add)),
            ]),
            FilledButton(
              onPressed: () {
                Provider.of<CartProvider>(context, listen: false).addToCart(widget.menu, _qty);
                Navigator.pop(context);
              },
              child: Text('Tambah ke Keranjang - Rp ${(widget.menu.price * _qty).toInt()}'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- CART PAGE ---
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang Anda')),
      body: Consumer<CartProvider>(
        builder: (context, provider, _) => Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: provider.items.length,
                itemBuilder: (context, i) {
                  final item = provider.items[i];
                  return ListTile(
                    title: Text(item.menu.name),
                    subtitle: Text('Jumlah: ${item.quantity} | Total: Rp ${(item.menu.price * item.quantity).toInt()}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => provider.removeFromCart(item.menu.id),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Total Tagihan: Rp ${provider.totalPrice.toInt()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
