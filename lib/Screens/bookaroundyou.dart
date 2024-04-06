import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:openbook/Models/book_model.dart';
import 'package:openbook/Screens/bookdetails.dart';
import 'package:openbook/TwitterAuth/provider/sign_in_provider.dart';
import 'package:openbook/Widgets/widgets.dart' as snackbar;
import 'package:openbook/utils/global_data.dart';
import 'package:openbook/utils/globalvar.dart';
import 'package:openbook/utils/next_screen.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';

class BookAroundYouScreen extends StatefulWidget {
  const BookAroundYouScreen({super.key});

  @override
  State<BookAroundYouScreen> createState() => _BookAroundYouScreenState();
}

class _BookAroundYouScreenState extends State<BookAroundYouScreen> {
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

    Future.delayed(const Duration(microseconds: 1), () async {
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
      CameraPosition cameraPosition = const CameraPosition(
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: ScreenUtil().screenHeight! * 0.9,
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
                    SizedBox(height: 20.h),
                    Text(
                      "Books around you",
                      style: TextStyle(fontFamily: globalfontfamily, fontSize: 16.sp, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      height: 650.h,
                      width: 342.w,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.grey[100]),
                      child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('Books').snapshots(),
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

                            return ListView.separated(
                              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                              itemCount: books.length,
                              itemBuilder: (context, index) {
                                return Bookwidget(
                                  book: books[index],
                                );
                              },
                              separatorBuilder: (BuildContext context, int index) => const Divider(),
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Bookwidget extends StatefulWidget {
  final Book book;
  const Bookwidget({
    super.key,
    required this.book,
  });

  @override
  State<Bookwidget> createState() => _BookwidgetState();
}

class _BookwidgetState extends State<Bookwidget> {
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(context, BookDetails(book: widget.book));
      },
      child: Row(
        children: [
          Image.network(widget.book.imageCover, fit: BoxFit.fill, height: 60.h, width: 40.w),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "By: ",
                      style: TextStyle(
                        fontFamily: globalfontfamily,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w200,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: Image.network(
                            widget.book.userimage,
                            fit: BoxFit.cover,
                          ).image,
                          radius: 4.r),
                    ),
                    Expanded(
                      child: Text(
                        " ${widget.book.username}, ${widget.book.userLocation}",
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: TextStyle(
                          fontFamily: globalfontfamily,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w200,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.book.bookName,
                  style: TextStyle(fontFamily: globalfontfamily, fontSize: 12.sp, fontWeight: FontWeight.w500),
                ),
                Text(
                  "Author: ${widget.book.authorName}",
                  style: TextStyle(
                    fontFamily: globalfontfamily,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w200,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          userglobalData?.uid != widget.book.userUid
              ? Container()
              : TapBounceContainer(
                  child: GestureDetector(
                    onTap: () async {
                      snackbar.showSnackbar(
                        context,
                        Colors.blue,
                        'Good job, The ${widget.book.bookName} request send to @${widget.book.username}',
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
                        requestusername: userglobalData!.username,
                        requestuserimage: userglobalData!.imageurl,
                        requestuseruid: userglobalData!.uid,
                        requestuserlocation: userglobalData!.locationname,
                        requestuserlat: userglobalData!.userlat,
                        requestuserlong: userglobalData!.userlong,
                        bookdesc: widget.book.bookdesc,
                      );

                      setState(() {
                        isloading = false;
                      });

                      // warningNoTask(context);
                    },
                    child: isloading
                        ? SizedBox(
                            height: 19.h,
                            width: 19.w,
                            child: const CircularProgressIndicator(),
                          )
                        : Text(
                            "Chat",
                            style: TextStyle(
                              fontFamily: globalfontfamily,
                              color: Colors.blueAccent,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
          SizedBox(width: 10.w)
        ],
      ),
    );
  }

  Future warningNoTask(BuildContext context) async {
    return PanaraInfoDialog.showAnimatedGrow(
      noImage: true,
      context,
      title: "Warning",
      message: "Already Requested to Chat",
      buttonText: "Okay",
      onTapDismiss: () async {
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.warning,
    );
  }

  Future saveDataToFirestore(
      {required String bookid,
      required String bookname,
      required String authorname,
      required String imgcover,
      required String username,
      required String userimage,
      required String useruid,
      required String userlocation,
      required double userlat,
      required double userlong,
      required String requestusername,
      required String requestuserimage,
      required String requestuseruid,
      required String requestuserlocation,
      required double requestuserlat,
      required double requestuserlong,
      required String bookdesc,
      re}) async {
    final DocumentSnapshot pr = await FirebaseFirestore.instance.collection("users").doc(useruid).collection("RequestedBooks").doc(bookid).get();

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(useruid)
        .collection("RequestedBooks")
        .limit(1) // Limit to 1 document to reduce data transfer
        .get();

    print("querySnapshot.docs.isNotEmpty  ${querySnapshot.docs.isNotEmpty}");
    print("pr.exists: ${pr.exists}");

    if (pr.exists) {
      warningNoTask(context);
      print("already  requested");
    } else {
      final DocumentReference r = FirebaseFirestore.instance.collection("users").doc(useruid).collection("RequestedBooks").doc(bookid);

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
        "requestusername": requestusername,
        "requestuserimage": requestuserimage,
        "requestuseruid": requestuseruid,
        "requestuserlocation": requestuserlocation,
        "requestuserlat": requestuserlat,
        "requestuserlong": requestuserlong,
        "bookdesc": bookdesc,
      });
    }
  }
}
