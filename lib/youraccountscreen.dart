import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:openbook/bookaroundyou.dart.dart';
import 'package:openbook/globalvar.dart';
import 'package:openbook/onboardingscreen.dart';
import 'package:openbook/recievedbookscreen.dart';
import 'package:openbook/twitterauth/Models/book_model.dart';
import 'package:openbook/twitterauth/Models/recieved_book_model.dart';
import 'package:openbook/twitterauth/Models/rented_book_model.dart';
import 'package:openbook/twitterauth/Models/user_data_models.dart';
import 'package:openbook/twitterauth/provider/sign_in_provider.dart';
import 'package:openbook/twitterauth/utils/global_data.dart';
import 'package:openbook/twitterauth/utils/next_screen.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
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

      // markers.add(
      //   Marker(
      //     markerId: MarkerId("2"),
      //     position: LatLng(widget.fromlat, widget.fromlong),
      //     infoWindow: InfoWindow(title: "My Location"),
      //   ),
      // );

      // markers.add(
      //   Marker(
      //     markerId: MarkerId("31"),
      //     position: LatLng(widget.destlat, widget.destlong),
      //     infoWindow: InfoWindow(title: "Destination"),
      //   ),
      // );
      // CameraPosition cameraPosition = CameraPosition(
      //   target: LatLng(28.644800, 77.216721),
      //   zoom: 14,
      // );

      // final GoogleMapController cotrllr = await controller.future;

      // cotrllr.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      // setState(() {});
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
                          // Container(
                          //   width: 300.w,
                          //   child: Text(
                          //     "Help us know more about your book preferences so we can let others know about your books",
                          //     style: TextStyle(
                          //         fontFamily: globalfontfamily,
                          //         color: Colors.black,
                          //         fontSize: 12.sp,
                          //         fontWeight: FontWeight.w300),
                          //   ),
                          // ),
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

                          // Container(
                          //   // height: 143.h,
                          //   width: 342.w,
                          //   color: Color.fromRGBO(249, 249, 249, 1),
                          //   child: Padding(
                          //     padding: EdgeInsets.only(
                          //       left: 20.0.w,
                          //       right: 20.0.w,
                          //       top: 16.h,
                          //     ),
                          //     child: Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         Container(
                          //           child: Row(
                          //             mainAxisAlignment:
                          //                 MainAxisAlignment.spaceBetween,
                          //             children: [
                          //               Text(
                          //                 "The Book of Mirad",
                          //                 style: TextStyle(
                          //                   fontFamily: globalfontfamily,
                          //                   color: Color.fromRGBO(0, 0, 0, 1),
                          //                   fontSize: 16.sp,
                          //                   fontWeight: FontWeight.w400,
                          //                 ),
                          //               ),
                          //               Image.asset("assets/images/scan.png")
                          //             ],
                          //           ),
                          //         ),
                          //         SizedBox(
                          //           height: 12.h,
                          //         ),
                          //         Container(
                          //           height: 1,
                          //           color: Color.fromRGBO(198, 198, 200, 1),
                          //         ),
                          //         SizedBox(
                          //           height: 12.h,
                          //         ),
                          //         Container(
                          //           child: Row(
                          //             mainAxisAlignment:
                          //                 MainAxisAlignment.spaceBetween,
                          //             children: [
                          //               Text(
                          //                 "Mans search for meaning",
                          //                 style: TextStyle(
                          //                   fontFamily: globalfontfamily,
                          //                   color: Color.fromRGBO(0, 0, 0, 1),
                          //                   fontSize: 16.sp,
                          //                   fontWeight: FontWeight.w400,
                          //                 ),
                          //               ),
                          //               Image.asset("assets/images/scan.png")
                          //             ],
                          //           ),
                          //         ),
                          //         SizedBox(
                          //           height: 12.h,
                          //         ),
                          //         Container(
                          //           height: 1,
                          //           color: Color.fromRGBO(198, 198, 200, 1),
                          //         ),
                          //         SizedBox(
                          //           height: 12.h,
                          //         ),
                          //         Container(
                          //           child: Row(
                          //             mainAxisAlignment:
                          //                 MainAxisAlignment.spaceBetween,
                          //             children: [
                          //               Text(
                          //                 "The 40 rules of love",
                          //                 style: TextStyle(
                          //                   fontFamily: globalfontfamily,
                          //                   color: Color.fromRGBO(0, 0, 0, 1),
                          //                   fontSize: 16.sp,
                          //                   fontWeight: FontWeight.w400,
                          //                 ),
                          //               ),
                          //               Image.asset("assets/images/scan.png")
                          //             ],
                          //           ),
                          //         ),
                          //         SizedBox(
                          //           height: 12.h,
                          //         ),
                          //         Container(
                          //           height: 1,
                          //           color: Color.fromRGBO(198, 198, 200, 1),
                          //         ),
                          //         SizedBox(
                          //           height: 16.h,
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
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
                          // Container(
                          //   width: 342.w,
                          //   color: Color.fromRGBO(249, 249, 249, 1),
                          //   child: Padding(
                          //     padding: EdgeInsets.only(
                          //         left: 20.0.w, right: 20.0.w, top: 16.h, bottom: 16.h),
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //       children: [
                          //         Text(
                          //           "Mumbai",
                          //           style: TextStyle(
                          //             fontFamily: globalfontfamily,
                          //             color: Color.fromRGBO(0, 0, 0, 1),
                          //             fontSize: 16.sp,
                          //             fontWeight: FontWeight.w300,
                          //           ),
                          //         ),
                          //         Image.asset("assets/images/loc.png")
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          // SizedBox(
                          //   height: 55.h,
                          // ),
                          // Container(
                          //   height: 43.h,
                          //   width: 339.w,
                          //   decoration: BoxDecoration(
                          //     color: Color.fromRGBO(85, 163, 255, 1),
                          //     borderRadius: BorderRadius.circular(22.r),
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: Colors.black.withOpacity(0.4),
                          //         spreadRadius: 0,
                          //         blurRadius: 4,
                          //         offset: Offset(0, 4),
                          //       ),
                          //     ],
                          //   ),
                          //   child: Center(
                          //       child: Row(
                          //     children: [
                          //       SizedBox(
                          //         width: 78.5.w,
                          //       ),
                          //       Text(
                          //         "Add books to your shelf",
                          //         style: TextStyle(
                          //             fontFamily: globalfontfamily,
                          //             color: Colors.white,
                          //             fontSize: 16.sp,
                          //             fontWeight: FontWeight.w600),
                          //       ),
                          //       SizedBox(
                          //         width: 46.5.w,
                          //       ),
                          //       Image.asset("assets/images/icarr.png")
                          //     ],
                          //   )),
                          // ),
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

class AccountBookwidget extends StatefulWidget {
  final Book book;
  const AccountBookwidget({
    super.key,
    required this.book,
  });

  @override
  State<AccountBookwidget> createState() => _AccountBookwidgetState();
}

class _AccountBookwidgetState extends State<AccountBookwidget> {
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            // color: Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 50.h,
                        width: 50.w,
                        child: Image.network(widget.book.imageCover)),
                    Padding(
                      padding: EdgeInsets.only(left: 12.0.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "By: ",
                                style: TextStyle(
                                  fontFamily: globalfontfamily,
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                              Container(
                                height: 8.h,
                                width: 8.w,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    backgroundImage: Image.network(
                                      widget.book.userimage,
                                      fit: BoxFit.cover,
                                    ).image,
                                    radius: 4,
                                    // child: Image.file(
                                    //   selectedImage!,
                                    //   fit: BoxFit.cover,
                                    // ),
                                  ),
                                ),
                              ),

                              SizedBox(
                                width: 2.w,
                              ),
                              // Image.asset("assets/images/playr1.png"),
                              Text(
                                "${widget.book.username}, ${widget.book.userLocation}",
                                style: TextStyle(
                                  fontFamily: globalfontfamily,
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 200.w,
                            child: Text(
                              "${widget.book.bookName}",
                              style: TextStyle(
                                fontFamily: globalfontfamily,
                                color: Color.fromRGBO(0, 0, 0, 1),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Text(
                            "Author: ${widget.book.authorName}",
                            style: TextStyle(
                              fontFamily: globalfontfamily,
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                          // SizedBox(
                          //   height: 12.h,
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 1,
                  color: Color.fromRGBO(198, 198, 200, 1),
                ),
                SizedBox(
                  height: 12.h,
                ),
                TapBounceContainer(
                  child: GestureDetector(
                    onTap: () async {
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.error(
                          message:
                              '${widget.book.bookName} deleted Sucessfully !',
                        ),
                      );
                      setState(() {
                        isloading = true;
                      });

                      final DocumentReference dl = FirebaseFirestore.instance
                          .collection("users")
                          .doc(widget.book.userUid)
                          .collection("Books")
                          .doc(widget.book.bookId);

                      await dl.delete();

                      final DocumentReference del = FirebaseFirestore.instance
                          .collection("Books")
                          .doc(widget.book.bookId);

                      await del.delete();

                      // await saveDataToFirestore(
                      //   bookid: widget.book.bookId,
                      //   bookname: widget.book.bookName,
                      //   authorname: widget.book.authorName,
                      //   imgcover: widget.book.imageCover,
                      //   username: widget.book.username,
                      //   userimage: widget.book.userimage,
                      //   useruid: widget.book.userUid,
                      //   userlocation: widget.book.userLocation,
                      //   userlat: widget.book.userLat,
                      //   userlong: widget.book.userLong,
                      //   requestusername: userglobalData!.username,
                      //   requestuserimage: userglobalData!.imageurl,
                      //   requestuseruid: userglobalData!.uid,
                      //   requestuserlocation: userglobalData!.locationname,
                      //   requestuserlat: userglobalData!.userlat,
                      //   requestuserlong: userglobalData!.userlong,
                      // );

                      setState(() {
                        isloading = false;
                      });
                      // warningNoTask(context);
                    },
                    child: isloading
                        ? Container(
                            height: 19.h,
                            width: 19.w,
                            child: CircularProgressIndicator(),
                          )
                        : Container(
                            height: 24.h,
                            width: 24.w,
                            child: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                  ),
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
        ],
      ),
    );
  }

  Future warningNoTask(BuildContext context) async {
    return PanaraInfoDialog.showAnimatedGrow(
      noImage: true,
      context,
      title: "Normal",
      message:
          "There is no Task For Delete!\n Try adding some and then try to delete it!",
      buttonText: "Okay",
      onTapDismiss: () async {
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.success,
    );
  }

  // Future saveDataToFirestore(
  //     {required String bookid,
  //     required String bookname,
  //     required String authorname,
  //     required String imgcover,
  //     required String username,
  //     required String userimage,
  //     required String useruid,
  //     required String userlocation,
  //     required double userlat,
  //     required double userlong,
  //     required String requestusername,
  //     required String requestuserimage,
  //     required String requestuseruid,
  //     required String requestuserlocation,
  //     required double requestuserlat,
  //     required double requestuserlong,
  //     re}) async {
  //   final DocumentReference r = FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(useruid)
  //       .collection("RequestedBooks")
  //       .doc(bookid);

  //   await r.set({
  //     "book_id": bookid,
  //     "book_name": bookname,
  //     "author_name": authorname,
  //     "image_cover": imgcover,
  //     "username": username,
  //     "userimage": userimage,
  //     "useruid": useruid,
  //     "user_location": userlocation,
  //     "user_lat": userlat,
  //     "user_long": userlong,
  //     "requestusername": requestusername,
  //     "requestuserimage": requestuserimage,
  //     "requestuseruid": requestuseruid,
  //     "requestuserlocation": requestuserlocation,
  //     "requestuserlat": requestuserlat,
  //     "requestuserlong": requestuserlong,
  //   });

  //   //  final DocumentReference br = FirebaseFirestore.instance
  //   //     .collection("users")
  //   //     .doc(requestuseruid)
  //   //     .collection("RequestBooks")
  //   //     .doc(bookid);

  //   // await br.set({
  //   //   "book_id": bookid,
  //   //   "book_name": bookname,
  //   //   "author_name": authorname,
  //   //   "image_cover": imgcover,
  //   //   "username": username,
  //   //   "userimage": userimage,
  //   //   "useruid": useruid,
  //   //   "user_location": userlocation,
  //   //   "user_lat": userlat,
  //   //   "user_long": userlong,
  //   // });
  // }
}

class RecievedBookwidget extends StatefulWidget {
  final RecievedBook book;
  const RecievedBookwidget({
    super.key,
    required this.book,
  });

  @override
  State<RecievedBookwidget> createState() => _RecievedBookwidgetState();
}

class _RecievedBookwidgetState extends State<RecievedBookwidget> {
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            // color: Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 50.h,
                        width: 50.w,
                        child: Image.network(widget.book.imageCover)),
                    Padding(
                      padding: EdgeInsets.only(left: 12.0.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Borrow from: ",
                                style: TextStyle(
                                  fontFamily: globalfontfamily,
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                              Container(
                                height: 8.h,
                                width: 8.w,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    backgroundImage: Image.network(
                                      widget.book.userimage,
                                      fit: BoxFit.cover,
                                    ).image,
                                    radius: 4,
                                    // child: Image.file(
                                    //   selectedImage!,
                                    //   fit: BoxFit.cover,
                                    // ),
                                  ),
                                ),
                              ),

                              SizedBox(
                                width: 2.w,
                              ),
                              // Image.asset("assets/images/playr1.png"),
                              Text(
                                "${widget.book.username}, ${widget.book.userLocation}",
                                style: TextStyle(
                                  fontFamily: globalfontfamily,
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 200.w,
                            child: Text(
                              "${widget.book.bookName}",
                              style: TextStyle(
                                fontFamily: globalfontfamily,
                                color: Color.fromRGBO(0, 0, 0, 1),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Text(
                            "Author: ${widget.book.authorName}",
                            style: TextStyle(
                              fontFamily: globalfontfamily,
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                          // SizedBox(
                          //   height: 12.h,
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 1,
                  color: Color.fromRGBO(198, 198, 200, 1),
                ),
                SizedBox(
                  height: 12.h,
                ),
                // GestureDetector(
                //   onTap: () async {
                //     setState(() {
                //       isloading = true;
                //     });

                //     // await saveDataToFirestore(
                //     //   bookid: widget.book.bookId,
                //     //   bookname: widget.book.bookName,
                //     //   authorname: widget.book.authorName,
                //     //   imgcover: widget.book.imageCover,
                //     //   username: widget.book.username,
                //     //   userimage: widget.book.userimage,
                //     //   useruid: widget.book.userUid,
                //     //   userlocation: widget.book.userLocation,
                //     //   userlat: widget.book.userLat,
                //     //   userlong: widget.book.userLong,
                //     //   rentedusername: widget.book.requestusername,
                //     //   renteduserimage: widget.book.requestuserimage,
                //     //   renteduseruid: widget.book.requestuseruid,
                //     //   renteduserlocation: widget.book.requestuserlocation,
                //     //   rentedtuserlat: widget.book.requestuserlat,
                //     //   renteduserlong: widget.book.requestuserlong,
                //     // );

                //     setState(() {
                //       isloading = false;
                //     });
                //     // warningNoTask(context);
                //   },
                //   child: isloading
                //       ? Container(
                //           height: 19.h,
                //           width: 19.w,
                //           child: CircularProgressIndicator(),
                //         )
                //       : Container(
                //           height: 24.h,
                //           width: 24.w,
                //           child: Image.asset("assets/images/nextarr.png"),
                //         ),
                // )
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
        ],
      ),
    );
  }
}

class RentedBookWidget extends StatefulWidget {
  final RentedBook book;
  const RentedBookWidget({
    super.key,
    required this.book,
  });

  @override
  State<RentedBookWidget> createState() => _RentedBookWidgetState();
}

class _RentedBookWidgetState extends State<RentedBookWidget> {
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            // color: Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 50.h,
                        width: 50.w,
                        child: Image.network(widget.book.imageCover)),
                    Padding(
                      padding: EdgeInsets.only(left: 12.0.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "rented to: ",
                                style: TextStyle(
                                  fontFamily: globalfontfamily,
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                              Container(
                                height: 8.h,
                                width: 8.w,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    backgroundImage: Image.network(
                                      widget.book.renteduserimage,
                                      fit: BoxFit.cover,
                                    ).image,
                                    radius: 4,
                                    // child: Image.file(
                                    //   selectedImage!,
                                    //   fit: BoxFit.cover,
                                    // ),
                                  ),
                                ),
                              ),

                              SizedBox(
                                width: 2.w,
                              ),
                              // Image.asset("assets/images/playr1.png"),
                              Text(
                                "${widget.book.rentedusername}, ${widget.book.renteduserlocation}",
                                style: TextStyle(
                                  fontFamily: globalfontfamily,
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 200.w,
                            child: Text(
                              "${widget.book.bookName}",
                              style: TextStyle(
                                fontFamily: globalfontfamily,
                                color: Color.fromRGBO(0, 0, 0, 1),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Text(
                            "Author: ${widget.book.authorName}",
                            style: TextStyle(
                              fontFamily: globalfontfamily,
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                          // SizedBox(
                          //   height: 12.h,
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 1,
                  color: Color.fromRGBO(198, 198, 200, 1),
                ),
                SizedBox(
                  height: 12.h,
                ),
                TapBounceContainer(
                  child: GestureDetector(
                    onTap: () async {
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.error(
                          message:
                              '${widget.book.bookName} sucessfully withdrawn from ${widget.book.rentedusername} to My Book Shelf',
                        ),
                      );
                      setState(() {
                        isloading = true;
                      });

                      await saveDataToFirestore(
                          bookid: widget.book.bookId,
                          bookname: widget.book.bookName,
                          authorname: widget.book.authorName,
                          imgcover: widget.book.imageCover,
                          username: widget.book.username,
                          userimage: widget.book.userimage,
                          useruid: widget.book.userUid,
                          userlocation: widget.book.userLocation,
                          userlat: widget.book.userLat,
                          userlong: widget.book.userLong,
                          rentedusername: widget.book.rentedusername,
                          renteduserimage: widget.book.renteduserimage,
                          renteduseruid: widget.book.renteduseruid,
                          renteduserlocation: widget.book.renteduserlocation,
                          renteduserlat: widget.book.renteduserlat,
                          renteduserlong: widget.book.renteduserlong,
                          bookdesc: widget.book.bookdesc);

                      setState(() {
                        isloading = false;
                      });

                      // warningNoTask(context);
                    },
                    child: isloading
                        ? Container(
                            height: 19.h,
                            width: 19.w,
                            child: CircularProgressIndicator(),
                          )
                        : Container(
                            height: 24.h,
                            width: 24.w,
                            child: Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            )
                            // child: Image.asset("assets/images/nextarr.png"),
                            ),
                  ),
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
        ],
      ),
    );
  }

  Future warningNoTask(BuildContext context) async {
    return PanaraInfoDialog.showAnimatedGrow(
      noImage: true,
      context,
      title: "Normal",
      message:
          "There is no Task For Delete!\n Try adding some and then try to delete it!",
      buttonText: "Okay",
      onTapDismiss: () async {
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.success,
    );
  }

  Future saveDataToFirestore({
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
    required String rentedusername,
    required String renteduserimage,
    required String renteduseruid,
    required String renteduserlocation,
    required double renteduserlat,
    required double renteduserlong,
    required String bookdesc,
  }) async {
    final DocumentReference r = FirebaseFirestore.instance
        .collection("users")
        .doc(useruid)
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

    await FirebaseFirestore.instance
        .collection("Books")
        .doc(widget.book.bookId)
        .update({
      "isrented": false,
    });

    final DocumentReference dl = FirebaseFirestore.instance
        .collection("users")
        .doc(useruid)
        .collection("RentedBooks")
        .doc(bookid);

    await dl.delete();

    final DocumentReference del = FirebaseFirestore.instance
        .collection("users")
        .doc(renteduseruid)
        .collection("RecievedBooks")
        .doc(bookid);

    await del.delete();

    //  final DocumentReference br = FirebaseFirestore.instance
    //     .collection("users")
    //     .doc(requestuseruid)
    //     .collection("RequestBooks")
    //     .doc(bookid);

    // await br.set({
    //   "book_id": bookid,
    //   "book_name": bookname,
    //   "author_name": authorname,
    //   "image_cover": imgcover,
    //   "username": username,
    //   "userimage": userimage,
    //   "useruid": useruid,
    //   "user_location": userlocation,
    //   "user_lat": userlat,
    //   "user_long": userlong,
    // });
  }
}
