import 'package:flutter/material.dart';
import 'package:form/models/models.dart';
import 'package:form/screens/screens.dart';
import 'package:form/services/services.dart';

import 'package:form/widgets/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsServices = Provider.of<ProductsServices>(context);
    final authServices = Provider.of<AuthServices>(context, listen: false);
    if (productsServices.isLoading) return const LoadingScreen();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () {
              authServices.logout();
              Navigator.pushReplacementNamed(context, 'login');
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: productsServices.products.length,
        itemBuilder: (context, index) => GestureDetector(
            onTap: () {
              productsServices.selectedProduct =
                  productsServices.products[index].copy();
              Navigator.pushNamed(context, 'product');
            },
            child: ProductCard(
              product: productsServices.products[index],
            )),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          productsServices.selectedProduct =
              Product(available: true, name: '', price: 0);
          Navigator.pushNamed(context, 'product');
        },
      ),
    );
  }
}
