import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shop_app/providers/cart.dart';
class OrderItem {
  final String id;
  final double amount;
  final List<CartItem>products;
  final DateTime dateTime;
  OrderItem({@required
  this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier{

  List<OrderItem> _orders=[];
  final String authToken;
  final String userId;
  Orders(this.authToken,this._orders,this.userId);
List<OrderItem>get orders{
  return [..._orders];
}
Future<void> fetchAndSetOrders()async{
  final url = 'https://shop-7d99e.firebaseio.com/orders/$userId.json?auth=$authToken';
  final res=await http.get(url);
  final List<OrderItem> loadedOrders=[];
  final extractedData=json.decode(res.body) as Map<String,dynamic>;
 if(extractedData==null) return;
  extractedData.forEach((orderId, orderData) {
    loadedOrders.add(OrderItem(id: orderId,
        amount: orderData['amount'],
        dateTime: DateTime.parse(orderData['dateTime']),
        products: (orderData['products'] as List<dynamic>).map((item){
         return CartItem(
           id:item['id'],
           price: item['price'],
           quantity: item['quantity'],
           title: item['title']
         );
        }).toList(),
    ));
  });
  _orders=loadedOrders;
  notifyListeners();
}
Future<void> addOrder(List<CartItem> cartProducts,double total)async{
  final url = 'https://shop-7d99e.firebaseio.com/orders/$userId.json?auth=$authToken';
  final timestamp=DateTime.now();
  final res=await http.post(url,body:json.encode({
'amount':total,
    'dateTime':timestamp.toIso8601String(),
    'products':cartProducts.map((cp)=>{
      'id':cp.id,
      'title':cp.title,
      'price':cp.price,
      'quantity':cp.quantity
  }).toList(),

  }));
  _orders.insert(0, OrderItem(
      id: json.decode(res.body)['name'],
      amount:total,
      products: cartProducts,
      dateTime: DateTime.now()
  ));
  notifyListeners();
}

}