import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Product with ChangeNotifier {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> imageUrls;
  final String category;
  final List<String> availableSizes;
  final List<Color> availableColors; // Usaremos Color diretamente aqui

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrls,
    required this.category,
    this.availableSizes = const ['P', 'M', 'G', 'GG'],
    this.availableColors = const [
      Color(0xFF000000), // Preto
      Color(0xFFFFFFFF), // Branco
      Color(0xFF808080), // Cinza
      Color(0xFF0000FF), // Azul
      Color(0xFFFF0000), // Vermelho
    ],
  });
}