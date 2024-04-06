import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:openbook/Models/book_model.dart';
import 'package:openbook/Models/recieved_book_model.dart';
import 'package:openbook/Models/rented_book_model.dart';
import 'package:openbook/ScreenWidgets/accountbookwidget.dart';
import 'package:openbook/ScreenWidgets/recievedbookwidget.dart';
import 'package:openbook/ScreenWidgets/rentedbookwidget.dart';
import 'package:openbook/TwitterAuth/provider/sign_in_provider.dart';
import 'package:openbook/utils/globalvar.dart';
import 'package:provider/provider.dart';

import '../Models/user_model.dart';

class UserAccountScreen extends StatefulWidget {
  final UserPeopleModel userModel;

  const UserAccountScreen({super.key, required this.userModel});

  @override
  State<UserAccountScreen> createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {
  bool bookloading = false;

  String result = '';
  Map<String, dynamic> bookDetails = {};

  Future<LatLng> getLocationFromAddress(String address) async {
    try {
      List<geo.Location> locations = await geo.locationFromAddress(address);
      if (locations.isNotEmpty) {
        geo.Location location = locations.first;
        return LatLng(location.latitude, location.longitude);
      }
      throw Exception("Location not found for the given address");
    } catch (e) {
      log("Error: $e");
      return const LatLng(0, 0);
    }
  }

  TextEditingController locationcontroller = TextEditingController();

  double? userlat;
  double? userlong;
  String? userlocationname;
  bool isloading = true;

  bool kisloading = true;

  Future<Map<String, dynamic>> getBookDetails(String isbn) async {
    const apiKey = 'AIzaSyDGiEMiI9r7CMcBS1RAJgvSp6kKxKeBt2M'; // Replace with your Google Books API key
    final apiUrl = 'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn&key=$apiKey';

    //https://www.googleapis.com/books/v1/volumes?q=isbn:4577714843828&key=AIzaSyDGiEMiI9r7CMcBS1RAJgvSp6kKxKeBt2M

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('items')) {
          final bookInfo = data['items'][0]['volumeInfo'];
          return bookInfo;
        } else {
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
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60.h),
              Row(
                children: [
                  Text(
                    "User account",
                    style: TextStyle(fontFamily: globalfontfamily, color: Colors.black, fontSize: 28.sp, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: Image.network(
                        widget.userModel!.imageurl,
                        fit: BoxFit.cover,
                      ).image,
                      radius: 50,
                      // child: Image.file(
                      //   selectedImage!,
                      //   fit: BoxFit.cover,
                      // ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.grey[100]),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Row(
                  children: [
                    Text(
                      "Name",
                      style: TextStyle(fontFamily: globalfontfamily, color: Colors.black, fontSize: 16.sp),
                    ),
                    SizedBox(width: 60.w),
                    Expanded(
                      child: Text(
                        widget.userModel!.name,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: TextStyle(fontFamily: globalfontfamily, color: Colors.black, fontSize: 16.sp),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "Books user read :",
                style: TextStyle(fontFamily: globalfontfamily, color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10.h),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(widget.userModel!.uid).collection('Books').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    List<Book> books = snapshot.data!.docs.map((DocumentSnapshot doc) {
                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                      return Book.fromMap(data, doc.id);
                    }).toList();
                    if (books.isEmpty) {
                      return buildNoBooks();
                    } else {
                      return buildBooks(books);
                    }
                  }),
              SizedBox(height: 20.h),
              Text(
                "Received Books",
                style: TextStyle(
                  fontFamily: globalfontfamily,
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10.h),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(widget.userModel!.uid).collection('RecievedBooks').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    List<RecievedBook> books = snapshot.data!.docs.map((DocumentSnapshot doc) {
                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                      return RecievedBook.fromMap(data, doc.id);
                    }).toList();

                    if (books.isEmpty) {
                      return buildNoBooks();
                    } else {
                      return buildBooksReceived(books);
                    }
                  }),
              SizedBox(height: 20.h),
              Text(
                "Rented Books",
                style: TextStyle(fontFamily: globalfontfamily, color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10.h),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(widget.userModel!.uid).collection('RentedBooks').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    List<RentedBook> books = snapshot.data!.docs.map((DocumentSnapshot doc) {
                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                      return RentedBook.fromMap(data, doc.id);
                    }).toList();
                    if (books.isEmpty) {
                      return buildNoBooks();
                    } else {
                      return buildBooksRented(books);
                    }
                  }),
              SizedBox(height: 20.h),
              Text(
                "Invite readers",
                style: TextStyle(fontFamily: globalfontfamily, fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset("assets/images/twitter.png", height: 30.h, width: 30.w),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset("assets/images/telegram.png", height: 30.h, width: 30.w),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset("assets/images/web.png", height: 30.h, width: 30.w),
                  ),
                ],
              ),
              SizedBox(height: 20.h)
            ],
          ),
        ),
      ),
    );
  }

  Container buildBooks(List<Book> books) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.grey[100]),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        itemCount: books.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (BuildContext context, int index) {
          return AccountBookwidget(
            book: books[index],
          );
        },
      ),
    );
  }

  Container buildBooksReceived(List<RecievedBook> books) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.grey[100]),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        itemCount: books.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (BuildContext context, int index) {
          return RecievedBookwidget(
            book: books[index],
          );
        },
      ),
    );
  }

  Container buildBooksRented(List<RentedBook> books) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.grey[100]),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            return RentedBookWidget(book: books[index]);
          }),
    );
  }

  Container buildNoBooks() {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.grey[100]),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Center(
        child: Text(
          "No books available",
          style: TextStyle(
              // fontWeight: FontWeight.bold,
              fontFamily: globalfontfamily,
              fontSize: 13.sp),
        ),
      ),
    );
  }
}
