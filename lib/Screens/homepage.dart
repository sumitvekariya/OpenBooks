import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:openbook/Models/book_model.dart';
import 'package:openbook/Models/rquest_book_model.dart';
import 'package:openbook/Models/user_model.dart';
import 'package:openbook/ScreenWidgets/requestscreenwidget.dart';
import 'package:openbook/Screens/bookaroundyou.dart';
import 'package:openbook/Screens/peoplearoundyou.dart';
import 'package:openbook/Screens/youraccountscreen.dart';
import 'package:openbook/Screens/yourrequestscreen.dart';
import 'package:openbook/Widgets/widgets.dart';
import 'package:openbook/utils/global_data.dart';
import 'package:openbook/utils/globalvar.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Marker> markers = <Marker>[];
  final Completer<GoogleMapController> controller = Completer();
  late GoogleMapController mapController;
  Set<Polyline> polylines = {};

  double? userlat;
  double? userlong;
  String? userlocationname;
  bool isloading = true;

  Future<Position> getcurrentlocation() async {
    await Geolocator.requestPermission().then((value) {}).onError((error, stackTrace) {
      log("error$error");
    });

    return Geolocator.getCurrentPosition();
  }

  Future<String> getLocationName(double latitude, double longitude) async {
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(latitude, longitude);

      if (placemarks != null && placemarks.isNotEmpty) {
        geo.Placemark place = placemarks[0];
        String locationName = "${place.subLocality}, ${place.locality}, ${place.country}";

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

  BitmapDescriptor markericon = BitmapDescriptor.defaultMarker;

  Future<void> getLocation() async {
    double latitude = userlat!;
    double longitude = userlong!;

    userlocationname = await getLocationName(latitude, longitude);
    log("location details are : $userlocationname");
  }

  Future addCustomIcon() async {
    final Uint8List customMarker = await getBytesFromAsset(path: "assets/images/prsn.png", width: 50);

    setState(() {
      markericon = BitmapDescriptor.fromBytes(customMarker);
    });
  }

  Future<Uint8List> getBytesFromAsset({String? path, int? width}) async {
    ByteData data = await rootBundle.load(path!);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    try {
      Future.delayed(const Duration(microseconds: 1), () async {
        await addCustomIcon();

        await FirebaseFirestore.instance.collection('users').snapshots().listen((snapshot) {
          // markers.clear();
          for (var doc in snapshot.docs) {
            UserPeopleModel user = UserPeopleModel.fromMap(doc.data(), doc.id);

            // Add marker for each location

            log("user is : ${user.username}");
            Marker marker = Marker(
              icon: markericon,
              markerId: MarkerId(user.uid),
              position: LatLng(user.userlat, user.userlong),
              infoWindow: InfoWindow(title: user.username, snippet: user.locationname),
            );

            markers.add(marker);
          }
        });

        await getcurrentlocation().then((value) async {
          log("my current location");
          log("${value.latitude} ${value.longitude}");

          userlat = value.latitude;
          userlong = value.longitude;
          await getLocation();
          markers.add(
            Marker(icon: markericon, markerId: const MarkerId("2"), position: LatLng(value.latitude, value.longitude), infoWindow: const InfoWindow(title: "my current loaction")),
          );

          CameraPosition cameraPosition = CameraPosition(
            target: LatLng(value.latitude, value.longitude),
            zoom: 14,
          );

          final GoogleMapController cotrllr = await controller.future;

          cotrllr.animateCamera(CameraUpdate.newCameraPosition(cameraPosition)).then((value) => setState(() {}));
        });
      });
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        floatingActionButton: IconButton(
          iconSize: 50.h,
          onPressed: () {
            nextScreen(context, const YourAccountScreen());
          },
          icon: const Icon(Icons.account_circle, color: Colors.red),
        ),
        body: isloading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                height: ScreenUtil().screenHeight,
                width: ScreenUtil().screenWidth,
                color: Colors.transparent,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    SizedBox(
                      height: 270.h,
                      child: GoogleMap(
                        mapType: MapType.terrain,
                        markers: Set<Marker>.of(markers),
                        onMapCreated: (GoogleMapController controllers) {
                          controller.complete(controllers);
                          // addPolyline();
                        },
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(28.644800, 77.216721),
                          // zoom: 14.0,
                        ),
                        // polylines: polylines,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 250.h),
                      child: Container(
                        height: 600.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(32.r), topRight: Radius.circular(32.r)),
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 24.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    nextScreen(context, const PeopleAroundYouScreen());
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.h),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.grey[100]),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Browse people around you",
                                          style: TextStyle(fontFamily: globalfontfamily, fontSize: 16.sp, color: Colors.blueAccent),
                                        ),
                                        const Icon(Icons.arrow_right, color: Colors.blueAccent)
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Text(
                                  "Books around you",
                                  style: TextStyle(fontFamily: globalfontfamily, fontSize: 16.sp, fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 15.h),
                                StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance.collection('Books').snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      }

                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      List<Book> books = snapshot.data!.docs
                                          .map((DocumentSnapshot doc) {
                                            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                                            return Book.fromMap(data, doc.id);
                                          })
                                          .where((book) => !book.isrented && book.userUid != userglobalData!.uid)
                                          .toList();
                                      // books = [];
                                      if (books.isEmpty) {
                                        return buildNoBooks();
                                      } else {
                                        return Column(
                                          children: [
                                            buildBooks(books),
                                            GestureDetector(
                                              onTap: () {
                                                nextScreen(context, const BookAroundYouScreen());
                                              },
                                              child: Center(
                                                child: Text(
                                                  "view all",
                                                  style: TextStyle(fontFamily: globalfontfamily, color: Colors.blueAccent, fontSize: 12.sp, fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    }),
                                SizedBox(height: 20.h),
                                Text(
                                  "DM requests",
                                  style: TextStyle(
                                    fontFamily: globalfontfamily,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 15.h),
                                StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance.collection('users').doc(userglobalData!.uid).collection('RequestedBooks').snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      }

                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      List<RequestedBook> books = snapshot.data!.docs.map((DocumentSnapshot doc) {
                                        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                                        return RequestedBook.fromMap(data, doc.id);
                                      }).toList();
                                      if (books.isEmpty) {
                                        return buildNoBooks();
                                      } else {
                                        return Column(
                                          children: [
                                            buildBooksRequest(books),
                                            GestureDetector(
                                              onTap: () {
                                                nextScreen(context, const YourRequestScreen());
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.only(bottom: 10.0.h),
                                                child: Center(
                                                  child: Text(
                                                    "view all",
                                                    style: TextStyle(fontFamily: globalfontfamily, color: Colors.blueAccent, fontSize: 12.sp, fontWeight: FontWeight.w600),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    }),
                                SizedBox(
                                  height: 15.h,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
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
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        itemCount: books.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (BuildContext context, int index) {
          return Bookwidget(
            book: books[index],
          );
        },
      ),
    );
  }

  Container buildBooksRequest(List<RequestedBook> books) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.grey[100]),
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        itemCount: books.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (BuildContext context, int index) {
          return RequestBookwidget(
            book: books[index],
          );
        },
      ),
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

  dynamic warningNoTask(BuildContext context) {
    return PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Normal",
      message: "There is no Task For Delete!\n Try adding some and then try to delete it!",
      buttonText: "Okay",
      onTapDismiss: () {
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.warning,
    );
  }
}
