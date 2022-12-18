import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart';
import '../widgets/cart_screen_item.dart';
import '../providers/cart.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart-screen';

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<Cart>(context);
    final cartItems = cartData.items.values.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(children: [
        SizedBox(
          height: 8,
        ),
        Card(
          elevation: 6,
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 25, horizontal: 18),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 16),
                  ),
                  Chip(
                    label: Text(
                      '\$${cartData.totalPrice}',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cartItems: cartItems, cartData: cartData)
                ]),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (_, i) {
              return CartScreenItem(
                cartItems[i].id,
                cartItems[i].title,
                cartItems[i].price,
                cartItems[i].quantity,
                cartData.removeItem,
              );
            },
            itemCount: cartItems.length,
          ),
        )
      ]),
    );
  }
}

class OrderButton extends StatefulWidget {

  const OrderButton({
    Key? key,
    required this.cartItems,
    required this.cartData,
  }) : super(key: key);

  final List<CartItem> cartItems;
  final Cart cartData;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: (widget.cartItems.length < 1 || _isLoading) ? null : () async {
          setState(() {
            _isLoading = true;
          });
          await Provider.of<Orders>(context, listen: false).addOrder(
            widget.cartItems,
            widget.cartData.totalPrice,
          );
          setState(() {
            _isLoading = false;
          });
          widget.cartData.clear();
        },
        child: _isLoading ? CircularProgressIndicator() : Text(
          'Order Now',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ));
  }
}
