import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreenItem extends StatelessWidget {
  final String id;
  final String title;
  final double price;
  final int quantity;
  void Function(String) removeItem;

  CartScreenItem(
      this.id, this.title, this.price, this.quantity, this.removeItem);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      onDismissed: (direction) {
        removeItem(id);
      },
      direction: DismissDirection.endToStart,
      key: Key(id),
      background: Container(
        child: Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(
              Icons.delete,
              color: Colors.white,
              size: 40,
            )),
        alignment: Alignment.centerRight,
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        color: Theme.of(context).errorColor,
      ),
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text('Are you sure?'),
                content: Text('Do you want to remove item from the cart?'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text('No')),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: Text('Yes')),
                ],
              );
            });
      },
      child: Card(
        elevation: 6,
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: ListTile(
            title: Text(
              title,
              style: TextStyle(fontSize: 15),
            ),
            subtitle: Text('Total : \$${price * quantity}'),
            leading: CircleAvatar(
              child: Padding(
                  padding: EdgeInsets.all(5),
                  child: FittedBox(child: Text('\$${price}'))),
            ),
            trailing: Text('${quantity}x'),
          ),
        ),
      ),
    );
  }
}
