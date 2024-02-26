import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const BarcodeScreen(),
//     );
//   }
// }

class BarcodeScreen extends StatefulWidget {
  const BarcodeScreen({Key? key}) : super(key: key);

  @override
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
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

  String result = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  var res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SimpleBarcodeScannerPage(),
                      ));

                  await getBookDetails(res).then((details) {
                    setState(() {
                      bookDetails = details;
                    });
                  });

                  setState(() {
                    if (res is String) {
                      result = res;
                    }
                  });
                },
                child: const Text('Open Scanner'),
              ),
              Column(
                children: [
                  Text('Barcode Result: $result'),
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
            ],
          ),
        ),
      ),
    );
  }
}
