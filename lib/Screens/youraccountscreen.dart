import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:openbook/ScreenWidgets/accountbookwidget.dart';
import 'package:openbook/ScreenWidgets/recievedbookwidget.dart';
import 'package:openbook/ScreenWidgets/rentedbookwidget.dart';

import 'package:openbook/Screens/onboardingscreen.dart';
import 'package:openbook/utils/globalvar.dart';

import 'package:openbook/Screens/recievedbookscreen.dart';
import 'package:openbook/Models/book_model.dart';
import 'package:openbook/Models/recieved_book_model.dart';
import 'package:openbook/Models/rented_book_model.dart';
import 'package:openbook/Models/user_data_models.dart';
import 'package:openbook/TwitterAuth/provider/sign_in_provider.dart';
import 'package:openbook/utils/global_data.dart';
import 'package:openbook/utils/next_screen.dart';

import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:http/http.dart' as http;

class YourAccountScreen extends StatefulWidget {
  const YourAccountScreen({super.key});

  @override
  State<YourAccountScreen> createState() => _YourAccountScreenState();
}

class _YourAccountScreenState extends State<YourAccountScreen> {
  bool bookloading = false;

  Future saveDataToFirestorefromscanner({
    required String bookid,
    required String bookname,
    required String authorname,
    required String imgcover,
    required String username,
    required String userimage,
    required String useruid,
    required String userlocation,
    required double userlat,
    required double userlong,
    required String bookdesc,
  }) async {
    final DocumentReference r = FirebaseFirestore.instance
        .collection("users")
        .doc(userglobalData!.uid)
        .collection("Books")
        .doc(bookid);

    await r.set({
      "book_id": bookid,
      "book_name": bookname,
      "author_name": authorname,
      "image_cover": imgcover,
      "username": username,
      "userimage": userimage,
      "useruid": useruid,
      "user_location": userlocation,
      "user_lat": userlat,
      "user_long": userlong,
      "isrented": false,
      "bookdesc": bookdesc,
    });

    final DocumentReference br =
        FirebaseFirestore.instance.collection("Books").doc(bookid);

    await br.set({
      "book_id": bookid,
      "book_name": bookname,
      "author_name": authorname,
      "image_cover": imgcover,
      "username": username,
      "userimage": userimage,
      "useruid": useruid,
      "user_location": userlocation,
      "user_lat": userlat,
      "user_long": userlong,
      "isrented": false,
      "bookdesc": bookdesc,
    });
  }

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
      print("Error: $e");
      return LatLng(0, 0);
    }
  }

  TextEditingController locationcontroller = TextEditingController();

  double? userlat;
  double? userlong;
  String? userlocationname;
  bool isloading = true;

  bool kisloading = true;

  Future<Map<String, dynamic>> getBookDetails(String isbn) async {
    final apiKey =
        'AIzaSyDGiEMiI9r7CMcBS1RAJgvSp6kKxKeBt2M'; // Replace with your Google Books API key
    final apiUrl =
        'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn&key=$apiKey';

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

  Future<Position> getcurrentlocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print("error" + error.toString());
    });

    return Geolocator.getCurrentPosition();
  }

  Future<String> getLocationName(double latitude, double longitude) async {
    try {
      List<geo.Placemark> placemarks =
          await geo.placemarkFromCoordinates(latitude, longitude);

      if (placemarks != null && placemarks.isNotEmpty) {
        geo.Placemark place = placemarks[0];
        String locationName =
            "${place.subLocality}, ${place.locality}, ${place.country}";

        setState(() {
          isloading = false;
        });
        return locationName;
      } else {
        return "Location not found";
      }
    } catch (e) {
      print("An error occurred: $e");
      return "Error retrieving location";
    }
  }

  Future<void> getLocation() async {
    double latitude = userlat!;
    double longitude = userlong!;

    userlocationname = await getLocationName(latitude, longitude);
    print("location details are : ${userlocationname}");

    locationcontroller.text = userlocationname!;
  }

  Future<UserData> getUserData(String uid) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentSnapshot userSnapshot =
          await firestore.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        userglobalData = UserData.fromSnapshot(userSnapshot);
        print('uid : ${userglobalData!.uid}');
        print('username: ${userglobalData!.username}');
        print('name: ${userglobalData!.name}');
        print('imageurl: ${userglobalData!.imageurl}');
        print('provider: ${userglobalData!.provider}');
        print('locationname: ${userglobalData!.locationname}');

        return userglobalData!;
      } else {
        print('User document does not exist');
        return UserData("", "", "", "", false, "", "", 0.0, 0.0);
      }
    } catch (e) {
      print('Error retrieving user data: $e');
      return UserData("", "", "", "", false, "", "", 0.0, 0.0);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration(seconds: 1), () async {
      await getcurrentlocation().then((value) async {
        print("my current loaction");
        print(value.latitude.toString() + " " + value.longitude.toString());

        userlat = value.latitude;
        userlong = value.longitude;
        await getLocation();
      });

      String? currentUserUID = await FirebaseAuth.instance.currentUser?.uid;
      await getUserData(currentUserUID!);

      setState(() {
        kisloading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();
    return Scaffold(
      body: kisloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                // color: Colors.red,
                width: screenWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 48.h,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 24.0.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your account",
                            style: TextStyle(
                                fontFamily: globalfontfamily,
                                color: Colors.black,
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        height: 102.h,
                        width: 102.w,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: Image.network(
                              userglobalData!.imageurl,
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
                    SizedBox(
                      height: 20.h,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 24.0.w),
                      child: Container(
                        // color: Colors.red,
                        height: 98.h,
                        width: 342.w,
                        child: Padding(
                          padding: EdgeInsets.only(left: 20.0.w, top: 16.h),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Name",
                                    style: TextStyle(
                                      fontFamily: globalfontfamily,
                                      color: Colors.black,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50.w,
                                  ),
                                  Text(
                                    "${userglobalData!.name}",
                                    style: TextStyle(
                                      fontFamily: globalfontfamily,
                                      color: Colors.black,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 12.h,
                              ),
                              Container(
                                height: 1,
                                color: Color.fromRGBO(198, 198, 200, 1),
                              ),
                              SizedBox(
                                height: 12.h,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "username",
                                    style: TextStyle(
                                      fontFamily: globalfontfamily,
                                      color: Colors.black,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 22.w,
                                  ),
                                  Text(
                                    "${userglobalData!.username}",
                                    style: TextStyle(
                                      fontFamily: globalfontfamily,
                                      color: Colors.black,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 24.0.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your top 3 books",
                            style: TextStyle(
                              fontFamily: globalfontfamily,
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "This helps us better match make",
                            style: TextStyle(
                              fontFamily: globalfontfamily,
                              color: Colors.black,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          SizedBox(
                            height: 12.h,
                          ),

                          Container(
                            height: 290.h,
                            width: 342.w,
                            color: Color.fromRGBO(249, 249, 249, 1),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 20.0.w,
                                right: 20.0.w,
                                // top: 16.h,
                              ),
                              child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userglobalData!.uid)
                                      .collection('Books')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }

                                    print(!snapshot.hasData);

                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                    List<Book> books = snapshot.data!.docs
                                        .map((DocumentSnapshot doc) {
                                      Map<String, dynamic> data =
                                          doc.data() as Map<String, dynamic>;
                                      return Book.fromMap(data, doc.id);
                                    }).toList();
                                    return ListView.builder(
                                        itemCount: books.length,
                                        itemBuilder: (context, index) {
                                          return AccountBookwidget(
                                            book: books[index],
                                          );
                                        });
                                  }),
                            ),
                          ),

                          SizedBox(
                            height: 24.h,
                          ),

                          TapBounceContainer(
                            child: GestureDetector(
                              onTap: () async {
                                setState(() {
                                  bookloading = true;
                                });
                                var res = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SimpleBarcodeScannerPage(),
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

                                print('Barcode Result: $result');
                                print(
                                    'Title: ${bookDetails['title'] ?? "no tittle"}');
                                print(
                                    'Author(s): ${bookDetails['authors'][0] ?? "no author name"}');
                                print(
                                    'Description: ${bookDetails['description'] ?? "no description"}');
                                print(
                                    'Image: ${bookDetails['imageLinks']['thumbnail'] ?? "no imgcovr"}');

                                String book1id = randomAlphaNumeric(9);
                                String book1name =
                                    bookDetails['title'] ?? "no tittle";
                                String book1authorname = bookDetails['authors']
                                        [0] ??
                                    "no author name";

                                String imgcover = bookDetails['imageLinks']
                                        ['thumbnail'] ??
                                    "https://firebasestorage.googleapis.com/v0/b/openbook-68460.appspot.com/o/cover.png?alt=media&token=63132f9d-b178-4a10-a38d-c59f98b55a09";

                                String bookdesc = bookDetails['description'] ??
                                    "no descriptions";

                                String userloc = locationcontroller.text;

                                LatLng locationcoordinates =
                                    await getLocationFromAddress(userloc);

                                double userlocationlat =
                                    locationcoordinates.latitude;

                                double userlocationlong =
                                    locationcoordinates.longitude;

                                await saveDataToFirestorefromscanner(
                                  bookid: book1id,
                                  bookname: book1name,
                                  authorname: book1authorname,
                                  imgcover: imgcover,
                                  username: userglobalData!.username,
                                  userimage: userglobalData!.imageurl,
                                  useruid: userglobalData!.uid,
                                  userlocation: userloc,
                                  userlat: userlocationlat,
                                  userlong: userlocationlong,
                                  bookdesc: bookdesc,
                                );

                                setState(() {
                                  bookloading = false;
                                });

                                showTopSnackBar(
                                  Overlay.of(context),
                                  CustomSnackBar.error(
                                    message: '${book1name} added Sucessfully !',
                                  ),
                                );

                                ///
                              },
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 25.0.w),
                                  child: Container(
                                    // color: Colors.red,
                                    height: 30,
                                    width: 30,
                                    child: bookloading
                                        ? CircularProgressIndicator()
                                        : Image.asset(
                                            "assets/images/scan.png",
                                            fit: BoxFit.cover,
                                            height: 30,
                                            width: 30,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 10.h,
                          ),

                          Text(
                            "Recieved Books",
                            style: TextStyle(
                              fontFamily: globalfontfamily,
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // Text(
                          //   "This helps us better match make",
                          //   style: TextStyle(
                          //     fontFamily: globalfontfamily,
                          //     color: Colors.black,
                          //     fontSize: 12.sp,
                          //     fontWeight: FontWeight.w300,
                          //   ),
                          // ),
                          SizedBox(
                            height: 12.h,
                          ),

                          Container(
                            height: 200.h,
                            width: 342.w,
                            color: Color.fromRGBO(249, 249, 249, 1),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 20.0.w,
                                right: 20.0.w,
                                // top: 16.h,
                              ),
                              child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userglobalData!.uid)
                                      .collection('RecievedBooks')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }

                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                    List<RecievedBook> books = snapshot
                                        .data!.docs
                                        .map((DocumentSnapshot doc) {
                                      Map<String, dynamic> data =
                                          doc.data() as Map<String, dynamic>;
                                      return RecievedBook.fromMap(data, doc.id);
                                    }).toList();
                                    return ListView.builder(
                                        itemCount: books.length == 1
                                            ? 1
                                            : books.length == 0
                                                ? 0
                                                : 2,
                                        itemBuilder: (context, index) {
                                          return RecievedBookwidget(
                                            book: books[index],
                                          );
                                        });
                                  }),
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              nextScreen(context, RecievedBookScreen());
                            },
                            child: Container(
                              width: 342.w,
                              color: Color.fromRGBO(249, 249, 249, 1),
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 14.0.h),
                                child: Center(
                                  child: Text(
                                    "view all",
                                    style: TextStyle(
                                      fontFamily: globalfontfamily,
                                      color: Color.fromRGBO(67, 128, 199, 1),
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 10.h,
                          ),

                          Text(
                            "Rented Books",
                            style: TextStyle(
                              fontFamily: globalfontfamily,
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // Text(
                          //   "This helps us better match make",
                          //   style: TextStyle(
                          //     fontFamily: globalfontfamily,
                          //     color: Colors.black,
                          //     fontSize: 12.sp,
                          //     fontWeight: FontWeight.w300,
                          //   ),
                          // ),
                          SizedBox(
                            height: 12.h,
                          ),

                          Container(
                            height: 290.h,
                            width: 342.w,
                            color: Color.fromRGBO(249, 249, 249, 1),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 20.0.w,
                                right: 20.0.w,
                                // top: 16.h,
                              ),
                              child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userglobalData!.uid)
                                      .collection('RentedBooks')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }

                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                    List<RentedBook> books = snapshot.data!.docs
                                        .map((DocumentSnapshot doc) {
                                      Map<String, dynamic> data =
                                          doc.data() as Map<String, dynamic>;
                                      return RentedBook.fromMap(data, doc.id);
                                    }).toList();
                                    return ListView.builder(
                                        itemCount: books.length,
                                        itemBuilder: (context, index) {
                                          return RentedBookWidget(
                                            book: books[index],
                                          );
                                        });
                                  }),
                            ),
                          ),

                          SizedBox(
                            height: 20.h,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Invite readers",
                                style: TextStyle(
                                  fontFamily: globalfontfamily,
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "This helps us better match make",
                                style: TextStyle(
                                  fontFamily: globalfontfamily,
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(
                            height: 12.h,
                          ),
                          Container(
                            // height: 143.h,
                            width: 342.w,
                            color: Color.fromRGBO(249, 249, 249, 1),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 20.0.w,
                                right: 20.0.w,
                                top: 16.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                                "assets/images/whatsapp.png"),
                                            SizedBox(
                                              width: 12.h,
                                            ),
                                            Text(
                                              "Whatsapp",
                                              style: TextStyle(
                                                fontFamily: globalfontfamily,
                                                color: Color.fromRGBO(
                                                    75, 200, 118, 1),
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Image.asset(
                                          "assets/images/frd.png",
                                          color:
                                              Color.fromRGBO(75, 200, 118, 1),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 12.h,
                                  ),
                                  Container(
                                    height: 1,
                                    color: Color.fromRGBO(198, 198, 200, 1),
                                  ),
                                  SizedBox(
                                    height: 12.h,
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset("assets/images/x.png"),
                                            SizedBox(
                                              width: 12.h,
                                            ),
                                            Text(
                                              "Twitter",
                                              style: TextStyle(
                                                fontFamily: globalfontfamily,
                                                color:
                                                    Color.fromRGBO(0, 0, 0, 1),
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Image.asset(
                                          "assets/images/frd.png",
                                          color: Color.fromRGBO(0, 0, 0, 1),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 12.h,
                                  ),
                                  Container(
                                    height: 1,
                                    color: Color.fromRGBO(198, 198, 200, 1),
                                  ),
                                  SizedBox(
                                    height: 12.h,
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                                "assets/images/inst.png"),
                                            SizedBox(
                                              width: 12.h,
                                            ),
                                            Text(
                                              "Instagram",
                                              style: TextStyle(
                                                fontFamily: globalfontfamily,
                                                color: Color.fromRGBO(
                                                    242, 68, 65, 1),
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Image.asset(
                                          "assets/images/frd.png",
                                          color: Color.fromRGBO(242, 68, 65, 1),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 12.h,
                                  ),
                                  Container(
                                    height: 1,
                                    color: Color.fromRGBO(198, 198, 200, 1),
                                  ),
                                  SizedBox(
                                    height: 16.h,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5.h,
                          ),

                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(right: 12.0.w),
                              child: ElevatedButton(
                                  onPressed: () {
                                    sp.userSignOut();
                                    nextScreenReplace(
                                        context, const OnBoradingScreen());
                                  },
                                  child: const Text("SIGNOUT",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ))),
                            ),
                          ),

                          SizedBox(
                            height: 15.h,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
