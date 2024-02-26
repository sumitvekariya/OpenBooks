import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: BookDetailsScreen(),
//     );
//   }
// }

class BookDetailsScreen extends StatefulWidget {
  @override
  _BookDetailsScreenState createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  TextEditingController isbnController = TextEditingController();
  Map<String, dynamic> bookDetails = {};
  Future<Map<String, dynamic>> getBookDetails(String isbn) async {
    final apiKey =
        'AIzaSyDGiEMiI9r7CMcBS1RAJgvSp6kKxKeBt2M'; // Replace with your Google Books API key
    final apiUrl =
        'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('items')) {
          // Assuming the first item in the response contains the relevant book details
          final bookInfo = data['items'][0]['volumeInfo'];
          return bookInfo;
        } else {
          // Handle the case when no books are found
          return {'error': 'Book not found'};
        }
      } else {
        // Handle API error
        return {'error': 'Failed to fetch book details'};
      }
    } catch (e) {
      // Handle network or other errors
      return {'error': 'An error occurred: $e'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: isbnController,
              decoration: InputDecoration(labelText: 'Enter ISBN'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                getBookDetails(isbnController.text).then((details) {
                  setState(() {
                    bookDetails = details;
                  });
                });
              },
              child: Text('Fetch Book Details'),
            ),
            SizedBox(height: 20),
            if (bookDetails.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Title: ${bookDetails['title']}'),
                  Text('Author(s): ${bookDetails['authors'][0]}'),
                  Text('Description: ${bookDetails['description']}'),
                  Text(
                      'Description: ${bookDetails['imageLinks']['thumbnail']}'),

                  // Add more fields as needed
                ],
              ),
          ],
        ),
      ),
    );
  }
}
