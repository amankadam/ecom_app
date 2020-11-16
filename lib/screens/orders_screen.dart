import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart' show Orders;
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/order_item.dart';
   class OrderScreen extends StatefulWidget {

  static const routeName='/orders';

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override

  void initState() {

     super.initState();
  }
     @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body:FutureBuilder(
        future: Provider.of<Orders>(context,listen: false).fetchAndSetOrders(),
        builder: (ctx,dataSnapshot){
          if(dataSnapshot.connectionState==ConnectionState.waiting){
           return Center(
        child: CircularProgressIndicator(),);
          }else if(dataSnapshot.error!=null){
          return Center(
            child: Text('AN error occured'),
          );
          }else{
            return Consumer<Orders>(
                builder: (ctx,orderData,child)=>
             ListView.builder(
                  itemCount: orderData.orders.length, itemBuilder: (ctx, i) {

                  return OrderItem(
                      orderData.orders[i]);
             }            ));
          }
        },
      ),
    );
  }
}
