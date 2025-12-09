import 'package:flutter/material.dart';
import 'package:fashion_store_app/models/product.dart';

final List<Product> mockProducts = [
  Product(
    id: 'p1',
    name: 'Vestido Alfait',
    description:
    'Um vestido clássico, perfeito para qualquer ocasião. Feito com tecido leve e caimento impecável.',
    price: 128000.00,
    imageUrls: [
      'assets/images/dress1.jpg', // Adicione suas imagens aqui
      'assets/images/dress2.jpg',
      'assets/images/dress3.jpg',
    ],
    category: 'Vestidos',
    availableSizes: ['P', 'M', 'G'],
    availableColors: [
      Colors.black, Colors.white, Colors.red[300]!,
    ],
  ),
  Product(
    id: 'p2',
    name: 'Camisa Enchard',
    description:
    'Camisa em algodão pima, ideal para o dia a dia. Conforto e estilo garantidos.',
    price: 89000.00,
    imageUrls: [
      'assets/images/tshirt1.jpg',
      'assets/images/tshirt2.jpg',
    ],
    category: 'Camisetas',
    availableSizes: ['P', 'M', 'G', 'GG'],
    availableColors: [
      Colors.blue[800]!, Colors.grey[700]!, Colors.white,
    ],
  ),
  Product(
    id: 'p3',
    name: 'Tênis Loafers Tassel',
    description:
    'Loafer de couro polido, unidade unica, moderno e versátil, perfeito para caminhadas ou para compor um look casual. Conforto incomparável.',
    price: 500000.00,
    imageUrls: [
      'assets/images/shoe1.jpg',
      'assets/images/shoe2.jpg',
    ],
    category: 'Calçados',
    availableSizes: ['36', '37', '38', '39', '40', '41', '42'],
    availableColors: [
      Colors.black, Colors.white, Colors.deepPurple[300]!,
    ],
  ),
  Product(
    id: 'p4',
    name: 'Jeans Sunny',
    description:
    'Jeans com corte slim, lavagem moderna e tecido com elastano para maior conforto. Essencial no guarda-roupa.',
    price: 150000.00,
    imageUrls: [
      'assets/images/jeans1.jpg',
      'assets/images/jeans2.jpg',
    ],
    category: 'Calças',
    availableSizes: ['38', '40', '42', '44', '46'],
    availableColors: [
      Colors.blue[900]!, Colors.lightBlue, Colors.black,
    ],
  ),
  Product(
    id: 'p5',
    name: 'Jaqueta Croco RedNeck Paradise',
    description:
    'Jaqueta, ideal para os dias mais frios. Com forro interno e detalhes em ribana.',
    price: 750000.00,
    imageUrls: [
      'assets/images/jacket1.jpg',
      'assets/images/jacket2.jpg',
    ],
    category: 'Casacos',
    availableSizes: ['P', 'M', 'G', 'GG'],
    availableColors: [
      Colors.black, Colors.green[800]!, Colors.brown,
    ],
  ),
];