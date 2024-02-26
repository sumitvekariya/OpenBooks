import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openbook/bookaroundyou.dart.dart';
import 'package:openbook/globalvar.dart';
import 'package:openbook/onboardingscreen.dart';
import 'package:openbook/recievedbookscreen.dart';
import 'package:openbook/twitterauth/Models/book_model.dart';
import 'package:openbook/twitterauth/Models/recieved_book_model.dart';
import 'package:openbook/twitterauth/Models/rented_book_model.dart';
import 'package:openbook/twitterauth/provider/sign_in_provider.dart';
import 'package:openbook/twitterauth/utils/global_data.dart';
import 'package:openbook/twitterauth/utils/next_screen.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:provider/provider.dart';

class YourAccountScreen extends StatefulWidget {
  const YourAccountScreen({super.key});

  @override
  State<YourAccountScreen> createState() => _YourAccountScreenState();
}

class _YourAccountScreenState extends State<YourAccountScreen> {
  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          // color: Colors.red,
          width: screenWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 48.h,
              ),
              Padding(
                padding: EdgeInsets.only(left: 24.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your account",
                      style: TextStyle(
                          fontFamily: globalfontfamily,
                          color: Colors.black,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w600),
                    ),
                    // Container(
                    //   width: 300.w,
                    //   child: Text(
                    //     "Help us know more about your book preferences so we can let others know about your books",
                    //     style: TextStyle(
                    //         fontFamily: globalfontfamily,
                    //         color: Colors.black,
                    //         fontSize: 12.sp,
                    //         fontWeight: FontWeight.w300),
                    //   ),
                    // ),
                  ],
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  height: 102.h,
                  width: 102.w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
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
              SizedBox(
                height: 20.h,
              ),
              Padding(
                padding: EdgeInsets.only(left: 24.0.w),
                child: Container(
                  // color: Colors.red,
                  height: 98.h,
                  width: 342.w,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20.0.w, top: 16.h),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Name",
                              style: TextStyle(
                                fontFamily: globalfontfamily,
                                color: Colors.black,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            SizedBox(
                              width: 50.w,
                            ),
                            Text(
                              "${userglobalData!.name}",
                              style: TextStyle(
                                fontFamily: globalfontfamily,
                                color: Colors.black,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "username",
                              style: TextStyle(
                                fontFamily: globalfontfamily,
                                color: Colors.black,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            SizedBox(
                              width: 22.w,
                            ),
                            Text(
                              "${userglobalData!.username}",
                              style: TextStyle(
                                fontFamily: globalfontfamily,
                                color: Colors.black,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Padding(
                padding: EdgeInsets.only(left: 24.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your top 3 books",
                      style: TextStyle(
                        fontFamily: globalfontfamily,
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "This helps us better match make",
                      style: TextStyle(
                        fontFamily: globalfontfamily,
                        color: Colors.black,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(
                      height: 12.h,
                    ),

                    Container(
                      height: 290.h,
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
                                .collection('Books')
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
                              List<Book> books = snapshot.data!.docs
                                  .map((DocumentSnapshot doc) {
                                Map<String, dynamic> data =
                                    doc.data() as Map<String, dynamic>;
                                return Book.fromMap(data, doc.id);
                              }).toList();
                              return ListView.builder(
                                  itemCount: books.length,
                                  itemBuilder: (context, index) {
                                    return AccountBookwidget(
                                      book: books[index],
                                    );
                                  });
                            }),
                      ),
                    ),

                    SizedBox(
                      height: 10.h,
                    ),

                    Text(
                      "Recieved Books",
                      style: TextStyle(
                        fontFamily: globalfontfamily,
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Text(
                    //   "This helps us better match make",
                    //   style: TextStyle(
                    //     fontFamily: globalfontfamily,
                    //     color: Colors.black,
                    //     fontSize: 12.sp,
                    //     fontWeight: FontWeight.w300,
                    //   ),
                    // ),
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
                                .collection('RecievedBooks')
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
                              List<RecievedBook> books = snapshot.data!.docs
                                  .map((DocumentSnapshot doc) {
                                Map<String, dynamic> data =
                                    doc.data() as Map<String, dynamic>;
                                return RecievedBook.fromMap(data, doc.id);
                              }).toList();
                              return ListView.builder(
                                  itemCount: books.length == 1
                                      ? 1
                                      : books.length == 0
                                          ? 0
                                          : 2,
                                  itemBuilder: (context, index) {
                                    return RecievedBookwidget(
                                      book: books[index],
                                    );
                                  });
                            }),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        nextScreen(context, RecievedBookScreen());
                      },
                      child: Container(
                        width: 342.w,
                        color: Color.fromRGBO(249, 249, 249, 1),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 14.0.h),
                          child: Center(
                            child: Text(
                              "view all",
                              style: TextStyle(
                                fontFamily: globalfontfamily,
                                color: Color.fromRGBO(67, 128, 199, 1),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 10.h,
                    ),

                    Text(
                      "Rented Books",
                      style: TextStyle(
                        fontFamily: globalfontfamily,
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Text(
                    //   "This helps us better match make",
                    //   style: TextStyle(
                    //     fontFamily: globalfontfamily,
                    //     color: Colors.black,
                    //     fontSize: 12.sp,
                    //     fontWeight: FontWeight.w300,
                    //   ),
                    // ),
                    SizedBox(
                      height: 12.h,
                    ),

                    Container(
                      height: 290.h,
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
                                .collection('RentedBooks')
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
                              List<RentedBook> books = snapshot.data!.docs
                                  .map((DocumentSnapshot doc) {
                                Map<String, dynamic> data =
                                    doc.data() as Map<String, dynamic>;
                                return RentedBook.fromMap(data, doc.id);
                              }).toList();
                              return ListView.builder(
                                  itemCount: books.length,
                                  itemBuilder: (context, index) {
                                    return RentedBookWidget(
                                      book: books[index],
                                    );
                                  });
                            }),
                      ),
                    ),

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
                    //         Container(
                    //           child: Row(
                    //             mainAxisAlignment:
                    //                 MainAxisAlignment.spaceBetween,
                    //             children: [
                    //               Text(
                    //                 "The Book of Mirad",
                    //                 style: TextStyle(
                    //                   fontFamily: globalfontfamily,
                    //                   color: Color.fromRGBO(0, 0, 0, 1),
                    //                   fontSize: 16.sp,
                    //                   fontWeight: FontWeight.w400,
                    //                 ),
                    //               ),
                    //               Image.asset("assets/images/scan.png")
                    //             ],
                    //           ),
                    //         ),
                    //         SizedBox(
                    //           height: 12.h,
                    //         ),
                    //         Container(
                    //           height: 1,
                    //           color: Color.fromRGBO(198, 198, 200, 1),
                    //         ),
                    //         SizedBox(
                    //           height: 12.h,
                    //         ),
                    //         Container(
                    //           child: Row(
                    //             mainAxisAlignment:
                    //                 MainAxisAlignment.spaceBetween,
                    //             children: [
                    //               Text(
                    //                 "Mans search for meaning",
                    //                 style: TextStyle(
                    //                   fontFamily: globalfontfamily,
                    //                   color: Color.fromRGBO(0, 0, 0, 1),
                    //                   fontSize: 16.sp,
                    //                   fontWeight: FontWeight.w400,
                    //                 ),
                    //               ),
                    //               Image.asset("assets/images/scan.png")
                    //             ],
                    //           ),
                    //         ),
                    //         SizedBox(
                    //           height: 12.h,
                    //         ),
                    //         Container(
                    //           height: 1,
                    //           color: Color.fromRGBO(198, 198, 200, 1),
                    //         ),
                    //         SizedBox(
                    //           height: 12.h,
                    //         ),
                    //         Container(
                    //           child: Row(
                    //             mainAxisAlignment:
                    //                 MainAxisAlignment.spaceBetween,
                    //             children: [
                    //               Text(
                    //                 "The 40 rules of love",
                    //                 style: TextStyle(
                    //                   fontFamily: globalfontfamily,
                    //                   color: Color.fromRGBO(0, 0, 0, 1),
                    //                   fontSize: 16.sp,
                    //                   fontWeight: FontWeight.w400,
                    //                 ),
                    //               ),
                    //               Image.asset("assets/images/scan.png")
                    //             ],
                    //           ),
                    //         ),
                    //         SizedBox(
                    //           height: 12.h,
                    //         ),
                    //         Container(
                    //           height: 1,
                    //           color: Color.fromRGBO(198, 198, 200, 1),
                    //         ),
                    //         SizedBox(
                    //           height: 16.h,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Invite readers",
                          style: TextStyle(
                            fontFamily: globalfontfamily,
                            color: Color.fromRGBO(0, 0, 0, 1),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "This helps us better match make",
                          style: TextStyle(
                            fontFamily: globalfontfamily,
                            color: Color.fromRGBO(0, 0, 0, 1),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 12.h,
                    ),
                    Container(
                      // height: 143.h,
                      width: 342.w,
                      color: Color.fromRGBO(249, 249, 249, 1),
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 20.0.w,
                          right: 20.0.w,
                          top: 16.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset("assets/images/whatsapp.png"),
                                      SizedBox(
                                        width: 12.h,
                                      ),
                                      Text(
                                        "Whatsapp",
                                        style: TextStyle(
                                          fontFamily: globalfontfamily,
                                          color:
                                              Color.fromRGBO(75, 200, 118, 1),
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Image.asset(
                                    "assets/images/frd.png",
                                    color: Color.fromRGBO(75, 200, 118, 1),
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
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset("assets/images/x.png"),
                                      SizedBox(
                                        width: 12.h,
                                      ),
                                      Text(
                                        "Twitter",
                                        style: TextStyle(
                                          fontFamily: globalfontfamily,
                                          color: Color.fromRGBO(0, 0, 0, 1),
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Image.asset(
                                    "assets/images/frd.png",
                                    color: Color.fromRGBO(0, 0, 0, 1),
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
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset("assets/images/inst.png"),
                                      SizedBox(
                                        width: 12.h,
                                      ),
                                      Text(
                                        "Instagram",
                                        style: TextStyle(
                                          fontFamily: globalfontfamily,
                                          color: Color.fromRGBO(242, 68, 65, 1),
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Image.asset(
                                    "assets/images/frd.png",
                                    color: Color.fromRGBO(242, 68, 65, 1),
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
                              height: 16.h,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),

                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 12.0.w),
                        child: ElevatedButton(
                            onPressed: () {
                              sp.userSignOut();
                              nextScreenReplace(
                                  context, const OnBoradingScreen());
                            },
                            child: const Text("SIGNOUT",
                                style: TextStyle(
                                  color: Colors.black,
                                ))),
                      ),
                    ),

                    SizedBox(
                      height: 15.h,
                    ),
                    // Container(
                    //   width: 342.w,
                    //   color: Color.fromRGBO(249, 249, 249, 1),
                    //   child: Padding(
                    //     padding: EdgeInsets.only(
                    //         left: 20.0.w, right: 20.0.w, top: 16.h, bottom: 16.h),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: [
                    //         Text(
                    //           "Mumbai",
                    //           style: TextStyle(
                    //             fontFamily: globalfontfamily,
                    //             color: Color.fromRGBO(0, 0, 0, 1),
                    //             fontSize: 16.sp,
                    //             fontWeight: FontWeight.w300,
                    //           ),
                    //         ),
                    //         Image.asset("assets/images/loc.png")
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 55.h,
                    // ),
                    // Container(
                    //   height: 43.h,
                    //   width: 339.w,
                    //   decoration: BoxDecoration(
                    //     color: Color.fromRGBO(85, 163, 255, 1),
                    //     borderRadius: BorderRadius.circular(22.r),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Colors.black.withOpacity(0.4),
                    //         spreadRadius: 0,
                    //         blurRadius: 4,
                    //         offset: Offset(0, 4),
                    //       ),
                    //     ],
                    //   ),
                    //   child: Center(
                    //       child: Row(
                    //     children: [
                    //       SizedBox(
                    //         width: 78.5.w,
                    //       ),
                    //       Text(
                    //         "Add books to your shelf",
                    //         style: TextStyle(
                    //             fontFamily: globalfontfamily,
                    //             color: Colors.white,
                    //             fontSize: 16.sp,
                    //             fontWeight: FontWeight.w600),
                    //       ),
                    //       SizedBox(
                    //         width: 46.5.w,
                    //       ),
                    //       Image.asset("assets/images/icarr.png")
                    //     ],
                    //   )),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountBookwidget extends StatefulWidget {
  final Book book;
  const AccountBookwidget({
    super.key,
    required this.book,
  });

  @override
  State<AccountBookwidget> createState() => _AccountBookwidgetState();
}

class _AccountBookwidgetState extends State<AccountBookwidget> {
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
                    Image.asset("assets/images/cover.png"),
                    Padding(
                      padding: EdgeInsets.only(left: 12.0.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "By: ",
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
                                      widget.book.userimage,
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
                                "${widget.book.username}, ${widget.book.userLocation}",
                                style: TextStyle(
                                  fontFamily: globalfontfamily,
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "${widget.book.bookName}",
                            style: TextStyle(
                              fontFamily: globalfontfamily,
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
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
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      isloading = true;
                    });

                    // await saveDataToFirestore(
                    //   bookid: widget.book.bookId,
                    //   bookname: widget.book.bookName,
                    //   authorname: widget.book.authorName,
                    //   imgcover: widget.book.imageCover,
                    //   username: widget.book.username,
                    //   userimage: widget.book.userimage,
                    //   useruid: widget.book.userUid,
                    //   userlocation: widget.book.userLocation,
                    //   userlat: widget.book.userLat,
                    //   userlong: widget.book.userLong,
                    //   requestusername: userglobalData!.username,
                    //   requestuserimage: userglobalData!.imageurl,
                    //   requestuseruid: userglobalData!.uid,
                    //   requestuserlocation: userglobalData!.locationname,
                    //   requestuserlat: userglobalData!.userlat,
                    //   requestuserlong: userglobalData!.userlong,
                    // );

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
      re}) async {
    final DocumentReference r = FirebaseFirestore.instance
        .collection("users")
        .doc(useruid)
        .collection("RequestedBooks")
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
      "requestusername": requestusername,
      "requestuserimage": requestuserimage,
      "requestuseruid": requestuseruid,
      "requestuserlocation": requestuserlocation,
      "requestuserlat": requestuserlat,
      "requestuserlong": requestuserlong,
    });

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

class RecievedBookwidget extends StatefulWidget {
  final RecievedBook book;
  const RecievedBookwidget({
    super.key,
    required this.book,
  });

  @override
  State<RecievedBookwidget> createState() => _RecievedBookwidgetState();
}

class _RecievedBookwidgetState extends State<RecievedBookwidget> {
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
                    Image.network(widget.book.imageCover),
                    Padding(
                      padding: EdgeInsets.only(left: 12.0.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Borrow from: ",
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
                                      widget.book.userimage,
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
                                "${widget.book.username}, ${widget.book.userLocation}",
                                style: TextStyle(
                                  fontFamily: globalfontfamily,
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "${widget.book.bookName}",
                            style: TextStyle(
                              fontFamily: globalfontfamily,
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
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
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      isloading = true;
                    });

                    // await saveDataToFirestore(
                    //   bookid: widget.book.bookId,
                    //   bookname: widget.book.bookName,
                    //   authorname: widget.book.authorName,
                    //   imgcover: widget.book.imageCover,
                    //   username: widget.book.username,
                    //   userimage: widget.book.userimage,
                    //   useruid: widget.book.userUid,
                    //   userlocation: widget.book.userLocation,
                    //   userlat: widget.book.userLat,
                    //   userlong: widget.book.userLong,
                    //   rentedusername: widget.book.requestusername,
                    //   renteduserimage: widget.book.requestuserimage,
                    //   renteduseruid: widget.book.requestuseruid,
                    //   renteduserlocation: widget.book.requestuserlocation,
                    //   rentedtuserlat: widget.book.requestuserlat,
                    //   renteduserlong: widget.book.requestuserlong,
                    // );

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
}

class RentedBookWidget extends StatefulWidget {
  final RentedBook book;
  const RentedBookWidget({
    super.key,
    required this.book,
  });

  @override
  State<RentedBookWidget> createState() => _RentedBookWidgetState();
}

class _RentedBookWidgetState extends State<RentedBookWidget> {
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
                    Image.network(widget.book.imageCover),
                    Padding(
                      padding: EdgeInsets.only(left: 12.0.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "rented to: ",
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
                                      widget.book.renteduserimage,
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
                                "${widget.book.rentedusername}, ${widget.book.renteduserlocation}",
                                style: TextStyle(
                                  fontFamily: globalfontfamily,
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "${widget.book.bookName}",
                            style: TextStyle(
                              fontFamily: globalfontfamily,
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
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
                GestureDetector(
                  onTap: () async {
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
                      rentedusername: widget.book.rentedusername,
                      renteduserimage: widget.book.renteduserimage,
                      renteduseruid: widget.book.renteduseruid,
                      renteduserlocation: widget.book.renteduserlocation,
                      renteduserlat: widget.book.renteduserlat,
                      renteduserlong: widget.book.renteduserlong,
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
      required String rentedusername,
      required String renteduserimage,
      required String renteduseruid,
      required String renteduserlocation,
      required double renteduserlat,
      required double renteduserlong,
      re}) async {
    final DocumentReference r = FirebaseFirestore.instance
        .collection("users")
        .doc(useruid)
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
    });

    await FirebaseFirestore.instance
        .collection("Books")
        .doc(widget.book.bookId)
        .update({
      "isrented": false,
    });

    final DocumentReference dl = FirebaseFirestore.instance
        .collection("users")
        .doc(useruid)
        .collection("RentedBooks")
        .doc(bookid);

    await dl.delete();

    final DocumentReference del = FirebaseFirestore.instance
        .collection("users")
        .doc(renteduseruid)
        .collection("RecievedBooks")
        .doc(bookid);

    await del.delete();

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
