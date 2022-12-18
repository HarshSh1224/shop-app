import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product-screen';
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageURLFocusNode = FocusNode();
  final _imageURLController = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool isLoading = false;

  Product _editedProduct = Product(
    id: 'empty',
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  Map<String, String> _initValues = {
    'title': '',
    'price': '',
    'imageUrl': '',
    'description': '',
  };

  @override
  void initState() {
    _imageURLFocusNode.addListener(_updateImage);
    super.initState();
  }

  bool isInit = false;

  @override
  void didChangeDependencies() {
    if (!isInit) {
      final String id = ModalRoute.of(context)!.settings.arguments as String;
      if (id != 'noIdDueToNewProduct') {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(id);
        _initValues = {
          'title': _editedProduct.title,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
          'description': _editedProduct.description,
        };
        _imageURLController.text = _editedProduct.imageUrl;
        print('Received ID is :${_editedProduct.isFavourite}');
      }
    }
    isInit = true;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageURLFocusNode.removeListener(_updateImage);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageURLController.dispose();
    _imageURLFocusNode.dispose();
    super.dispose();
  }

  void _updateImage() {
    setState(() {});
  }

  void _saveForm() async {
    final isValid = _form.currentState?.validate();
    if (!isValid!) {
      return;
    }

    _form.currentState?.save();
    setState(() {
      isLoading = true;
    });

    if (_editedProduct.id != 'empty') {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('An error occured'),
                content: Text('Something Went Wrong'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Okay'))
                ],
              );
            });
      }
    }
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add or Edit Product'),
        actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.done))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(13.0),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(
                          child: Container(
                        height: 110,
                        width: 110,
                        // child: Image.asset('assets/images/add_image.png'),
                        child: (!(_imageURLController.text.isEmpty))
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(55),
                                child: Image.network(
                                  _imageURLController.text,
                                  fit: BoxFit.fitWidth,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                    color: Colors.black54,
                                  ),
                                  Text(
                                    'Add URL',
                                    style: TextStyle(fontSize: 9),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.black54,
                          ),
                          borderRadius: BorderRadius.circular(55),
                        ),
                      )),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Title'),
                        initialValue: _initValues['title'],
                        textInputAction: TextInputAction.next,
                        validator: ((value) {
                          if (value!.isEmpty)
                            return 'This value is required.';
                          else
                            return null;
                        }),
                        onFieldSubmitted: ((value) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        }),
                        onSaved: (newValue) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            title: newValue!,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl,
                            isFavourite: _editedProduct.isFavourite,
                          );
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Price'),
                        initialValue: _initValues['price'],
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        validator: ((value) {
                          if (value!.isEmpty) return 'This value is required.';
                          if (double.tryParse(value) == null)
                            return 'Please provide a valid number';
                          else
                            return null;
                        }),
                        onFieldSubmitted: ((value) {
                          FocusScope.of(context)
                              .requestFocus(_imageURLFocusNode);
                        }),
                        onSaved: (newValue) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: double.parse(newValue!),
                            imageUrl: _editedProduct.imageUrl,
                            isFavourite: _editedProduct.isFavourite,
                          );
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Image URL'),
                        keyboardType: TextInputType.url,
                        focusNode: _imageURLFocusNode,
                        controller: _imageURLController,
                        validator: ((value) {
                          if (value!.isEmpty)
                            return 'This value is required.';
                          // if(!value.startsWith('http')) return 'Please enter a valid URL';
                          else
                            return null;
                        }),
                        onSaved: (newValue) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageUrl: newValue!,
                            isFavourite: _editedProduct.isFavourite,
                          );
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Description'),
                        initialValue: _initValues['description'],
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        validator: ((value) {
                          if (value!.isEmpty)
                            return 'This value is required.';
                          else
                            return null;
                        }),
                        onSaved: (newValue) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: newValue!,
                            price: _editedProduct.price,
                            isFavourite: _editedProduct.isFavourite,
                            imageUrl: _editedProduct.imageUrl,
                          );
                        },
                      ),
                    ],
                  ),
                )),
      ),
    );
  }
}
