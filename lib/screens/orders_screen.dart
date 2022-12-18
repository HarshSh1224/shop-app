import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart' as ord;
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  static const routeName = '/orders-screen';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoading = false;
  bool _noOrders = true;

  void initState() {
    Future.delayed(Duration.zero).then((_) async {
      setState(() {
        _isLoading = true;
      });
      try {
        await Provider.of<ord.Orders>(context, listen: false)
            .fetchAndSetOrders();
          setState(() {
            _noOrders = false;
          });
      }catch(error){
        // setState(() {
        //   _noOrders = true;
        // });
      }
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<ord.Orders>(context).items;
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : (_noOrders ? Center(child: Text('No Orders Found!')) : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (_, index) => OrderItem(orders[index]),
            )),
    );
  }
}
