import 'package:flutter/material.dart';

class LocationPopup extends StatelessWidget {
  // Controllers for each text field
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController streetController = TextEditingController();

  LocationPopup({super.key});

  // Function to save the location
  void _saveLocation(BuildContext context) {
    String postalCode = postalCodeController.text;
    String country = countryController.text;
    String city = cityController.text;
    String street = streetController.text;

    // Handle save location logic, such as saving data locally or sending it to the backend.
    Navigator.pop(context); // Close the dialog
    print('Location saved: $postalCode, $country, $city, $street');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Save Location"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter your location:"),
            const SizedBox(height: 16),
            // Postal Code TextField
            TextField(
              controller: postalCodeController,
              decoration: const InputDecoration(
                labelText: "Postal Code",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Country TextField
            TextField(
              controller: countryController,
              decoration: const InputDecoration(
                labelText: "Country",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // City TextField
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: "City",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Street TextField
            TextField(
              controller: streetController,
              decoration: const InputDecoration(
                labelText: "Street",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Save Button
            ElevatedButton(
              onPressed: () => _saveLocation(context),
              child: const Text("Save Location"),
            ),
          ],
        ),
      ),
    );
  }
}
