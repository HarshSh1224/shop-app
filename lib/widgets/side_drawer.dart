import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../screens/user_products.dart';
import '../screens/orders_screen.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(title: Text('Shop App'),automaticallyImplyLeading: false,),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            title: Text('Shop'),
            leading: Icon(Icons.shop),
            onTap: (){
              Navigator.of(context).pushNamed('/');
            },
          ),
          Divider(),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            title: Text('Orders'),
            leading: Icon(Icons.payment),
            onTap: (){
              Navigator.of(context).pushNamed(OrdersScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            title: Text('Manage Products'),
            leading: Icon(Icons.edit),
            onTap: (){
              Navigator.of(context).pushNamed(UserProductScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            title: Text('Log Out'),
            leading: Icon(Icons.logout_sharp),
            onTap: (){
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logOut();
            },
          )
        ],
      ),
    );
  }
}