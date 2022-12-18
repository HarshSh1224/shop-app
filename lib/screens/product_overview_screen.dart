import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../widgets/side_drawer.dart';
import '../screens/cart_screen.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import '../widgets/products_grid.dart';

enum Favourite { only, all }

class ProductOverview extends StatefulWidget {

  static const routeName = '/product-overview-screen';

  @override
  State<ProductOverview> createState() => _ProductOverviewState();
}

class _ProductOverviewState extends State<ProductOverview> {
  bool _showOnlyFavourite = false;
  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    if (!_isInitialized) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
      _isInitialized = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Shop'),
        actions: [
          PopupMenuButton(
            color: Color.fromARGB(221, 32, 32, 32),
            onSelected: (value) {
              if (value == Favourite.only) {
                setState(() {
                  _showOnlyFavourite = true;
                });
              } else {
                setState(() {
                  _showOnlyFavourite = false;
                });
              }
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                  child: Text('Show Only Favourites',
                      style: TextStyle(color: Colors.white)),
                  value: Favourite.only),
              PopupMenuItem(
                  child:
                      Text('Show All', style: TextStyle(color: Colors.white)),
                  value: Favourite.all),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch!,
              value: '${cart.noOfItems}',
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: SideDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavourite),
    );
  }
}
