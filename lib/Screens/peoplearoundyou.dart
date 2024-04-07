import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:openbook/Chat/users.dart';

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

    Future.delayed(const Duration(microseconds: 1), () async {
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
    return Scaffold(
      appBar: AppBar(
        title: Text("People around you", style: TextStyle(fontSize: 16.sp)),
      ),
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          // decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r), color: Colors.grey[100]),
          child: const UsersPage()),
    );
  }
}
