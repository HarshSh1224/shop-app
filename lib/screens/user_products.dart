import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/edit_product_screen.dart';
import '../widgets/side_drawer.dart';
import '../widgets/user_product_item.dart';
import '../providers/products.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = '/user-product-screen';
  const UserProductScreen({super.key});

  Future<void> _onRefresh(BuildContext context) {
    return Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsInfo = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName,
                  arguments: 'noIdDueToNewProduct');
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _onRefresh(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _onRefresh(context),
                    child: Consumer<Products>(
                      builder: (ctx, productsInfo, ch) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: productsInfo.items.length < 1
                            ? Center(
                                child: Text(
                                    'You dont own any products.\nTry adding some using the + icon', textAlign: TextAlign.center,))
                            : ListView.builder(
                                itemBuilder: (_, index) {
                                  return UserProductItem(
                                      productsInfo.items[index].id,
                                      productsInfo.items[index].title,
                                      productsInfo.items[index].imageUrl);
                                },
                                itemCount: productsInfo.items.length,
                              ),
                      ),
                    ),
                  ),
      ),
      drawer: SideDrawer(),
    );
  }
}
