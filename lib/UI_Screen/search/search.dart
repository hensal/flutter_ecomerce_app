import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchFormFieldUI extends StatefulWidget {
  const SearchFormFieldUI({super.key});

  @override
  State<SearchFormFieldUI> createState() => _SearchFormFieldUIState();
}

class _SearchFormFieldUIState extends State<SearchFormFieldUI> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSearchList = false;

  // Holds recent search items retrieved from the server
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _showSearchList = _focusNode.hasFocus;
      });
    });
    _fetchSearchItems();  // Fetch the stored search items
  }

  // Function to fetch search items from the server
  Future<void> _fetchSearchItems() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3006/get_search_items'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _recentSearches = List<String>.from(data['search_items']);
        });
      } else {
        // Handle error
        print('Failed to load search items');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to save search item to the server
  Future<void> _saveSearchItem(String searchText) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3006/save_search_item'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'search_text': searchText}),
      );

      if (response.statusCode == 200) {
        // Optionally fetch the updated list of search items
        _fetchSearchItems();
      } else {
        // Handle error
        print('Failed to save search item');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      // Save the search text when user submits
                      _saveSearchItem(value);
                      _controller.clear();  // Clear the search field
                    }
                  },
                ),
              ),
              const Icon(
                Icons.search,
                color: Colors.grey,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Display Search List if Focused
        if (_showSearchList)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _recentSearches.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_recentSearches[index]),
                  onTap: () {
                    // Populate search field with selected text
                    _controller.text = _recentSearches[index];
                    setState(() {
                      _showSearchList = false;
                      _focusNode.unfocus();
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
