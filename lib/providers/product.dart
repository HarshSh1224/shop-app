import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shopapp/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavourite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavourite = false,
  });

  Future<void> toggleFavourite(String _authToken, String userId) async {
    final url = Uri.parse(
        'https://flutter-demo-820f5-default-rtdb.asia-southeast1.firebasedatabase.app/userFavourites/$userId/${this.id}.json?auth=$_authToken');
    final oldFavourite = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    try {
      final response =
          await http.put(url, body: json.encode(isFavourite));
      if (response.statusCode >= 400) {
        isFavourite = oldFavourite;
        notifyListeners();
        throw HttpException('Cant mark as Fav exception');
      }
    } catch (error) {
      isFavourite = oldFavourite;
      notifyListeners();
      throw HttpException('Cant mark as Fav exception');
    }
  }
}
