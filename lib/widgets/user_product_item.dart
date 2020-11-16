import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String title;
  final String id;
  final String imageUrl;
  UserProductItem(this.id,this.title,this.imageUrl);
  @override
  Widget build(BuildContext context) {
    final scaffold=Scaffold.of(context);
    return ListTile(
      title: Text(title),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(icon:Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
              onPressed: (){
          Navigator.of(context).pushNamed(EditProductScreen.routeName,arguments: id);
            },),
            IconButton(icon:Icon(Icons.delete),
              color: Theme.of(context).errorColor,
              onPressed: ()async{
                try {
                  await Provider.of<Products>(context, listen: false)
                      .deleteProduct(id);
                }catch(error){
                  scaffold.showSnackBar(SnackBar(
                    content:Text('Deleting Failed!',textAlign: TextAlign.center,)
                  ));
                }
                 },),
          ],
        ),
      ),
      leading: CircleAvatar(backgroundImage:NetworkImage(imageUrl),

    ));
  }
}
