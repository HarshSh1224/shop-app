import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;
  const OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 3,
        child: ListTile(
          title: Text('\$${widget.order.amount}'),
          subtitle: Text(
              DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime)),
              // 'DateTime',),
          trailing: Icon(Icons.expand_more),
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
        ),
      ),
      if (_expanded)
        Container(
            height: min(widget.order.products.length * 20 + 100, 150),
            width: double.infinity,
            // child: Text(widget.order.products[1].title),
            child: Card(
              elevation: 10,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SingleChildScrollView(
                child: Column(
                  children: widget.order.products.map((product) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13.0, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product.title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${product.quantity} x \$${product.price}',
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            )),
    ]);
  }
}
