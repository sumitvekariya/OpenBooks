// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:openbook/ScreenWidgets/peoplescreenwidget.dart';
// import 'package:openbook/utils/globalvar.dart';
// import 'package:openbook/Models/user_data_models.dart';
// import 'package:openbook/Models/user_model.dart';
// import 'package:openbook/Widgets/widgets.dart';
// import 'package:openbook/Screens/youraccountscreen.dart';

// class PeopleAroundYouScreen extends StatefulWidget {
//   const PeopleAroundYouScreen({super.key});

//   @override
//   State<PeopleAroundYouScreen> createState() => _PeopleAroundYouScreenState();
// }

// class _PeopleAroundYouScreenState extends State<PeopleAroundYouScreen> {
//   final List<Marker> markers = <Marker>[
//     // Marker(
//     //     markerId: MarkerId("1"),
//     //     position: LatLng(28.669155, 77.453758),
//     //     infoWindow: InfoWindow(title: "Hello")),
//     // Marker(
//     //     markerId: MarkerId("1"),
//     //     position: LatLng(28.669155, 77.453758),
//     //     infoWindow: InfoWindow(title: "Hello")),
//   ];
//   final Completer<GoogleMapController> controller = Completer();
//   late GoogleMapController mapController;
//   Set<Polyline> polylines = {};

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();

//     Future.delayed(Duration(microseconds: 1), () async {
//       // markers.add(
//       //   Marker(
//       //     markerId: MarkerId("2"),
//       //     position: LatLng(widget.fromlat, widget.fromlong),
//       //     infoWindow: InfoWindow(title: "My Location"),
//       //   ),
//       // );

//       // markers.add(
//       //   Marker(
//       //     markerId: MarkerId("31"),
//       //     position: LatLng(widget.destlat, widget.destlong),
//       //     infoWindow: InfoWindow(title: "Destination"),
//       //   ),
//       // );
//       CameraPosition cameraPosition = CameraPosition(
//         target: LatLng(28.644800, 77.216721),
//         zoom: 14,
//       );

//       final GoogleMapController cotrllr = await controller.future;

//       cotrllr.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

//       setState(() {});
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         height: screenHeight,
//         width: screenWidth,
//         color: Colors.transparent,
//         child: Stack(
//           alignment: Alignment.bottomCenter,
//           children: [
//             // GoogleMap(
//             //   mapType: MapType.terrain,
//             //   markers: Set<Marker>.of(markers),
//             //   onMapCreated: (GoogleMapController controllers) {
//             //     controller.complete(controllers);
//             //     // addPolyline();
//             //   },
//             //   initialCameraPosition: CameraPosition(
//             //     target: LatLng(28.644800, 77.216721),
//             //     zoom: 6.0,
//             //   ),
//             //   polylines: polylines,
//             // ),
//             Container(
//               height: screenHeight! * 0.9,
//               width: 390.w,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(32.r),
//                     topRight: Radius.circular(32.r)),
//               ),
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.only(
//                     left: 24.0,
//                     right: 24,
//                     top: 24,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Container(
//                       //   height: 53.h,
//                       //   width: 342.w,
//                       //   decoration: BoxDecoration(
//                       //     color: Color.fromRGBO(249, 249, 249, 1),
//                       //     borderRadius: BorderRadius.all(Radius.circular(12.r)),
//                       //   ),
//                       //   child: Padding(
//                       //     padding: EdgeInsets.only(left: 20.0.w, right: 20.0.w),
//                       //     child: Row(
//                       //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       //       children: [
//                       //         Text(
//                       //           "Search book ",
//                       //           style: TextStyle(
//                       //             fontFamily: globalfontfamily,
//                       //             color: Color.fromRGBO(0, 0, 0, 1),
//                       //             fontSize: 16.sp,
//                       //             fontWeight: FontWeight.w400,
//                       //           ),
//                       //         ),
//                       //         Image.asset("assets/images/scan.png")
//                       //       ],
//                       //     ),
//                       //   ),
//                       // ),
//                       // SizedBox(
//                       //   height: 20.h,
//                       // ),
//                       // Row(
//                       //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       //   children: [
//                       //     Text(
//                       //       "Browse people around you",
//                       //       style: TextStyle(
//                       //         fontFamily: globalfontfamily,
//                       //         color: Color.fromRGBO(85, 163, 255, 1),
//                       //         fontSize: 16.sp,
//                       //         fontWeight: FontWeight.w500,
//                       //       ),
//                       //     ),
//                       //     Image.asset("assets/images/frd.png")
//                       //   ],
//                       // ),
//                       // SizedBox(
//                       //   height: 20.h,
//                       // ),
//                       Text(
//                         "People around you",
//                         style: TextStyle(
//                           fontFamily: globalfontfamily,
//                           color: Color.fromRGBO(0, 0, 0, 1),
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(
//                         height: 20.h,
//                       ),
//                       Container(
//                         height: 680.h,
//                         width: 342.w,
//                         color: Color.fromRGBO(249, 249, 249, 1),
//                         child: Padding(
//                           padding: EdgeInsets.only(
//                             left: 20.0.w,
//                             right: 20.0.w,
//                             top: 16.h,
//                           ),
//                           child: StreamBuilder<QuerySnapshot>(
//                               stream: FirebaseFirestore.instance
//                                   .collection('users')
//                                   .snapshots(),
//                               builder: (context, snapshot) {
//                                 if (snapshot.hasError) {
//                                   return Text('Error: ${snapshot.error}');
//                                 }

//                                 if (snapshot.connectionState ==
//                                     ConnectionState.waiting) {
//                                   return Center(
//                                       child: CircularProgressIndicator());
//                                 }

//                                 List<UserPeopleModel> userdata = snapshot
//                                     .data!.docs
//                                     .map((DocumentSnapshot doc) {
//                                   Map<String, dynamic> data =
//                                       doc.data() as Map<String, dynamic>;
//                                   return UserPeopleModel.fromMap(data, doc.id);
//                                 }).toList();
//                                 return ListView.builder(
//                                     itemCount: userdata.length,
//                                     itemBuilder: (context, index) {
//                                       return PeopleWidget(
//                                         usermodel: userdata[index],
//                                       );
//                                     });
//                               }),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 20.h,
//                       ),
//                       // Text(
//                       //   "Your Requests",
//                       //   style: TextStyle(
//                       //     fontFamily: globalfontfamily,
//                       //     color: Color.fromRGBO(0, 0, 0, 1),
//                       //     fontSize: 16.sp,
//                       //     fontWeight: FontWeight.w500,
//                       //   ),
//                       // ),
//                       // SizedBox(
//                       //   height: 12.h,
//                       // ),
//                       // Container(
//                       //   // height: 143.h,
//                       //   width: 342.w,
//                       //   color: Color.fromRGBO(249, 249, 249, 1),
//                       //   child: Padding(
//                       //     padding: EdgeInsets.only(
//                       //       left: 20.0.w,
//                       //       right: 20.0.w,
//                       //       top: 16.h,
//                       //     ),
//                       //     child: Column(
//                       //       crossAxisAlignment: CrossAxisAlignment.start,
//                       //       children: [
//                       //         // Container(
//                       //         //   // color: Colors.red,
//                       //         //   child: Row(
//                       //         //     mainAxisAlignment:
//                       //         //         MainAxisAlignment.spaceBetween,
//                       //         //     children: [
//                       //         //       Row(
//                       //         //         mainAxisAlignment:
//                       //         //             MainAxisAlignment.start,
//                       //         //         crossAxisAlignment:
//                       //         //             CrossAxisAlignment.start,
//                       //         //         children: [
//                       //         //           Padding(
//                       //         //             padding:
//                       //         //                 EdgeInsets.only(left: 12.0.w),
//                       //         //             child: Column(
//                       //         //               mainAxisAlignment:
//                       //         //                   MainAxisAlignment.start,
//                       //         //               crossAxisAlignment:
//                       //         //                   CrossAxisAlignment.start,
//                       //         //               children: [
//                       //         //                 Row(
//                       //         //                   children: [
//                       //         //                     Text(
//                       //         //                       "By: ",
//                       //         //                       style: TextStyle(
//                       //         //                         fontFamily:
//                       //         //                             globalfontfamily,
//                       //         //                         color: Color.fromRGBO(
//                       //         //                             0, 0, 0, 1),
//                       //         //                         fontSize: 8.sp,
//                       //         //                         fontWeight:
//                       //         //                             FontWeight.w200,
//                       //         //                       ),
//                       //         //                     ),
//                       //         //                     Image.asset(
//                       //         //                         "assets/images/playr1.png"),
//                       //         //                     Text(
//                       //         //                       "praj.eth, 350mts away",
//                       //         //                       style: TextStyle(
//                       //         //                         fontFamily:
//                       //         //                             globalfontfamily,
//                       //         //                         color: Color.fromRGBO(
//                       //         //                             0, 0, 0, 1),
//                       //         //                         fontSize: 8.sp,
//                       //         //                         fontWeight:
//                       //         //                             FontWeight.w200,
//                       //         //                       ),
//                       //         //                     ),
//                       //         //                   ],
//                       //         //                 ),
//                       //         //                 Text(
//                       //         //                   "The Book of Mirad",
//                       //         //                   style: TextStyle(
//                       //         //                     fontFamily: globalfontfamily,
//                       //         //                     color: Color.fromRGBO(
//                       //         //                         0, 0, 0, 1),
//                       //         //                     fontSize: 16.sp,
//                       //         //                     fontWeight: FontWeight.w400,
//                       //         //                   ),
//                       //         //                 ),
//                       //         //                 // Text(
//                       //         //                 //   "Author: Mikhail Naimy",
//                       //         //                 //   style: TextStyle(
//                       //         //                 //     fontFamily: globalfontfamily,
//                       //         //                 //     color:
//                       //         //                 //         Color.fromRGBO(0, 0, 0, 1),
//                       //         //                 //     fontSize: 16.sp,
//                       //         //                 //     fontWeight: FontWeight.w200,
//                       //         //                 //   ),
//                       //         //                 // ),
//                       //         //                 // SizedBox(
//                       //         //                 //   height: 12.h,
//                       //         //                 // ),
//                       //         //               ],
//                       //         //             ),
//                       //         //           ),
//                       //         //         ],
//                       //         //       ),
//                       //         //       Container(
//                       //         //         height: 1,
//                       //         //         color: Color.fromRGBO(198, 198, 200, 1),
//                       //         //       ),
//                       //         //       SizedBox(
//                       //         //         height: 12.h,
//                       //         //       ),
//                       //         //       Image.asset("assets/images/nextarr.png")
//                       //         //     ],
//                       //         //   ),
//                       //         // ),
//                       //         // SizedBox(
//                       //         //   height: 12.h,
//                       //         // ),
//                       //         // Container(
//                       //         //   height: 1,
//                       //         //   color: Color.fromRGBO(198, 198, 200, 1),
//                       //         // ),
//                       //         // SizedBox(
//                       //         //   height: 12.h,
//                       //         // ),
//                       //         // Container(
//                       //         //   // color: Colors.red,
//                       //         //   child: Row(
//                       //         //     mainAxisAlignment:
//                       //         //         MainAxisAlignment.spaceBetween,
//                       //         //     children: [
//                       //         //       Row(
//                       //         //         mainAxisAlignment:
//                       //         //             MainAxisAlignment.start,
//                       //         //         crossAxisAlignment:
//                       //         //             CrossAxisAlignment.start,
//                       //         //         children: [
//                       //         //           Padding(
//                       //         //             padding:
//                       //         //                 EdgeInsets.only(left: 12.0.w),
//                       //         //             child: Column(
//                       //         //               mainAxisAlignment:
//                       //         //                   MainAxisAlignment.start,
//                       //         //               crossAxisAlignment:
//                       //         //                   CrossAxisAlignment.start,
//                       //         //               children: [
//                       //         //                 Row(
//                       //         //                   children: [
//                       //         //                     Text(
//                       //         //                       "By: ",
//                       //         //                       style: TextStyle(
//                       //         //                         fontFamily:
//                       //         //                             globalfontfamily,
//                       //         //                         color: Color.fromRGBO(
//                       //         //                             0, 0, 0, 1),
//                       //         //                         fontSize: 8.sp,
//                       //         //                         fontWeight:
//                       //         //                             FontWeight.w200,
//                       //         //                       ),
//                       //         //                     ),
//                       //         //                     Image.asset(
//                       //         //                         "assets/images/playr1.png"),
//                       //         //                     Text(
//                       //         //                       "praj.eth, 350mts away",
//                       //         //                       style: TextStyle(
//                       //         //                         fontFamily:
//                       //         //                             globalfontfamily,
//                       //         //                         color: Color.fromRGBO(
//                       //         //                             0, 0, 0, 1),
//                       //         //                         fontSize: 8.sp,
//                       //         //                         fontWeight:
//                       //         //                             FontWeight.w200,
//                       //         //                       ),
//                       //         //                     ),
//                       //         //                   ],
//                       //         //                 ),
//                       //         //                 Text(
//                       //         //                   "The fault in our stars",
//                       //         //                   style: TextStyle(
//                       //         //                     fontFamily: globalfontfamily,
//                       //         //                     color: Color.fromRGBO(
//                       //         //                         0, 0, 0, 1),
//                       //         //                     fontSize: 16.sp,
//                       //         //                     fontWeight: FontWeight.w400,
//                       //         //                   ),
//                       //         //                 ),
//                       //         //                 // Text(
//                       //         //                 //   "Author: Mikhail Naimy",
//                       //         //                 //   style: TextStyle(
//                       //         //                 //     fontFamily: globalfontfamily,
//                       //         //                 //     color:
//                       //         //                 //         Color.fromRGBO(0, 0, 0, 1),
//                       //         //                 //     fontSize: 16.sp,
//                       //         //                 //     fontWeight: FontWeight.w200,
//                       //         //                 //   ),
//                       //         //                 // ),
//                       //         //                 // SizedBox(
//                       //         //                 //   height: 12.h,
//                       //         //                 // ),
//                       //         //               ],
//                       //         //             ),
//                       //         //           ),
//                       //         //         ],
//                       //         //       ),
//                       //         //       Container(
//                       //         //         height: 1,
//                       //         //         color: Color.fromRGBO(198, 198, 200, 1),
//                       //         //       ),
//                       //         //       SizedBox(
//                       //         //         height: 12.h,
//                       //         //       ),
//                       //         //       Image.asset("assets/images/nextarr.png")
//                       //         //     ],
//                       //         //   ),
//                       //         // ),
//                       //         SizedBox(
//                       //           height: 12.h,
//                       //         ),
//                       //         // Container(
//                       //         //   child: Row(
//                       //         //     mainAxisAlignment: MainAxisAlignment.center,
//                       //         //     children: [
//                       //         //       Text(
//                       //         //         "View all",
//                       //         //         style: TextStyle(
//                       //         //           fontFamily: globalfontfamily,
//                       //         //           color: Color.fromRGBO(67, 128, 199, 1),
//                       //         //           fontSize: 12.sp,
//                       //         //           fontWeight: FontWeight.w400,
//                       //         //         ),
//                       //         //       ),
//                       //         //     ],
//                       //         //   ),
//                       //         // ),
//                       //         SizedBox(
//                       //           height: 16.h,
//                       //         ),
//                       //       ],
//                       //     ),
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// // class PeopleWidget extends StatelessWidget {
// //   final UserPeopleModel usermodel;
// //   const PeopleWidget({
// //     super.key,
// //     required this.usermodel,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       children: [
// //         Container(
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.start,
// //                 crossAxisAlignment: CrossAxisAlignment.center,
// //                 children: [
// //                   Container(
// //                     // margin: EdgeInsets.symmetric(horizontal: 16),
// //                     height: 30.h,
// //                     width: 30.w,
// //                     child: ClipRRect(
// //                       borderRadius: BorderRadius.circular(6),
// //                       child: CircleAvatar(
// //                         backgroundColor: Colors.white,
// //                         backgroundImage: Image.network(
// //                           usermodel.imageurl,
// //                           fit: BoxFit.cover,
// //                         ).image,
// //                         radius: 50,
// //                         // child: Image.file(
// //                         //   selectedImage!,
// //                         //   fit: BoxFit.cover,
// //                         // ),
// //                       ),
// //                     ),
// //                   ),
// //                   Padding(
// //                     padding: EdgeInsets.only(left: 12.0.w),
// //                     child: Column(
// //                       mainAxisAlignment: MainAxisAlignment.start,
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           "${usermodel.username}",
// //                           style: TextStyle(
// //                             fontFamily: globalfontfamily,
// //                             color: Color.fromRGBO(0, 0, 0, 1),
// //                             fontSize: 16.sp,
// //                             fontWeight: FontWeight.w400,
// //                           ),
// //                         ),
// //                         Text(
// //                           "${usermodel.locationname}",
// //                           style: TextStyle(
// //                             fontFamily: globalfontfamily,
// //                             color: Color.fromRGBO(0, 0, 0, 1),
// //                             fontSize: 12.sp,
// //                             fontWeight: FontWeight.w200,
// //                           ),
// //                         ),
// //                         // SizedBox(
// //                         //   height: 12.h,
// //                         // ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               Container(
// //                 height: 1,
// //                 color: Color.fromRGBO(198, 198, 200, 1),
// //               ),
// //               SizedBox(
// //                 height: 12.h,
// //               ),
// //               Image.asset("assets/images/msg.png")
// //             ],
// //           ),
// //         ),
// //         SizedBox(
// //           height: 12.h,
// //         ),
// //         Container(
// //           height: 1,
// //           color: Color.fromRGBO(198, 198, 200, 1),
// //         ),
// //         SizedBox(
// //           height: 12.h,
// //         ),
// //       ],
// //     );
// //   }
// // }

// // class PeopleBox extends StatelessWidget {
// //   const PeopleBox({
// //     super.key,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: () {
// //         nextScreen(context, YourAccountScreen());
// //       },
// //       child: Container(
// //         // color: Colors.red,
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.start,
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Image.asset("assets/images/people.png"),
// //                 Padding(
// //                   padding: EdgeInsets.only(left: 12.0.w),
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.start,
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         "Aisha Mukherjee",
// //                         style: TextStyle(
// //                           fontFamily: globalfontfamily,
// //                           color: Color.fromRGBO(0, 0, 0, 1),
// //                           fontSize: 16.sp,
// //                           fontWeight: FontWeight.w400,
// //                         ),
// //                       ),
// //                       Text(
// //                         "320+ books",
// //                         style: TextStyle(
// //                           fontFamily: globalfontfamily,
// //                           color: Color.fromRGBO(0, 0, 0, 1),
// //                           fontSize: 12.sp,
// //                           fontWeight: FontWeight.w200,
// //                         ),
// //                       ),
// //                       // SizedBox(
// //                       //   height: 12.h,
// //                       // ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             Container(
// //               height: 1,
// //               color: Color.fromRGBO(198, 198, 200, 1),
// //             ),
// //             SizedBox(
// //               height: 12.h,
// //             ),
// //             Image.asset("assets/images/msg.png")
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
