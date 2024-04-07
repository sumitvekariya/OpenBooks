import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:openbook/Models/book_model.dart';
import 'package:openbook/Models/recieved_book_model.dart';
import 'package:openbook/Models/rented_book_model.dart';
import 'package:openbook/Models/user_data_models.dart';
import 'package:openbook/ScreenWidgets/accountbookwidget.dart';
import 'package:openbook/ScreenWidgets/recievedbookwidget.dart';
import 'package:openbook/ScreenWidgets/rentedbookwidget.dart';
import 'package:openbook/Screens/onboardingscreen.dart';
import 'package:openbook/Screens/recievedbookscreen.dart';
import 'package:openbook/TwitterAuth/provider/sign_in_provider.dart';
import 'package:openbook/Widgets/widgets.dart' as SnackBar;
import 'package:openbook/constants.dart';
import 'package:openbook/utils/global_data.dart';
import 'package:openbook/utils/globalvar.dart';
import 'package:openbook/utils/next_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_barcode_scanner/enum.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/api_client.dart';

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
    const apiKey =
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
      log("error" + error.toString());
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
      log("An error occurred: $e");
      return "Error retrieving location";
    }
  }

  Future<void> getLocation() async {
    double latitude = userlat!;
    double longitude = userlong!;

    userlocationname = await getLocationName(latitude, longitude);
    log("location details are : ${userlocationname}");

    locationcontroller.text = userlocationname!;
  }

  String? token;
  String? name;
  String? walletAddress;
  String? username;
  String? imageUrl;

  fetchToken() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    setState(() {
      token = s.getString('token');
      name = s.getString('name');
      walletAddress = s.getString('wallet_address');
      username = s.getString('username');
      imageUrl = s.getString('image_url');
    });
  }

  Future<UserData> getUserData(String uid) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentSnapshot userSnapshot =
          await firestore.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        userglobalData = UserData.fromSnapshot(userSnapshot);
        log('uid : ${userglobalData!.uid}');
        log('username: ${userglobalData!.username}');
        log('name: ${userglobalData!.name}');
        log('imageurl: ${userglobalData!.imageurl}');
        log('provider: ${userglobalData!.provider}');
        log('locationname: ${userglobalData!.locationname}');

        return userglobalData!;
      } else {
        log('User document does not exist');
        return UserData("", "", "", "", false, "", "", 0.0, 0.0);
      }
    } catch (e) {
      log('Error retrieving user data: $e');
      return UserData("", "", "", "", false, "", "", 0.0, 0.0);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchToken();

    Future.delayed(const Duration(seconds: 1), () async {
      await getcurrentlocation().then((value) async {
        log("my current location");
        log("${value.latitude} ${value.longitude}");

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
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 60.h),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back_ios),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            style: const ButtonStyle(
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap),
                          ),
                          SizedBox(width: 80.w),
                          Text(
                            "Your account",
                            style: TextStyle(
                                fontFamily: globalfontfamily,
                                color: Colors.black,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w600),
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
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (userglobalData!.username.isNotEmpty ?? false)
                            GestureDetector(
                              onTap: () async {
                                try {
                                  if (!await launchUrl(Uri.parse(
                                      "https://twitter.com/${username}" ??
                                          ""))) {
                                    throw Exception(
                                        'Could not launch of twitter ${username}');
                                  }
                                } catch (e) {
                                  // Handle any exception
                                  print('Error: $e');
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2.0,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    "assets/images/twitter.png",
                                    height: 20.h,
                                    width: 20.w,
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(width: 10.w),
                          if (walletAddress?.isNotEmpty ?? false)
                            GestureDetector(
                              onTap: () async {
                                try {
                                  if (!await launchUrl(Uri.parse(
                                      "https://translator.shyft.to/address/${walletAddress}?cluster=devnet" ??
                                          ""))) {
                                    throw Exception(
                                        'Could not launch ${walletAddress} this wallet');
                                  }
                                } catch (e) {
                                  // Handle any exception
                                  print('Error: $e');
                                }
                              },
                              child: Image.asset("assets/images/solana.png",
                                  height: 27.h, width: 27.w),
                            ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey[100]),
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 12.h),
                        child: Row(
                          children: [
                            Text(
                              "Name",
                              style: TextStyle(
                                  fontFamily: globalfontfamily,
                                  color: Colors.black,
                                  fontSize: 16.sp),
                            ),
                            SizedBox(width: 45.w),
                            Expanded(
                              child: Text(
                                userglobalData!.name,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyle(
                                    fontFamily: globalfontfamily,
                                    color: Colors.black,
                                    fontSize: 16.sp),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Your top 3 books",
                        style: TextStyle(
                            fontFamily: globalfontfamily,
                            color: Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "This helps us better match make",
                        style: TextStyle(
                            fontFamily: globalfontfamily,
                            color: Colors.black,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w300),
                      ),
                      SizedBox(height: 12.h),
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(userglobalData!.uid)
                              .collection('Books')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            List<Book> books =
                                snapshot.data!.docs.map((DocumentSnapshot doc) {
                              Map<String, dynamic> data =
                                  doc.data() as Map<String, dynamic>;
                              return Book.fromMap(data, doc.id);
                            }).toList();
                            if (books.isEmpty) {
                              return buildNoBooks(
                                  'Please add top 3 books read and owned by you');
                            } else {
                              return buildBooks(books);
                            }
                          }),
                      SizedBox(height: 30.h),
                      TapBounceContainer(
                        child: GestureDetector(
                          onTap: () async {
                            var res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SimpleBarcodeScannerPage(
                                          scanType: ScanType.barcode),
                                ));

                            if (res != '-1') {
                              setState(() {
                                bookloading = true;
                              });
                              await getBookDetails(res).then((details) {
                                setState(() {
                                  bookDetails = details;
                                });
                              }).catchError((e) {
                                setState(() {
                                  bookloading = false;
                                });

                                SnackBar.showSnackbar(
                                    context, Colors.red, 'Book not Found');

                                // showTopSnackBar(
                                //   Overlay.of(context),
                                //   const CustomSnackBar.error(
                                //     message: 'Book not Found',
                                //   ),
                                // );
                              });
                              try {
                                log('Barcode Result: $res');
                                log('Title: ${bookDetails['title'] ?? "no tittle"}');
                                log('Author(s): ${bookDetails['authors'][0] ?? "no author name"}');
                                log('Description: ${bookDetails['description'] ?? "no description"}');
                                log('Image: ${bookDetails['imageLinks']['thumbnail'] ?? "no imgcovr"}');

                                String bookid = res;
                                String bookname =
                                    bookDetails['title'] ?? "no tittle";
                                String bookauthorname = bookDetails['authors']
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
                                  bookid: bookid,
                                  bookname: bookname,
                                  authorname: bookauthorname,
                                  imgcover: imgcover,
                                  username: userglobalData!.username,
                                  userimage: userglobalData!.imageurl,
                                  useruid: userglobalData!.uid,
                                  userlocation: userloc,
                                  userlat: userlocationlat,
                                  userlong: userlocationlong,
                                  bookdesc: bookdesc,
                                );
                                final SharedPreferences s =
                                    await SharedPreferences.getInstance();
                                final token = s.getString('token');

                                Map<String, dynamic> mintBooksData = {
                                  'name': name,
                                  'longitude': userlocationlong.toString(),
                                  'latitude': userlocationlat.toString(),
                                  'profilePicture': imageUrl,
                                  'books': [
                                    {
                                      "isbn": res.toString(),
                                      "title": bookname,
                                      "author": bookauthorname,
                                      "description": bookdesc,
                                      "imageUrl": imgcover
                                    }
                                  ]
                                };
                                log("ssssssssssssssssssssssssssssssss $mintBooksData");
                                Response response = await ApiClient()
                                    .mintBooks(mintBooksData, token);
                                final data = response.data;
                                if (data.containsKey('data')) {
                                  Map<String, dynamic> loginData = data['data'];
                                  log("Your profile's data: $loginData");
                                }
                                setState(() {
                                  bookloading = false;
                                });

                                SnackBar.showSnackbar(context, Colors.blue,
                                    '$bookname added Successfully !');

                                // showTopSnackBar(
                                //   Overlay.of(context),
                                //   CustomSnackBar.success(
                                //     message:
                                //         '$book1name added Successfully !',
                                //   ),
                                // );

                                ///
                              } catch (e) {
                                setState(() {
                                  bookloading = false;
                                });

                                SnackBar.showSnackbar(context, Colors.red,
                                    'An error occurred while processing the book details');

                                // showTopSnackBar(
                                //   Overlay.of(context),
                                //   const CustomSnackBar.error(
                                //     message:
                                //         'An error occurred while processing the book details',
                                //   ),
                                // );
                              }
                            }
                          },
                          child: Center(
                            child: bookloading
                                ? const CircularProgressIndicator()
                                : Image.asset(
                                    "assets/images/barcode-scanner.png",
                                    fit: BoxFit.cover,
                                    height: 30,
                                    width: 30,
                                  ),
                          ),
                        ),
                      ),
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
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            List<RecievedBook> books =
                                snapshot.data!.docs.map((DocumentSnapshot doc) {
                              Map<String, dynamic> data =
                                  doc.data() as Map<String, dynamic>;
                              return RecievedBook.fromMap(data, doc.id);
                            }).toList();

                            if (books.isEmpty) {
                              return buildNoBooks('');
                            } else {
                              return Column(
                                children: [
                                  buildBooksReceived(books),
                                  GestureDetector(
                                    onTap: () {
                                      nextScreen(
                                          context, const RecievedBookScreen());
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: 14.0.h),
                                      child: Center(
                                        child: Text(
                                          "view all",
                                          style: TextStyle(
                                            fontFamily: globalfontfamily,
                                            color: Colors.blueAccent,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                          }),
                      SizedBox(height: 20.h),
                      Text(
                        "Rented Books",
                        style: TextStyle(
                            fontFamily: globalfontfamily,
                            color: Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 10.h),
                      StreamBuilder<QuerySnapshot>(
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
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            List<RentedBook> books =
                                snapshot.data!.docs.map((DocumentSnapshot doc) {
                              Map<String, dynamic> data =
                                  doc.data() as Map<String, dynamic>;
                              return RentedBook.fromMap(data, doc.id);
                            }).toList();
                            if (books.isEmpty) {
                              return buildNoBooks('No books rented');
                            } else {
                              return buildBooksRented(books);
                            }
                          }),
                      SizedBox(height: 20.h),
                      Text(
                        "Invite readers",
                        style: TextStyle(
                            fontFamily: globalfontfamily,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            onPressed: () {
                              launchUrl(Uri.parse(twitterURL));
                            },
                            icon: Image.asset("assets/images/twitter.png",
                                height: 30.h, width: 30.w),
                          ),
                          IconButton(
                            onPressed: () {
                              launchUrl(Uri.parse(telegramURL));
                            },
                            icon: Image.asset("assets/images/telegram.png",
                                height: 30.h, width: 30.w),
                          ),
                          // IconButton(
                          //   onPressed: () {},
                          //   icon: Image.asset("assets/images/web.png",
                          //       height: 30.h, width: 30.w),
                          // ),
                        ],
                      ),
                      SizedBox(height: 20.h)
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0.h, 24.h, 25.h),
          child: ElevatedButton(
            onPressed: () {
              sp.userSignOut();
              nextScreenReplace(context, const OnBoardingScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              "SIGN OUT",
              style: TextStyle(
                  fontFamily: globalfontfamily,
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ));
  }

  Container buildBooks(List<Book> books) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), color: Colors.grey[100]),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 20.h),
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
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), color: Colors.grey[100]),
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
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), color: Colors.grey[100]),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        itemCount: books.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (BuildContext context, int index) {
          return RentedBookWidget(
            book: books[index],
          );
        },
      ),
    );
  }

  Container buildNoBooks(String? msg) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), color: Colors.grey[100]),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Center(
        child: Text(
          msg ?? "No books available",
          style: TextStyle(
              // fontWeight: FontWeight.bold,
              fontFamily: globalfontfamily,
              fontSize: 13.sp),
        ),
      ),
    );
  }
}
