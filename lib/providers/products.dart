import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exception.dart';
import './product.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product>_items = [];

  List<Product> get getFavouriteItems {
    return _items.where((element) => element.isFavourite).toList();
  }
final String authToken;
  final String userId;

  Products(this.authToken,this._items,this.userId);
  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((prod) =>
    prod.id == id
    );
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url = 'https://shop-7d99e.firebaseio.com/products/$id.json';
      await http.patch(url, body: json.encode({
        'title': newProduct.title,
        'description': newProduct.description,
        'imageUrl': newProduct.imageUrl,
        'price': newProduct.price,

      }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {

    }
  }

  Future<void> fetchAndSetProduct([bool filterByUser=false]) async {
    final filterString=filterByUser?'orderBy="creatorId"&equalTo="$userId"':'';
    var  url = 'https://shop-7d99e.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final res = await http.get(url);
      final extractedData = json.decode(res.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];

      if(extractedData==null) return;

      final favRes=await http.get('https://shop-7d99e.firebaseio.com/userFavourites/$userId.json?auth=$authToken');
      final favData=json.decode(favRes.body);
      extractedData.forEach((prodId, prodData) {

        loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavourite:favData==null?false: favData[prodId]??false
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
   final url = 'https://shop-7d99e.firebaseio.com/products.json?auth=$authToken';
    try {
      final res = await http.post(url, body: json.encode({
        'title': product.title,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'price': product.price,
        'creatorId':userId
      }));
      final newProduct = Product(
        title: product.title,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
        id: json.decode(res.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }


  Future<void> deleteProduct(String id) async {
    final url = 'https://shop-7d99e.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((element) =>
    element.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final res = await http.delete(url);

    if (res.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }

}