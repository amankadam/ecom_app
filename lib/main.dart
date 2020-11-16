import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/splash_screen.dart';
import './providers/products.dart';
import 'screens/edit_product_screen.dart';
import 'screens/products_overview_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'screens/auth_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value:Auth()),
        ChangeNotifierProxyProvider<Auth,Products>(
          update: (ctx,auth,previousProducts)=>Products(
              auth.token,previousProducts==null ?[]:previousProducts.items,auth.userId),

        ),
        ChangeNotifierProvider.value(value: Cart()),
        ChangeNotifierProxyProvider<Auth,Orders>(
   update: (ctx,auth,previousOrder)=>Orders(
auth.token,previousOrder==null?[]:previousOrder.orders,auth.userId
   ))
      ],
      child:Consumer<Auth>(
        builder: (ctx,auth,_)=> MaterialApp(
        title: 'My Shop',

        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.deepOrange,
          fontFamily: 'Lato'
        ),
        home:auth.isAuth? ProductsOverviewScreen():
        FutureBuilder(
          future: auth.tryAutoLogin(),
          builder: (ctx,authResultSnapshot)=>authResultSnapshot.connectionState==ConnectionState.waiting?SplashScreen():AuthScreen(),
        ),
        routes:{
          ProductDetailScreen.routeName:(ctx)=> ProductDetailScreen(),
          CartScreen.routeName:(ctx)=>CartScreen(),
          OrderScreen.routeName:(ctx)=>OrderScreen(),
          UserProductsScreen.routeName:(ctx)=>UserProductsScreen(),
          EditProductScreen.routeName:(ctx)=>EditProductScreen()
        }
    ),
      ));
  }
}

