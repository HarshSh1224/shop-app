import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/splash-screen.dart';
import '../providers/auth.dart';
import '../screens/auth-screen.dart';
import '../screens/edit_product_screen.dart';
import '../screens/user_products.dart';
import '../screens/orders_screen.dart';
import '../providers/orders.dart';
import '../screens/cart_screen.dart';
import '../screens/product_overview_screen.dart';
import '../screens/product_detail_screen.dart';
import '../providers/products.dart';
import '../providers/cart.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (context) => Products(null, [], null),
            update: (context, auth, previousProducts) => Products(
                auth.token ?? '',
                previousProducts == null ? [] : previousProducts.items,
                auth.userId),
          ),
          ChangeNotifierProvider(
            create: (context) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
              create: (context) => Orders(),
              update: (context, auth, previousOrders) =>
                  previousOrders!..receiveToken(auth, previousOrders.items)),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) {
            print('Building Material app');
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Flutter Demo',
              theme: ThemeData(
                primarySwatch: Colors.pink,
                accentColor: Colors.amber,
                fontFamily: 'Anton',
                textTheme: Theme.of(context).textTheme.apply(
                      fontSizeFactor: 0.94,
                    ),
              ),
              // home: ProductOverview(),
              home: auth.isAuth
                  ? ProductOverview()
                  : FutureBuilder(
                      future: auth.tryAutoLogin(),
                      builder:
                          (BuildContext ctx, AsyncSnapshot snapshot) =>
                      //   if (snapshot.hasData) {
                      //     return Text('hasdata ${snapshot.data}');
                      //   } else if (snapshot.hasError) {
                      //     print(snapshot.toString());
                      //     return Text(snapshot.toString());
                      //   } else {
                      //     return Text('No Data');
                      //   }
                      // }
                      snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          // ? SplashScreen()
                          // : (snapshot.data!? ProductOverview() : AuthScreen()),
                          : AuthScreen(),
                      ),
              routes: {
                ProductOverview.routeName: (context) => ProductOverview(),
                ProductDetailScreen.routeName: (context) =>
                    ProductDetailScreen(),
                CartScreen.routeName: (context) => CartScreen(),
                OrdersScreen.routeName: (context) => OrdersScreen(),
                UserProductScreen.routeName: (context) => UserProductScreen(),
                EditProductScreen.routeName: (context) => EditProductScreen(),
              },
            );
          },
        ));
  }
}
