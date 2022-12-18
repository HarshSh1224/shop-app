import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../providers/cart.dart';
import '../screens/product_detail_screen.dart';
import '../providers/product.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var authData = Provider.of<Auth>(context);
    final scaffoldMesenger = ScaffoldMessenger.of(context);
    final cartData = Provider.of<Cart>(context);
    final productInfo = Provider.of<Product>(context, listen: false);
    final String imageUrl = productInfo.imageUrl;
    final String title = productInfo.title;
    final String id = productInfo.id;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () => {
            Navigator.of(context)
                .pushNamed(ProductDetailScreen.routeName, arguments: id),
          },
          child: FadeInImage.assetNetwork(
            placeholder: 'assets/images/loader.gif',
            image: imageUrl,
            fit: BoxFit.cover,
          ),
          //     CachedNetworkImage(
          //   imageUrl: imageUrl,
          //   placeholder: (context, url) => Image.asset('assets/images/loader.gif', fit: BoxFit.fitWidth,),
          //   errorWidget: (context, url, error) => new Icon(Icons.error),
          // ),
        ),
        footer: GridTileBar(
          title: Text(
            title,
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.black87,
          trailing: IconButton(
            icon: Icon(Icons.add_shopping_cart),
            color: Theme.of(context).accentColor,
            onPressed: () {
              cartData.addItem(id, title, productInfo.price);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added to cart!'),
                  duration: Duration(seconds: 3),
                  action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        cartData.removeSingle(productInfo.id);
                      }),
                ),
              );
            },
          ),
          leading: Consumer<Product>(
            builder: (ctx, productInfo, child) => IconButton(
              icon: Icon(productInfo.isFavourite
                  ? Icons.favorite_outlined
                  : Icons.favorite_outline_outlined),
              color: Theme.of(context).accentColor,
              onPressed: () async {
                try {
                  await productInfo.toggleFavourite(authData.token!, authData.userId);
                } catch (error) {
                  scaffoldMesenger.hideCurrentSnackBar();
                  scaffoldMesenger.showSnackBar(SnackBar(
                      content: Text('Unable to change favourite status', textAlign: TextAlign.center,)));
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
