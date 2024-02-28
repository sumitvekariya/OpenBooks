import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:openbook/globalvar.dart';
import 'package:openbook/onboardingscreen.dart';
// import 'package:openbook/twitterauth/Models/book_model.dart';
import 'package:openbook/twitterauth/Models/rquest_book_model.dart';
import 'package:openbook/twitterauth/provider/sign_in_provider.dart';
import 'package:openbook/twitterauth/utils/global_data.dart';
import 'package:openbook/twitterauth/utils/next_screen.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class YourRequestScreen extends StatefulWidget {
  const YourRequestScreen({super.key});

  @override
  State<YourRequestScreen> createState() => _YourRequestScreenState();
}

class _YourRequestScreenState extends State<YourRequestScreen> {
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration(seconds: 1), () async {
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
      CameraPosition cameraPosition = CameraPosition(
        target: LatLng(28.644800, 77.216721),
        zoom: 14,
      );

      final GoogleMapController cotrllr = await controller.future;

      cotrllr.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          width: screenWidth,
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // GoogleMap(
              //   mapType: MapType.terrain,
              //   markers: Set<Marker>.of(markers),
              //   onMapCreated: (GoogleMapController controllers) {
              //     controller.complete(controllers);
              //     // addPolyline();
              //   },
              //   initialCameraPosition: CameraPosition(
              //     target: LatLng(28.644800, 77.216721),
              //     zoom: 6.0,
              //   ),
              //   polylines: polylines,
              // ),
              Container(
                height: screenHeight! * 0.9,
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
                        // Container(
                        //   height: 53.h,
                        //   width: 342.w,
                        //   decoration: BoxDecoration(
                        //     color: Color.fromRGBO(249, 249, 249, 1),
                        //     borderRadius:
                        //         BorderRadius.all(Radius.circular(12.r)),
                        //   ),
                        //   child: Padding(
                        //     padding:
                        //         EdgeInsets.only(left: 20.0.w, right: 20.0.w),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         ElevatedButton(
                        //             onPressed: () {
                        //               sp.userSignOut();
                        //               nextScreenReplace(
                        //                   context, const OnBoradingScreen());
                        //             },
                        //             child: const Text("SIGNOUT",
                        //                 style: TextStyle(
                        //                   color: Colors.white,
                        //                 ))),
                        //         Text(
                        //           "Search book ",
                        //           style: TextStyle(
                        //             fontFamily: globalfontfamily,
                        //             color: Color.fromRGBO(0, 0, 0, 1),
                        //             fontSize: 16.sp,
                        //             fontWeight: FontWeight.w400,
                        //           ),
                        //         ),
                        //         Image.asset("assets/images/scan.png")
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 20.h,
                        // ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Text(
                        //       "Browse people around you",
                        //       style: TextStyle(
                        //         fontFamily: globalfontfamily,
                        //         color: Color.fromRGBO(85, 163, 255, 1),
                        //         fontSize: 16.sp,
                        //         fontWeight: FontWeight.w500,
                        //       ),
                        //     ),
                        //     Image.asset("assets/images/frd.png")
                        //   ],
                        // ),
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
                          height: 20.h,
                        ),
                        Container(
                          height: 650.h,
                          width: 342.w,
                          color: Color.fromRGBO(249, 249, 249, 1),
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 20.0.w,
                              right: 20.0.w,
                              top: 0.h,
                              bottom: 10.h,
                            ),
                            child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userglobalData!.uid)
                                    .collection('RequestedBooks')
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

                                  List<RequestedBook> books = snapshot
                                      .data!.docs
                                      .map((DocumentSnapshot doc) {
                                    Map<String, dynamic> data =
                                        doc.data() as Map<String, dynamic>;
                                    return RequestedBook.fromMap(data, doc.id);
                                  }).toList();
                                  return ListView.builder(
                                      itemCount: books.length,
                                      itemBuilder: (context, index) {
                                        print("books.length: ${books.length}");
                                        return RequestBookwidget(
                                          book: books[index],
                                        );
                                      });
                                }),
                          ),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        // Text(
                        //   "Your Requests",
                        //   style: TextStyle(
                        //     fontFamily: globalfontfamily,
                        //     color: Color.fromRGBO(0, 0, 0, 1),
                        //     fontSize: 16.sp,
                        //     fontWeight: FontWeight.w500,
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 12.h,
                        // ),
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
                        //         // Container(
                        //         //   // color: Colors.red,
                        //         //   child: Row(
                        //         //     mainAxisAlignment:
                        //         //         MainAxisAlignment.spaceBetween,
                        //         //     children: [
                        //         //       Row(
                        //         //         mainAxisAlignment:
                        //         //             MainAxisAlignment.start,
                        //         //         crossAxisAlignment:
                        //         //             CrossAxisAlignment.start,
                        //         //         children: [
                        //         //           Padding(
                        //         //             padding:
                        //         //                 EdgeInsets.only(left: 12.0.w),
                        //         //             child: Column(
                        //         //               mainAxisAlignment:
                        //         //                   MainAxisAlignment.start,
                        //         //               crossAxisAlignment:
                        //         //                   CrossAxisAlignment.start,
                        //         //               children: [
                        //         //                 Row(
                        //         //                   children: [
                        //         //                     Text(
                        //         //                       "By: ",
                        //         //                       style: TextStyle(
                        //         //                         fontFamily:
                        //         //                             globalfontfamily,
                        //         //                         color: Color.fromRGBO(
                        //         //                             0, 0, 0, 1),
                        //         //                         fontSize: 8.sp,
                        //         //                         fontWeight:
                        //         //                             FontWeight.w200,
                        //         //                       ),
                        //         //                     ),
                        //         //                     Image.asset(
                        //         //                         "assets/images/playr1.png"),
                        //         //                     Text(
                        //         //                       "praj.eth, 350mts away",
                        //         //                       style: TextStyle(
                        //         //                         fontFamily:
                        //         //                             globalfontfamily,
                        //         //                         color: Color.fromRGBO(
                        //         //                             0, 0, 0, 1),
                        //         //                         fontSize: 8.sp,
                        //         //                         fontWeight:
                        //         //                             FontWeight.w200,
                        //         //                       ),
                        //         //                     ),
                        //         //                   ],
                        //         //                 ),
                        //         //                 Text(
                        //         //                   "The Book of Mirad",
                        //         //                   style: TextStyle(
                        //         //                     fontFamily: globalfontfamily,
                        //         //                     color: Color.fromRGBO(
                        //         //                         0, 0, 0, 1),
                        //         //                     fontSize: 16.sp,
                        //         //                     fontWeight: FontWeight.w400,
                        //         //                   ),
                        //         //                 ),
                        //         //                 // Text(
                        //         //                 //   "Author: Mikhail Naimy",
                        //         //                 //   style: TextStyle(
                        //         //                 //     fontFamily: globalfontfamily,
                        //         //                 //     color:
                        //         //                 //         Color.fromRGBO(0, 0, 0, 1),
                        //         //                 //     fontSize: 16.sp,
                        //         //                 //     fontWeight: FontWeight.w200,
                        //         //                 //   ),
                        //         //                 // ),
                        //         //                 // SizedBox(
                        //         //                 //   height: 12.h,
                        //         //                 // ),
                        //         //               ],
                        //         //             ),
                        //         //           ),
                        //         //         ],
                        //         //       ),
                        //         //       Container(
                        //         //         height: 1,
                        //         //         color: Color.fromRGBO(198, 198, 200, 1),
                        //         //       ),
                        //         //       SizedBox(
                        //         //         height: 12.h,
                        //         //       ),
                        //         //       Image.asset("assets/images/nextarr.png")
                        //         //     ],
                        //         //   ),
                        //         // ),
                        //         // SizedBox(
                        //         //   height: 12.h,
                        //         // ),
                        //         // Container(
                        //         //   height: 1,
                        //         //   color: Color.fromRGBO(198, 198, 200, 1),
                        //         // ),
                        //         // SizedBox(
                        //         //   height: 12.h,
                        //         // ),
                        //         // Container(
                        //         //   // color: Colors.red,
                        //         //   child: Row(
                        //         //     mainAxisAlignment:
                        //         //         MainAxisAlignment.spaceBetween,
                        //         //     children: [
                        //         //       Row(
                        //         //         mainAxisAlignment:
                        //         //             MainAxisAlignment.start,
                        //         //         crossAxisAlignment:
                        //         //             CrossAxisAlignment.start,
                        //         //         children: [
                        //         //           Padding(
                        //         //             padding:
                        //         //                 EdgeInsets.only(left: 12.0.w),
                        //         //             child: Column(
                        //         //               mainAxisAlignment:
                        //         //                   MainAxisAlignment.start,
                        //         //               crossAxisAlignment:
                        //         //                   CrossAxisAlignment.start,
                        //         //               children: [
                        //         //                 Row(
                        //         //                   children: [
                        //         //                     Text(
                        //         //                       "By: ",
                        //         //                       style: TextStyle(
                        //         //                         fontFamily:
                        //         //                             globalfontfamily,
                        //         //                         color: Color.fromRGBO(
                        //         //                             0, 0, 0, 1),
                        //         //                         fontSize: 8.sp,
                        //         //                         fontWeight:
                        //         //                             FontWeight.w200,
                        //         //                       ),
                        //         //                     ),
                        //         //                     Image.asset(
                        //         //                         "assets/images/playr1.png"),
                        //         //                     Text(
                        //         //                       "praj.eth, 350mts away",
                        //         //                       style: TextStyle(
                        //         //                         fontFamily:
                        //         //                             globalfontfamily,
                        //         //                         color: Color.fromRGBO(
                        //         //                             0, 0, 0, 1),
                        //         //                         fontSize: 8.sp,
                        //         //                         fontWeight:
                        //         //                             FontWeight.w200,
                        //         //                       ),
                        //         //                     ),
                        //         //                   ],
                        //         //                 ),
                        //         //                 Text(
                        //         //                   "The fault in our stars",
                        //         //                   style: TextStyle(
                        //         //                     fontFamily: globalfontfamily,
                        //         //                     color: Color.fromRGBO(
                        //         //                         0, 0, 0, 1),
                        //         //                     fontSize: 16.sp,
                        //         //                     fontWeight: FontWeight.w400,
                        //         //                   ),
                        //         //                 ),
                        //         //                 // Text(
                        //         //                 //   "Author: Mikhail Naimy",
                        //         //                 //   style: TextStyle(
                        //         //                 //     fontFamily: globalfontfamily,
                        //         //                 //     color:
                        //         //                 //         Color.fromRGBO(0, 0, 0, 1),
                        //         //                 //     fontSize: 16.sp,
                        //         //                 //     fontWeight: FontWeight.w200,
                        //         //                 //   ),
                        //         //                 // ),
                        //         //                 // SizedBox(
                        //         //                 //   height: 12.h,
                        //         //                 // ),
                        //         //               ],
                        //         //             ),
                        //         //           ),
                        //         //         ],
                        //         //       ),
                        //         //       Container(
                        //         //         height: 1,
                        //         //         color: Color.fromRGBO(198, 198, 200, 1),
                        //         //       ),
                        //         //       SizedBox(
                        //         //         height: 12.h,
                        //         //       ),
                        //         //       Image.asset("assets/images/nextarr.png")
                        //         //     ],
                        //         //   ),
                        //         // ),
                        //         SizedBox(
                        //           height: 12.h,
                        //         ),
                        //         // Container(
                        //         //   child: Row(
                        //         //     mainAxisAlignment: MainAxisAlignment.center,
                        //         //     children: [
                        //         //       Text(
                        //         //         "View all",
                        //         //         style: TextStyle(
                        //         //           fontFamily: globalfontfamily,
                        //         //           color: Color.fromRGBO(67, 128, 199, 1),
                        //         //           fontSize: 12.sp,
                        //         //           fontWeight: FontWeight.w400,
                        //         //         ),
                        //         //       ),
                        //         //     ],
                        //         //   ),
                        //         // ),
                        //         SizedBox(
                        //           height: 16.h,
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
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
}

class RequestBookwidget extends StatefulWidget {
  final RequestedBook book;

  const RequestBookwidget({
    super.key,
    required this.book,
  });

  @override
  State<RequestBookwidget> createState() => _RequestBookwidgetState();
}

class _RequestBookwidgetState extends State<RequestBookwidget> {
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
                    // Image.network(widget.book.imageCover),
                    Padding(
                      padding: EdgeInsets.only(left: 12.0.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "requested by: ",
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
                                      widget.book.requestuserimage,
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
                                "${widget.book.requestusername}, ${widget.book.requestuserlocation}",
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
                        CustomSnackBar.success(
                          message:
                              'Great! ${widget.book.bookName} sucessfully rented to ${widget.book.requestusername}',
                        ),
                      );
                      setState(() {
                        isloading = true;
                      });

                      print("Bookname :  ${widget.book.bookName}");

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
                        rentedusername: widget.book.requestusername,
                        renteduserimage: widget.book.requestuserimage,
                        renteduseruid: widget.book.requestuseruid,
                        renteduserlocation: widget.book.requestuserlocation,
                        rentedtuserlat: widget.book.requestuserlat,
                        renteduserlong: widget.book.requestuserlong,
                        bookdesc: widget.book.bookdesc,
                      );

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
                            child: Image.asset("assets/images/nextarr.png"),
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
    required double rentedtuserlat,
    required double renteduserlong,
    required String bookdesc,
  }) async {
    final DocumentReference r = FirebaseFirestore.instance
        .collection("users")
        .doc(useruid)
        .collection("RentedBooks")
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
      "rentedusername": rentedusername,
      "renteduserimage": renteduserimage,
      "renteduseruid": renteduseruid,
      "renteduserlocation": renteduserlocation,
      "rentedtuserlat": rentedtuserlat,
      "renteduserlong": renteduserlong,
      "bookdesc": bookdesc,
    });

    final DocumentReference br = FirebaseFirestore.instance
        .collection("users")
        .doc(renteduseruid)
        .collection("RecievedBooks")
        .doc(bookid);

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
      "recievedusername": rentedusername,
      "recieveduserimage": renteduserimage,
      "recieveduseruid": renteduseruid,
      "recieveduserlocation": renteduserlocation,
      "recievedtuserlat": rentedtuserlat,
      "recieveduserlong": renteduserlong,
      "bookdesc": bookdesc,
    });

    final DocumentReference dl = FirebaseFirestore.instance
        .collection("users")
        .doc(useruid)
        .collection("RequestedBooks")
        .doc(bookid);

    await dl.delete();

    print("THis 1 runs");

    final DocumentReference del = FirebaseFirestore.instance
        .collection("users")
        .doc(useruid)
        .collection("Books")
        .doc(bookid);

    await del.delete();

    print("THis 2 runs");

    await FirebaseFirestore.instance.collection("Books").doc(bookid).update({
      "isrented": true,
    });

    print("THis 3 runs");

    // await FirebaseFirestore.instance
    //     .collection("users")
    //     .doc(widget.book.userUid)
    //     .collection("Books")
    //     .doc(widget.book.bookId)
    //     .update({
    //   "isrented": true,
    // });

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
