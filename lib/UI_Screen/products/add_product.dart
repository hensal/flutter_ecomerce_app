import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shop_ecommerce/API_Service/products/add_produt_service.dart';
import 'package:image/image.dart' as img;

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Controllers for the text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _stockQuantityController =
      TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  final List<PlatformFile> _selectedFiles = [];

  // Function to pick images (works on Web, Android, and iOS)
  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.files);
      });
    }
  }

  // Function to compress and convert the image to base64
  Future<String?> _compressAndUploadImage(PlatformFile file) async {
    // For web, use image package to compress the image
    if (file.bytes != null) {
      Uint8List bytes = file.bytes!;

      // Web-specific image compression using the 'image' package
      img.Image? image = img.decodeImage(Uint8List.fromList(bytes));
      if (image != null) {
        // Resize the image (if necessary)
        img.Image resizedImage = img.copyResize(image, width: 600, height: 600);

        // Compress image
        List<int> compressedImage =
            img.encodePng(resizedImage, level: 9); // Compression level

        return base64Encode(Uint8List.fromList(
            compressedImage)); // Return base64 encoded image data
      }
    }

    return null; // If compression failed, return null
  }

  Future<void> _submitProduct() async {
    final product = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'price': _priceController.text,
      'discount': _discountController.text,
      'stock_quantity': int.parse(_stockQuantityController.text),
      'category_id': _categoryController.text,
      'rating': _ratingController.text,
      'brand': _brandController.text,
      'weight': _weightController.text,
      'tags': _tagsController.text.split(','),
    };

    // Compress and prepare the image data
    List<String> imageUrls = [];
    for (var file in _selectedFiles) {
      if (file.bytes != null) {
        // Compress and upload the image
        String? compressedImage = await _compressAndUploadImage(file);
        if (compressedImage != null) {
          imageUrls.add('data:image/png;base64,$compressedImage');
        }
      }
    }

    product['image_url'] = imageUrls.join(',');

    final productService = ProductService();
    try {
      final isSuccess = await productService.submitProduct(product);

      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully')));
        _clearForm();
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add product: $e')));
    }
  }

  // Function to clear form fields
  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _discountController.clear();
    _stockQuantityController.clear();
    _categoryController.clear();
    _ratingController.clear();
    _brandController.clear();
    _weightController.clear();
    _tagsController.clear();
    setState(() {
      _selectedFiles.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Form for product details
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _discountController,
                decoration: const InputDecoration(labelText: 'Discount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _stockQuantityController,
                decoration: const InputDecoration(labelText: 'Stock Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: _ratingController,
                decoration: const InputDecoration(labelText: 'Rating'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
              ),
              TextField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight'),
              ),
              TextField(
                controller: _tagsController,
                decoration:
                    const InputDecoration(labelText: 'Tags (comma separated)'),
              ),
              const SizedBox(height: 20),

              // Button to pick images
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Add Product Images'),
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              ),

              const SizedBox(height: 20),

              // Display selected images in a grid
              _selectedFiles.isNotEmpty
                  ? GridView.builder(
                      shrinkWrap: true,
                      itemCount: _selectedFiles.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        final file = _selectedFiles[index];
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: file.bytes != null
                                ? Image.memory(file.bytes!, fit: BoxFit.cover)
                                : Image.file(File(file.path!),
                                    fit: BoxFit.cover),
                          ),
                        );
                      },
                    )
                  : const Center(child: Text('No images selected')),

              const SizedBox(height: 20),

              // Submit button
              ElevatedButton(
                onPressed: _submitProduct,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Submit Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
