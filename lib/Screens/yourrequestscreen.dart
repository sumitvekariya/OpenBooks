import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:openbook/ScreenWidgets/requestscreenwidget.dart';
import 'package:openbook/utils/globalvar.dart';

import 'package:openbook/Models/rquest_book_model.dart';
import 'package:openbook/TwitterAuth/provider/sign_in_provider.dart';
import 'package:openbook/utils/global_data.dart';

import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:provider/provider.dart';

class YourRequestScreen extends StatefulWidget {
  const YourRequestScreen({super.key});

  @override
  State<YourRequestScreen> createState() => _YourRequestScreenState();
}

class _YourRequestScreenState extends State<YourRequestScreen> {
  final List<Marker> markers = <Marker>[];
  final Completer<GoogleMapController> controller = Completer();
  late GoogleMapController mapController;
  Set<Polyline> polylines = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration(seconds: 1), () async {
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
