import 'dart:io';
import 'package:flutter/material.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/utils/image_picker_service.dart';
import '../data/product_service.dart';

class AddProductTestScreen extends StatefulWidget {
  const AddProductTestScreen({super.key});

  @override
  State<AddProductTestScreen> createState() => _AddProductTestScreenState();
}

class _AddProductTestScreenState extends State<AddProductTestScreen> {
  File? imageFile;

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final categoryController = TextEditingController();

  final picker = ImagePickerService();
  final storage = StorageService();
  final productService = ProductService();

  Future<void> pickImage() async {
    final file = await picker.pickImage();

    if (file != null) {
      setState(() {
        imageFile = file;
      });
    }
  }

  Future<void> uploadProduct() async {
    if (imageFile == null) return;

    final productId = DateTime.now().millisecondsSinceEpoch.toString();

    // 1. upload image
    final imageUrl = await storage.uploadImage(imageFile!, productId);

    // 2. save product in firestore
    await productService.addProduct(
      id: productId,
      name: nameController.text,
      price: int.parse(priceController.text),
      category: categoryController.text,
      imageUrl: imageUrl,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Product Added Successfully")),
    );

    setState(() {
      imageFile = null;
      nameController.clear();
      priceController.clear();
      categoryController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[300],
                child: imageFile == null
                    ? const Icon(Icons.add_a_photo)
                    : Image.file(imageFile!, fit: BoxFit.cover),
              ),
            ),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
            ),

            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: "Category"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: uploadProduct,
              child: const Text("Upload Product"),
            ),
          ],
        ),
      ),
    );
  }
}