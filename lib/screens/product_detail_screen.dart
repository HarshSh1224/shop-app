import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/cart.dart';
import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';
  @override
  Widget build(BuildContext context) {
    final String productId =
        ModalRoute.of(context)!.settings.arguments as String;
    final loadedProduct =
        Provider.of<Products>(context, listen: false).findById(productId);
    final cartData = Provider.of<Cart>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              elevation: 6,
              child: Image.network(loadedProduct.imageUrl)),
            SizedBox(
              height: 6,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                child: Card(
                  // margin: EdgeInsets.all(2),
                  elevation: 9,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          loadedProduct.title,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          '\$${loadedProduct.price}',
                          style: TextStyle(
                              color: Color.fromARGB(255, 84, 83, 83),
                              fontSize: 23),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        RichText(
                            text: TextSpan(
                          // Note: Styles for TextSpans must be explicitly defined.
                          // Child text spans will inherit styles from parent
                          style: const TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(text: 'Description : ',style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: loadedProduct.description,
                                )
                          ],
                        )),
                        SizedBox(
                          height: 30,
                        ),
                        Center(
                          child: ElevatedButton(
                              onPressed: () {
              cartData.addItem(loadedProduct.id, loadedProduct.title, loadedProduct.price);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added to cart!'),
                  duration: Duration(seconds: 3),
                  action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        cartData.removeSingle(loadedProduct.id);
                      }),
                ),
              );
            }, child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text('Add to Cart', style: TextStyle(fontSize: 14),),
                              )),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
