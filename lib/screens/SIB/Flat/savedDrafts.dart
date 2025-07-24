import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:login_screen/screens/SIB/Flat/config.dart';
import 'package:login_screen/screens/SIB/Flat/valuation_form.dart';

class SavedDrafts extends StatefulWidget {
  const SavedDrafts({super.key});

  @override
  State<SavedDrafts> createState() => _SavedDraftsState();
}

class _SavedDraftsState extends State<SavedDrafts> {
  DateTime date = DateTime.now();
  List<dynamic> searchResults = [];
  bool isLoading = false;

  Future<void> searchByDate() async {
    setState(() {
      isLoading = true;
      searchResults = []; // Clear previous results
    });

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await http.post(
        Uri.parse(url3),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'date': formattedDate}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          searchResults = data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToValuationForm(Map<String, dynamic> propertyData) {
    final detail = jsonEncode(propertyData);
    debugPrint(detail);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SIBValuationFormScreen(
          // Pass the property data to ValuationFormScreen
          /* initialData: propertyData, */
          propertyData: propertyData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Drafts'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('Select Date'),
              subtitle: Text(DateFormat('dd-MM-yyyy').format(date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2200),
                );
                if (picked != null) {
                  setState(() {
                    date = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: isLoading ? null : searchByDate,
              label: const Text('Search'),
              icon: const Icon(Icons.search),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final property = searchResults[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text('File No: ${property['refNo']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Owner: ${property['nameOfOwner']}'),
                            const SizedBox(height: 4),
                            Text(
                              'Location: ${property['docLocationSketch']}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => navigateToValuationForm(property),
                      ),
                    );
                  },
                ),
              )
            else if (!isLoading)
              const Expanded(
                child: Center(
                  child: Text('No results found'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
