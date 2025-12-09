import 'package:flutter/material.dart' hide CarouselController; // <<< CORRIGIDO AQUI
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:fashion_store_app/models/product.dart';
import 'package:fashion_store_app/data/mock_products.dart';
import 'package:fashion_store_app/providers/cart_provider.dart';
import 'package:fashion_store_app/screens/cart_screen.dart'; // <<< ADICIONADO AQUI

class ProductDetailsScreen extends StatefulWidget {
  static const routeName = '/product-details';

  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? _selectedSize;
  Color? _selectedColor;

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)?.settings.arguments as String;
    final loadedProduct =
    mockProducts.firstWhere((prod) => prod.id == productId);

    // Define o primeiro tamanho e cor como padrão se não houver seleção
    if (_selectedSize == null && loadedProduct.availableSizes.isNotEmpty) {
      _selectedSize = loadedProduct.availableSizes[0];
    }
    if (_selectedColor == null && loadedProduct.availableColors.isNotEmpty) {
      _selectedColor = loadedProduct.availableColors[0];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.name),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CarouselSlider(
              options: CarouselOptions(
                height: 300.0,
                enlargeCenterPage: true,
                autoPlay: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                viewportFraction: 0.8,
              ),
              items: loadedProduct.imageUrls.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    loadedProduct.name,
                    style: const TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'R\$ ${loadedProduct.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    loadedProduct.description,
                    style: const TextStyle(
                      fontSize: 16.0,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // Seleção de Tamanho
                  if (loadedProduct.availableSizes.isNotEmpty) ...[
                    Text(
                      'Tamanho:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      children: loadedProduct.availableSizes.map((size) {
                        final isSelected = _selectedSize == size;
                        return ChoiceChip(
                          label: Text(size),
                          selected: isSelected,
                          selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedSize = size;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20.0),
                  ],

                  // Seleção de Cor
                  if (loadedProduct.availableColors.isNotEmpty) ...[
                    Text(
                      'Cor:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      children: loadedProduct.availableColors.map((Color color) { // Tipagem explícita 'Color' adicionada
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.transparent,
                                width: isSelected ? 3.0 : 1.0,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: (_selectedSize == null || _selectedColor == null)
                    ? null // Desabilita se tamanho ou cor não forem selecionados
                    : () {
                  if (_selectedSize != null && _selectedColor != null) {
                    Provider.of<CartProvider>(context, listen: false).addItem(
                      loadedProduct,
                      _selectedSize!,
                      _selectedColor!,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Produto adicionado ao carrinho!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Adicionar ao Carrinho'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}