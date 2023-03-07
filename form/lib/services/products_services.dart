

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:form/models/models.dart';
import 'package:http/http.dart' as http;

class ProductsServices extends ChangeNotifier {
  final String _baseUrl = 'flutter-varios-10b0b-default-rtdb.firebaseio.com';
  final List<Product> products = [];
  Product? selectedProduct;
  final storage = const FlutterSecureStorage();
  File? newPictureFile;
  bool isLoading = true;
  bool isSaving = false;

  ProductsServices() {
    loadProducts();
  }

  Future<List<Product>> loadProducts() async {
    isLoading = true;
    notifyListeners();
    final url = Uri.https(_baseUrl, 'products.json',{
      'auth' : await storage.read(key: 'token') ?? '',
    });
    final resp = await http.get(url);

    final Map<String, dynamic> productsMap = jsonDecode(resp.body);

    productsMap.forEach((key, value) {
      final tempProduct = Product.fromMap(value);
      tempProduct.id = key;
      products.add(tempProduct);
    });
    isLoading = false;
    notifyListeners();
    return products;
  }

  Future saveOrCreateProduct(Product product) async {
    isSaving = true;
    notifyListeners();
    if (product.id == null) {
      //es necesario crear
      await createProduct(product);
    } else {
      // es necesario actualizar
      await updateProduct(product);
    }

    isSaving = false;
    notifyListeners();
  }

  Future<String> updateProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products/${product.id}.json',{
      'auth' : await storage.read(key: 'token') ?? '',
    });
    final resp = await http.put(url, body: product.toJson());
    final decodedData = resp.body;

    final index = products.indexWhere((element) => element.id == product.id);
    products[index] = product;

    return product.id!;
  }

  Future<String> createProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products.json',{
      'auth' : await storage.read(key: 'token') ?? '',
    });
    final resp = await http.post(url, body: product.toJson());
    final decodedData = json.decode(resp.body);
    product.id = decodedData['name'];
    products.add(product);

    return product.id!;
  }

  void updateSelectedProductImage(String path) {
    selectedProduct!.picture = path;
    newPictureFile = File.fromUri(Uri(path: path));

    notifyListeners();
  }

  Future<String?> uploadImage() async {
    if (newPictureFile == null) return null;
    isSaving = true;
    notifyListeners();

    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/drxl0r5x7/image/upload?upload_preset=fgauh42v');

    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file =
        await http.MultipartFile.fromPath('file', newPictureFile!.path);

    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      // ignore: avoid_print
      print('algo salio mal');
      // ignore: avoid_print
      print(resp.body);
      return null;
    }
    newPictureFile = null;
    final decodedData = json.decode(resp.body);
    return decodedData['secure_url'];
  }
}
