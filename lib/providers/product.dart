import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
class Product with ChangeNotifier{
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavourite=false
  });
  Future<void> toggleFavouriteStatus(String token,String userId)async{
    final oldStatus=isFavourite;
    isFavourite=!isFavourite;
    final url = 'https://shop-7d99e.firebaseio.com/userFavourites/$userId/$id.json?auth=$token';

    try{
    final res= await http.put(url,body:json.encode(
      isFavourite,
    )
    );
    print(res.statusCode);
    if(res.statusCode>=400){
      isFavourite=oldStatus;
    }
    notifyListeners();
  }catch(e){
       isFavourite=oldStatus;
       notifyListeners();
    }
  }
}