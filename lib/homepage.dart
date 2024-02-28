import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:openbook/bookaroundyou.dart.dart';
import 'package:openbook/globalvar.dart';
import 'package:openbook/peoplearoundyou.dart';
import 'package:openbook/twitterauth/Models/book_model.dart';
import 'package:openbook/twitterauth/Models/rquest_book_model.dart';
import 'package:openbook/twitterauth/Models/user_model.dart';
import 'package:openbook/twitterauth/utils/global_data.dart';
import 'package:openbook/widgets.dart';
import 'package:openbook/youraccountscreen.dart';
import 'package:openbook/yourrequestscreen.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'dart:typed_data';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Marker> markers = <Marker>[
    // Marker(
    //     markerId: MarkerId("1"),
    //     position: LatLng(28.669155, 77.453758),
    //     infoWindow: InfoWindow(title: "Hello")),
    // Marker(
    //     markerId: MarkerId("1"),
    //     position: LatLng(28.669155, 77.453758),
    //     infoWindow: InfoWindow(title: "Hello")),
  ];
  final Completer<GoogleMapController> controller = Completer();
  late GoogleMapController mapController;
  Set<Polyline> polylines = {};

  double? userlat;
  double? userlong;
  String? userlocationname;
  bool isloading = true;

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

  BitmapDescriptor markericon = BitmapDescriptor.defaultMarker;

  Future<void> getLocation() async {
    double latitude = userlat!;
    double longitude = userlong!;

    userlocationname = await getLocationName(latitude, longitude);
    print("location details are : ${userlocationname}");
  }

  Future addCustomIcon() async {
    // BitmapDescriptor.fromAssetImage(
    //         ImageConfiguration(size: Size(10, 10)), "assets/images/car2.png")
    //     .then((icon) {
    //   setState(() {
    //     markericon = icon;
    //   });
    // });
    final Uint8List customMarker = await getBytesFromAsset(
        path: "assets/images/prsn.png", //paste the custom image path
        width: 50 // size of custom image as marker
        );

    setState(() {
      markericon = BitmapDescriptor.fromBytes(customMarker);
    });
  }

  Future<Uint8List> getBytesFromAsset({String? path, int? width}) async {
    ByteData data = await rootBundle.load(path!);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration(microseconds: 1), () async {
      await addCustomIcon();

      await FirebaseFirestore.instance
          .collection('users')
          .snapshots()
          .listen((snapshot) {
        // markers.clear();
        snapshot.docs.forEach((doc) {
          UserPeopleModel user = UserPeopleModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id);

          // Add marker for each location

          print("user is : ${user.username}");
          Marker marker = Marker(
            icon: markericon,
            markerId: MarkerId(user.uid),
            position: LatLng(user.userlat, user.userlong),
            infoWindow:
                InfoWindow(title: user.username, snippet: user.locationname),
          );

          markers.add(marker);
        });

        // Update the map with new markers
        // mapController.clearMarkers();
      });

      await getcurrentlocation().then((value) async {
        print("my current loaction");
        print(value.latitude.toString() + " " + value.longitude.toString());

        userlat = value.latitude;
        userlong = value.longitude;
        await getLocation();
        markers.add(
          Marker(
              icon: markericon,
              markerId: MarkerId("2"),
              position: LatLng(value.latitude, value.longitude),
              infoWindow: InfoWindow(title: "my current loaction")),
        );

        CameraPosition cameraPosition = CameraPosition(
          target: LatLng(value.latitude, value.longitude),
          zoom: 14,
        );

        final GoogleMapController cotrllr = await controller.future;

        cotrllr.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        setState(() {});
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
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: isloading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                height: screenHeight,
                width: screenWidth,
                color: Colors.transparent,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      width: screenWidth,
                      height: 270.h,
                      child: GoogleMap(
                        mapType: MapType.terrain,
                        markers: Set<Marker>.of(markers),
                        onMapCreated: (GoogleMapController controllers) {
                          controller.complete(controllers);
                          // addPolyline();
                        },
                        initialCameraPosition: CameraPosition(
                          target: LatLng(28.644800, 77.216721),
                          // zoom: 14.0,
                        ),
                        polylines: polylines,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 250.0.h),
                      child: Container(
                        height: screenHeight! * 0.65,
                        width: 390.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32.r),
                              topRight: Radius.circular(32.r)),
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 24.0,
                              right: 24,
                              top: 24,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 53.h,
                                  width: 342.w,
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(249, 249, 249, 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12.r)),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 20.0.w, right: 20.0.w),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "@${userglobalData!.username}",
                                          style: TextStyle(
                                            fontFamily: globalfontfamily,
                                            color: Color.fromRGBO(0, 0, 0, 1),
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            nextScreen(
                                                context, YourAccountScreen());
                                          },
                                          child: Container(
                                            height: 24.h,
                                            width: 24.w,
                                            child: Image.asset(
                                                "assets/images/nextarr.png"),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Browse people around you",
                                      style: TextStyle(
                                        fontFamily: globalfontfamily,
                                        color: Color.fromRGBO(85, 163, 255, 1),
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        nextScreen(
                                            context, PeopleAroundYouScreen());
                                      },
                                      child: Container(
                                          height: 24.h,
                                          width: 24.w,
                                          child: Image.asset(
                                              "assets/images/frd.png")),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                Text(
                                  "Books around you",
                                  style: TextStyle(
                                    fontFamily: globalfontfamily,
                                    color: Color.fromRGBO(0, 0, 0, 1),
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                Container(
                                  height: 180.h,
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
                                            .collection('Books')
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          }

                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                          List<Book> books = snapshot.data!.docs
                                              .map((DocumentSnapshot doc) {
                                            Map<String, dynamic> data = doc
                                                .data() as Map<String, dynamic>;
                                            return Book.fromMap(data, doc.id);
                                          }).toList();
                                          return ListView.builder(
                                              itemCount: books.length,
                                              // itemCount: books.length == 1
                                              //     ? 1
                                              //     : books.length == 0
                                              //         ? 0
                                              //         : 2,
                                              itemBuilder: (context, index) {
                                                return Bookwidget(
                                                  book: books[index],
                                                );
                                              });
                                        }),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    nextScreen(context, BookAroundYouScreen());
                                  },
                                  child: Container(
                                    color: Color.fromRGBO(249, 249, 249, 1),
                                    width: screenWidth,
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: 10.0.h),
                                      child: Center(
                                        child: Text(
                                          "view all",
                                          style: TextStyle(
                                            fontFamily: globalfontfamily,
                                            color:
                                                Color.fromRGBO(67, 128, 199, 1),
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                Text(
                                  "Your Requests",
                                  style: TextStyle(
                                    fontFamily: globalfontfamily,
                                    color: Color.fromRGBO(0, 0, 0, 1),
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
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
                                            .collection('RequestedBooks')
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          }

                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                          List<RequestedBook> books = snapshot
                                              .data!.docs
                                              .map((DocumentSnapshot doc) {
                                            Map<String, dynamic> data = doc
                                                .data() as Map<String, dynamic>;
                                            return RequestedBook.fromMap(
                                                data, doc.id);
                                          }).toList();
                                          return ListView.builder(
                                              itemCount: books.length == 1
                                                  ? 1
                                                  : books.length == 0
                                                      ? 0
                                                      : 2,
                                              itemBuilder: (context, index) {
                                                return RequestBookwidget(
                                                  book: books[index],
                                                );
                                              });
                                        }),
                                  ),
                                ),
                                Container(
                                  // height: 143.h,
                                  width: 342.w,
                                  color: Color.fromRGBO(249, 249, 249, 1),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: 20.0.w,
                                      right: 20.0.w,
                                      top: 1.h,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Container(
                                        //   // color: Colors.red,
                                        //   child: Row(
                                        //     mainAxisAlignment:
                                        //         MainAxisAlignment.spaceBetween,
                                        //     children: [
                                        //       Row(
                                        //         mainAxisAlignment:
                                        //             MainAxisAlignment.start,
                                        //         crossAxisAlignment:
                                        //             CrossAxisAlignment.start,
                                        //         children: [
                                        //           Padding(
                                        //             padding:
                                        //                 EdgeInsets.only(left: 12.0.w),
                                        //             child: Column(
                                        //               mainAxisAlignment:
                                        //                   MainAxisAlignment.start,
                                        //               crossAxisAlignment:
                                        //                   CrossAxisAlignment.start,
                                        //               children: [
                                        //                 Row(
                                        //                   children: [
                                        //                     Text(
                                        //                       "By: ",
                                        //                       style: TextStyle(
                                        //                         fontFamily:
                                        //                             globalfontfamily,
                                        //                         color: Color.fromRGBO(
                                        //                             0, 0, 0, 1),
                                        //                         fontSize: 8.sp,
                                        //                         fontWeight:
                                        //                             FontWeight.w200,
                                        //                       ),
                                        //                     ),
                                        //                     Image.asset(
                                        //                         "assets/images/playr1.png"),
                                        //                     Text(
                                        //                       "praj.eth, 350mts away",
                                        //                       style: TextStyle(
                                        //                         fontFamily:
                                        //                             globalfontfamily,
                                        //                         color: Color.fromRGBO(
                                        //                             0, 0, 0, 1),
                                        //                         fontSize: 8.sp,
                                        //                         fontWeight:
                                        //                             FontWeight.w200,
                                        //                       ),
                                        //                     ),
                                        //                   ],
                                        //                 ),
                                        //                 Text(
                                        //                   "The Book of Mirad",
                                        //                   style: TextStyle(
                                        //                     fontFamily: globalfontfamily,
                                        //                     color: Color.fromRGBO(
                                        //                         0, 0, 0, 1),
                                        //                     fontSize: 16.sp,
                                        //                     fontWeight: FontWeight.w400,
                                        //                   ),
                                        //                 ),
                                        //                 // Text(
                                        //                 //   "Author: Mikhail Naimy",
                                        //                 //   style: TextStyle(
                                        //                 //     fontFamily: globalfontfamily,
                                        //                 //     color:
                                        //                 //         Color.fromRGBO(0, 0, 0, 1),
                                        //                 //     fontSize: 16.sp,
                                        //                 //     fontWeight: FontWeight.w200,
                                        //                 //   ),
                                        //                 // ),
                                        //                 // SizedBox(
                                        //                 //   height: 12.h,
                                        //                 // ),
                                        //               ],
                                        //             ),
                                        //           ),
                                        //         ],
                                        //       ),
                                        //       Container(
                                        //         height: 1,
                                        //         color: Color.fromRGBO(198, 198, 200, 1),
                                        //       ),
                                        //       SizedBox(
                                        //         height: 12.h,
                                        //       ),
                                        //       Image.asset("assets/images/nextarr.png")
                                        //     ],
                                        //   ),
                                        // ),
                                        // SizedBox(
                                        //   height: 12.h,
                                        // ),
                                        // Container(
                                        //   height: 1,
                                        //   color: Color.fromRGBO(198, 198, 200, 1),
                                        // ),
                                        // SizedBox(
                                        //   height: 12.h,
                                        // ),
                                        // Container(
                                        //   // color: Colors.red,
                                        //   child: Row(
                                        //     mainAxisAlignment:
                                        //         MainAxisAlignment.spaceBetween,
                                        //     children: [
                                        //       Row(
                                        //         mainAxisAlignment:
                                        //             MainAxisAlignment.start,
                                        //         crossAxisAlignment:
                                        //             CrossAxisAlignment.start,
                                        //         children: [
                                        //           Padding(
                                        //             padding:
                                        //                 EdgeInsets.only(left: 12.0.w),
                                        //             child: Column(
                                        //               mainAxisAlignment:
                                        //                   MainAxisAlignment.start,
                                        //               crossAxisAlignment:
                                        //                   CrossAxisAlignment.start,
                                        //               children: [
                                        //                 Row(
                                        //                   children: [
                                        //                     Text(
                                        //                       "By: ",
                                        //                       style: TextStyle(
                                        //                         fontFamily:
                                        //                             globalfontfamily,
                                        //                         color: Color.fromRGBO(
                                        //                             0, 0, 0, 1),
                                        //                         fontSize: 8.sp,
                                        //                         fontWeight:
                                        //                             FontWeight.w200,
                                        //                       ),
                                        //                     ),
                                        //                     Image.asset(
                                        //                         "assets/images/playr1.png"),
                                        //                     Text(
                                        //                       "praj.eth, 350mts away",
                                        //                       style: TextStyle(
                                        //                         fontFamily:
                                        //                             globalfontfamily,
                                        //                         color: Color.fromRGBO(
                                        //                             0, 0, 0, 1),
                                        //                         fontSize: 8.sp,
                                        //                         fontWeight:
                                        //                             FontWeight.w200,
                                        //                       ),
                                        //                     ),
                                        //                   ],
                                        //                 ),
                                        //                 Text(
                                        //                   "The fault in our stars",
                                        //                   style: TextStyle(
                                        //                     fontFamily: globalfontfamily,
                                        //                     color: Color.fromRGBO(
                                        //                         0, 0, 0, 1),
                                        //                     fontSize: 16.sp,
                                        //                     fontWeight: FontWeight.w400,
                                        //                   ),
                                        //                 ),
                                        //                 // Text(
                                        //                 //   "Author: Mikhail Naimy",
                                        //                 //   style: TextStyle(
                                        //                 //     fontFamily: globalfontfamily,
                                        //                 //     color:
                                        //                 //         Color.fromRGBO(0, 0, 0, 1),
                                        //                 //     fontSize: 16.sp,
                                        //                 //     fontWeight: FontWeight.w200,
                                        //                 //   ),
                                        //                 // ),
                                        //                 // SizedBox(
                                        //                 //   height: 12.h,
                                        //                 // ),
                                        //               ],
                                        //             ),
                                        //           ),
                                        //         ],
                                        //       ),
                                        //       Container(
                                        //         height: 1,
                                        //         color: Color.fromRGBO(198, 198, 200, 1),
                                        //       ),
                                        //       SizedBox(
                                        //         height: 12.h,
                                        //       ),
                                        //       Image.asset("assets/images/nextarr.png")
                                        //     ],
                                        //   ),
                                        // ),
                                        // SizedBox(
                                        //   height: 12.h,
                                        // ),
                                        GestureDetector(
                                          onTap: () {
                                            nextScreen(
                                                context, YourRequestScreen());
                                          },
                                          child: Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "View all",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        globalfontfamily,
                                                    color: Color.fromRGBO(
                                                        67, 128, 199, 1),
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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

  dynamic warningNoTask(BuildContext context) {
    return PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Normal",
      message:
          "There is no Task For Delete!\n Try adding some and then try to delete it!",
      buttonText: "Okay",
      onTapDismiss: () {
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.warning,
    );
  }
}
