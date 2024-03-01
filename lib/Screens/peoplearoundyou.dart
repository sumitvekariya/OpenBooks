import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:openbook/ScreenWidgets/peoplescreenwidget.dart';
import 'package:openbook/utils/globalvar.dart';

import 'package:openbook/Models/user_model.dart';

class PeopleAroundYouScreen extends StatefulWidget {
  const PeopleAroundYouScreen({super.key});

  @override
  State<PeopleAroundYouScreen> createState() => _PeopleAroundYouScreenState();
}

class _PeopleAroundYouScreenState extends State<PeopleAroundYouScreen> {
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
    return Scaffold(
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
                      Text(
                        "People around you",
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
                        height: 680.h,
                        width: 342.w,
                        color: Color.fromRGBO(249, 249, 249, 1),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 20.0.w,
                            right: 20.0.w,
                            top: 16.h,
                          ),
                          child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
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

                                List<UserPeopleModel> userdata = snapshot
                                    .data!.docs
                                    .map((DocumentSnapshot doc) {
                                  Map<String, dynamic> data =
                                      doc.data() as Map<String, dynamic>;
                                  return UserPeopleModel.fromMap(data, doc.id);
                                }).toList();
                                return ListView.builder(
                                    itemCount: userdata.length,
                                    itemBuilder: (context, index) {
                                      return PeopleWidget(
                                        usermodel: userdata[index],
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
