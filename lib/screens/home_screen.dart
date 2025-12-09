import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fashion_store_app/data/mock_products.dart';
import 'package:fashion_store_app/widgets/product_card.dart';
import 'package:fashion_store_app/screens/cart_screen.dart';
import 'package:fashion_store_app/providers/cart_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _selectedCategory == null
        ? mockProducts
        : mockProducts
        .where((prod) => prod.category == _selectedCategory)
        .toList();

    final categories =
    mockProducts.map((p) => p.category).toSet().toList(); // Get unique categories

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fashion Store'),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, ch) => Badge(
              label: Text(cart.itemCount.toString()),
              isLabelVisible: cart.itemCount > 0,
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              'Encontre seu estilo!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 50, // Altura para a lista de categorias
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: categories.length + 1, // +1 para "Todos"
              itemBuilder: (ctx, i) {
                final category = i == 0 ? 'Todos' : categories[i - 1];
                final isSelected = _selectedCategory == category ||
                    (i == 0 && _selectedCategory == null);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected && category != 'Todos' ? category : null;
                      });
                    },
                    elevation: 1,
                    pressElevation: 3,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75, // Ajusta a proporção para caber mais verticalmente
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (ctx, i) => ProductCard(product: filteredProducts[i]),
            ),
          ),
        ],
      ),
    );
  }
}