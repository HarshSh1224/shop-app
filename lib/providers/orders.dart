import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shopapp/providers/auth.dart';
import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final DateTime dateTime;
  final List<CartItem> products;

  OrderItem({
    required this.id,
    required this.amount,
    required this.dateTime,
    required this.products,
  });
}

class Orders with ChangeNotifier {

  String? _authToken;
  String? _userId;
  List<OrderItem> _items = [];

  void receiveToken(Auth auth, List<OrderItem> items, ){
    _items = items;
    _authToken = auth.token;
    _userId = auth.userId;
    // print(_authToken);
  }

  List<OrderItem> get items {
    return [..._items];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://flutter-demo-820f5-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$_userId.json?auth=$_authToken');

    try{
    final fetchedData = await http.get(url);
    final extractedData = json.decode(fetchedData.body) as Map<String, dynamic>;
    final List<OrderItem> loadedData = [];
    // if (_authToken == null ) print('$extractedData ');

    if(extractedData.isEmpty){
      return;
    }

    extractedData.forEach((key, value) {
      loadedData.add(OrderItem(
          id: key,
          amount: value['amount'],
          dateTime: DateTime.parse(value['dateTime']),
          products: (value['products'] as List<dynamic>
              ).map((el) => CartItem(
                  id: el['id'],
                  price: el['price'],
                  quantity: el['quantity'],
                  title: el['title']))
              .toList()));
    });

    _items = loadedData.reversed.toList();
    }catch(error){
      // print('ERROROROROROROR');
      throw error;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double amount) async {
    final url = Uri.parse(
        'https://flutter-demo-820f5-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$_userId.json?auth=$_authToken');
    final timeStamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': amount,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts.map((cp) {
            return {
              'id': cp.id,
              'price': cp.price,
              'quantity': cp.quantity,
              'title': cp.title,
            };
          }).toList()
        }));

    // print(json.decode(response.body)['name']);

    _items.insert(
        0,
        OrderItem(
            id: json.decode(response.body)['name'],
            amount: amount,
            dateTime: timeStamp,
            products: cartProducts));
    notifyListeners();
  }
}
