import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fashion_store_app/providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seu Carrinho'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total:',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Chip(
                    label: Text(
                      'R\$ ${cart.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  TextButton(
                    onPressed: cart.totalAmount <= 0
                        ? null
                        : () {
                      // Lógica para finalizar a compra (ex: navegar para tela de checkout)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Compra finalizada! Total: R\$ ${cart.totalAmount.toStringAsFixed(2)}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      cart.clearCart(); // Limpa o carrinho após a "compra"
                    },
                    child: Text(
                      'FINALIZAR COMPRA',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: cart.itemCount == 0
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.remove_shopping_cart,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Seu carrinho está vazio!',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: cart.itemCount,
              itemBuilder: (ctx, i) {
                final cartItem = cart.items.values.toList()[i];
                final uniqueId = cart.items.keys.toList()[i];

                return Dismissible(
                  key: ValueKey(uniqueId),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 4,
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) {
                    return showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Tem certeza?'),
                        content: const Text(
                            'Deseja remover o item do carrinho?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Não'),
                            onPressed: () {
                              Navigator.of(ctx).pop(false);
                            },
                          ),
                          TextButton(
                            child: const Text('Sim'),
                            onPressed: () {
                              Navigator.of(ctx).pop(true);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    cart.removeItem(uniqueId);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(cartItem.product.imageUrls[0]),
                          radius: 30,
                        ),
                        title: Text(cartItem.product.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tamanho: ${cartItem.selectedSize}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Cor: ',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: cartItem.selectedColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Total: R\$ ${(cartItem.product.price * cartItem.quantity).toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        trailing: Text('${cartItem.quantity}x'),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}