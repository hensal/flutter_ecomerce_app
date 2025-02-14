import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shop_ecommerce/API_Service/users/profile_update.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  Uint8List? _imageBytes; // To store the selected image bytes
  bool isSaving = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }

Future<void> _saveProfile() async {
  final name = _displayNameController.text.trim();
  final email = _emailController.text.trim();

  if (name.isEmpty || email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Name and email cannot be empty')),
    );
    return;
  }

  if (_imageBytes == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select an image')),
    );
    return;
  }

  setState(() {
    isSaving = true;
  });

  final String base64Image = base64Encode(_imageBytes!);
  final profileService = ProfileService();

  final result = await profileService.updateProfile(
    name: name,
    email: email,
    image: base64Image,
  );

  setState(() {
    isSaving = false;
  });

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Your Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _imageBytes != null
                      ? MemoryImage(_imageBytes!)
                      : const NetworkImage(
                          'https://via.placeholder.com/150',
                        ) as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, size: 28, color: Colors.white),
                    onPressed: _pickImage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
              ),
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Profile', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
