import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'dart:convert';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  final String? _token;
  final String? _userId;

  Products(this._token, this._items, this._userId);

  Future<void> fetchAndSetProducts([bool userSpecific = false]) async {
    String appdendIf = userSpecific ? '&orderBy="creatorId"&equalTo="$_userId"' : '';
    var url = Uri.parse(
        'https://flutter-demo-820f5-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$_token$appdendIf');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      url = Uri.parse(
          'https://flutter-demo-820f5-default-rtdb.asia-southeast1.firebasedatabase.app/userFavourites/$_userId.json?auth=$_token');
      var favData;
      try {
        final favouriteResponse = await http.get(url);
        favData = json.decode(favouriteResponse.body);
      } catch (error) {
        throw error;
      }
      final List<Product> loadedProducts = [];
      extractedData.forEach((key, value) {
        // print(favData['$key']);
        loadedProducts.add(Product(
          id: key,
          title: value['title'],
          description: value['description'],
          imageUrl: value['imageUrl'],
          price: value['price'],
          isFavourite: favData != null && favData[key] != null ? favData[key] : false,
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favouriteItems {
    return _items.where((prdct) => prdct.isFavourite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> addProduct(Product prduct) async {
    final url = Uri.parse(
        'https://flutter-demo-820f5-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$_token');

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': prduct.title,
          'description': prduct.description,
          'imageUrl': prduct.imageUrl,
          'price': prduct.price,
          'creatorId' : _userId,
        }),
      );

      Product newProduct = Product(
        id: json.decode(response.body)['name'],
        title: prduct.title,
        description: prduct.description,
        price: prduct.price,
        imageUrl: prduct.imageUrl,
      );
      print('Hello ${newProduct.id}');
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(Product prduct) async {
    final url = Uri.parse(
        'https://flutter-demo-820f5-default-rtdb.asia-southeast1.firebasedatabase.app/products/${prduct.id}.json?auth=$_token');

    await http.patch(url,
        body: json.encode({
          'title': prduct.title,
          'description': prduct.description,
          'imageUrl': prduct.imageUrl,
          'price': prduct.price,
        }));

    int i = _items.indexWhere((element) => element.id == prduct.id);
    if (i < 0) {
      print('Error');
      return;
    }
    _items[i] = prduct;
    notifyListeners();
  }

  Future<void> removeProductWithID(String id) async {
    final url = Uri.parse(
        'https://flutter-demo-820f5-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$_token');
    final index = _items.indexWhere((element) => element.id == id);
    Product? copiedProduct = _items[index];
    _items.removeAt(index);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(index, copiedProduct);
      notifyListeners();
      throw HttpException('Cant Delete Product Exception');
    }
    copiedProduct = null;
  }
}
