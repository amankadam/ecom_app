import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';
class EditProductScreen extends StatefulWidget {
  static const routeName='/edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode=FocusNode();
  final _descriptionFocusNode=FocusNode();
  final _imageUrlFocusNode=FocusNode();
 final _imageUrlController=TextEditingController();
 final _form=GlobalKey<FormState>();

 var _isInit=true;
 var _loading=false;
 var _initValues={
   'title':'',
   'description':'',
   'price':'',
   'imageUrl':''
 };
 var _editedProduct=Product(
   id:null,title:'',price: 0,description:'',imageUrl: '' );
  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }
  @override
  void didChangeDependencies() {
    if(_isInit){
         final productId=ModalRoute.of(context).settings.arguments as String;
         if(productId!=null) {
           _editedProduct =
               Provider.of<Products>(context, listen: false).findById(productId);
           _initValues = {
             'title': _editedProduct.title,
             'description': _editedProduct.description,
             'price': _editedProduct.price.toString(),
               'imageUrl':''
                 };
           _imageUrlController.text=_editedProduct.imageUrl;
         }    }
    super.didChangeDependencies();
  }
  void dispose(){
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }
  Future<void> _saveForm()async{
    final isValid= _form.currentState.validate();
    if(!isValid) return;
     _form.currentState.save();
     setState(() {
       _loading=true;
     });
     if(_editedProduct.id!=null){
       await Provider.of<Products>(context, listen: false).updateProduct(_editedProduct.id,_editedProduct);
     setState(() {
       _loading=false;
     });
       Navigator.of(context).pop();
     }else {
       try {
         await Provider.of<Products>(context, listen: false).addProduct(
             _editedProduct);
       } catch (error) {
         await showDialog<Null>(context: context, builder: (ctx) =>
             AlertDialog(title: Text('An error occured'),
               content: Text('Something Went Wrong'),
               actions: [
                 FlatButton(
                   child: Text('Okay'),
                   onPressed: () {
                     Navigator.of(ctx).pop();
                   },
                 )
               ],
             ));
       }
//       finally {
//         setState(() {
//           _loading = false;
//         });
//         Navigator.of(context).pop();
//       }
         setState(() {
           _loading = false;
         });
         Navigator.of(context).pop();
     }

  }
  void _updateImageUrl(){
if(!_imageUrlFocusNode.hasFocus) {
  if(!_imageUrlController.text.startsWith('http') || !_imageUrlController.text.startsWith('https'))
    return ;
  if(!_imageUrlController.text.endsWith('.png') && !_imageUrlController.text.endsWith('jpg') && !_imageUrlController.text.endsWith('jpeg')){
    return ;
  }
  return null;
  setState(() {

  });
}}
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Product'),
      actions: [
        IconButton(icon:Icon(Icons.save),
        onPressed: _saveForm,
        )
      ],
      ),

      body:_loading ?Center(
        child: CircularProgressIndicator(),
      ):
      Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key:_form,

          child:ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
                initialValue: _initValues['title'],
                onSaved: (v){
                  _editedProduct=Product(title: v,price: _editedProduct.price,description: _editedProduct.description,imageUrl: _editedProduct.imageUrl,
                  isFavourite: _editedProduct.isFavourite,
                  id:_editedProduct.id);
                },
                validator: (v){
                  if(v.isEmpty)return 'Please Provide a value.';
                  return null;
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_){
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Price',
                ),
                initialValue: _initValues['price'],
                validator: (v){
                  if(v.isEmpty) return 'Please enter a Price.';
                  if(double.tryParse(v)==null)
                    return 'Please enter a valid number.';
                 if(double.parse(v)<=0){
                   return 'Please enter a number greater than 0';
                  }
                  },
                onSaved: (v){
                  _editedProduct=Product(title:_editedProduct.title,price:double.parse(v),description: _editedProduct.description,imageUrl: _editedProduct.imageUrl,
                      isFavourite: _editedProduct.isFavourite,
                      id:_editedProduct.id);
                },
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (_){
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
                initialValue: _initValues['description'],
                validator: (v){
                  if(v.isEmpty) return 'Please enter a description';
                  if(v.length<10) return 'Should be at least 10 characters long.';

                },
                onSaved: (v){
                  _editedProduct=Product(title:_editedProduct.title,price:_editedProduct.price,description: v,imageUrl: _editedProduct.imageUrl,
                      isFavourite: _editedProduct.isFavourite,
                      id:_editedProduct.id);
                },
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionFocusNode,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(top:8,right:10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey
                      )
                    ),
                    child: _imageUrlController.text.isEmpty ?
                    Text('Enter a URL'):
                    FittedBox(child: Image.network(_imageUrlController.text),
                    fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      validator: (v){
                        if(v.isEmpty){
                          return 'Please enter an Image URL';
                        }
                        if(!v.startsWith('http') || !v.startsWith('https'))
                          return 'Please enter a valid URL';
                        if(!v.endsWith('.png') && !v.endsWith('jpg') && !v.endsWith('jpeg')){
                          return 'Please enter a valid image URL';
                        }
                        return null;
                          },
                      decoration: InputDecoration(labelText: 'Image URL'),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      focusNode: _imageUrlFocusNode,
                      onFieldSubmitted: (v){
                        _saveForm();
                      },
                        onSaved: (v){
                          _editedProduct=Product(title:_editedProduct.title,price:_editedProduct.price,description: _editedProduct.description,imageUrl:v,
                              isFavourite: _editedProduct.isFavourite,
                              id:_editedProduct.id);
                        },
                    ),
                  )
                ],
              )
            ],
          )
        ),
      ),
    );
  }
}
