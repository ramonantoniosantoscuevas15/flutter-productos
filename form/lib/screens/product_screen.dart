import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:form/iu/input_decoration.dart';

import 'package:form/widgets/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/providers.dart';
import '../services/services.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productServices = Provider.of<ProductsServices>(context);
    return ChangeNotifierProvider(
      create: (_) => ProductFormProvider(productServices.selectedProduct!),
      child: _ProductScreenBody(productServices: productServices),
    );
  }
}

class _ProductScreenBody extends StatelessWidget {
  const _ProductScreenBody({
    Key? key,
    required this.productServices,
  }) : super(key: key);

  final ProductsServices productServices;

  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ProductImage(
                  url: productServices.selectedProduct!.picture,
                ),
                Positioned(
                    top: 60,
                    left: 20,
                    child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 40,
                          color: Colors.white,
                        ))),
                Positioned(
                    top: 60,
                    right: 20,
                    child: IconButton(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final XFile? pickedFile = await picker.pickImage(
                              source: ImageSource.camera, imageQuality: 100);
                          if (pickedFile == null) {
                            return;
                          }

                          productServices
                              .updateSelectedProductImage(pickedFile.path);
                        },
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.white,
                        ))),
              ],
            ),
            const _ProductForm(),
            const SizedBox(
              height: 100,
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: productServices.isSaving
        ? null
        :
        () async {
          if (!productForm.isValidForm()) return;
          final String? imageUrl = await productServices.uploadImage();

          if (imageUrl != null) productForm.product.picture = imageUrl;

          await productServices.saveOrCreateProduct(productForm.product);
        },
        child:  productServices.isSaving
        ? const CircularProgressIndicator(color:  Colors.white,)
        : const Icon(
          Icons.save,
        ),
      ),
    );
  }
}

class _ProductForm extends StatelessWidget {
  const _ProductForm({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);
    final product = productForm.product;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        decoration: _boxDecoration(),
        child: Form(
            key: productForm.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  initialValue: product.name,
                  onChanged: (value) => product.name = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El Nombre es Obligatorio';
                    }
                    return null;
                  },
                  decoration: InputDecorations.authInputDecoration(
                      hintText: 'Nombre del Producto', labelText: 'Nombre:'),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  initialValue: '${product.price}',
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^(\d+)?\.?\d{0,2}'))
                  ],
                  onChanged: (value) {
                    if (double.tryParse(value) == null) {
                      product.price = 0;
                    } else {
                      product.price = double.parse(value);
                    }
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecorations.authInputDecoration(
                      hintText: '\$150', labelText: 'Precio:'),
                ),
                const SizedBox(
                  height: 30,
                ),
                SwitchListTile.adaptive(
                    value: product.available,
                    title: const Text('Disponible'),
                    activeColor: Colors.indigo,
                    onChanged: productForm.updateAvailability),
                const SizedBox(
                  height: 30,
                ),
              ],
            )),
      ),
    );
  }

  BoxDecoration _boxDecoration() => BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 5),
                blurRadius: 5)
          ]);
}
