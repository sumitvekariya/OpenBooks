import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:openbook/Models/recieved_book_model.dart';
import 'package:openbook/ScreenWidgets/recievedbookwidget.dart';
import 'package:openbook/TwitterAuth/provider/sign_in_provider.dart';
import 'package:openbook/utils/global_data.dart';
import 'package:openbook/utils/globalvar.dart';
import 'package:provider/provider.dart';

class RecievedBookScreen extends StatefulWidget {
  const RecievedBookScreen({super.key});

  @override
  State<RecievedBookScreen> createState() => _RecievedBookScreenState();
}

class _RecievedBookScreenState extends State<RecievedBookScreen> {
  final List<Marker> markers = <Marker>[];
  final Completer<GoogleMapController> controller = Completer();
  late GoogleMapController mapController;
  Set<Polyline> polylines = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration(microseconds: 1), () async {
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
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
                  topRight: Radius.circular(32.r),
                ),
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
                        "Received Books",
                        style: TextStyle(
                          fontFamily: globalfontfamily,
                          color: const Color.fromRGBO(0, 0, 0, 1),
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
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(249, 249, 249, 1),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32.r),
                            topRight: Radius.circular(32.r),
                            bottomLeft: Radius.circular(32.r),
                            bottomRight: Radius.circular(32.r),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 20.0.w,
                            right: 20.0.w,
                            top: 20.h,
                            bottom: 20.h,
                          ),
                          child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance.collection('users').doc(userglobalData!.uid).collection('RecievedBooks').snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }

                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }

                                List<RecievedBook> books = snapshot.data!.docs.map((DocumentSnapshot doc) {
                                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                                  return RecievedBook.fromMap(data, doc.id);
                                }).toList();
                                return ListView.builder(
                                    itemCount: books.length,
                                    itemBuilder: (context, index) {
                                      return RecievedBookwidget(
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
    );
  }
}
