import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openbook/utils/globalvar.dart';
import 'package:openbook/Screens/homepage.dart';
import 'package:openbook/Widgets/widgets.dart';

class AddBooks extends StatefulWidget {
  const AddBooks({super.key});

  @override
  State<AddBooks> createState() => _AddBooksState();
}

class _AddBooksState extends State<AddBooks> {
  @override
  Widget build(BuildContext context) {
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
                      "Add books",
                      style: TextStyle(
                          fontFamily: globalfontfamily,
                          color: Colors.black,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w600),
                    ),
                    Container(
                      width: 300.w,
                      child: Text(
                        "Every book lying on your shelf is locked value. Not only that someone looking for the same book around you could use the book, but also be your friend.\n\n It is mandatory to add 1 book at-least. \nScan to add books to your shelf.",
                        style: TextStyle(
                            fontFamily: globalfontfamily,
                            color: Colors.black,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w300),
                      ),
                    ),
                  ],
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
                                  Text(
                                    "The Book of Mirad",
                                    style: TextStyle(
                                      fontFamily: globalfontfamily,
                                      color: Color.fromRGBO(0, 0, 0, 1),
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Image.asset("assets/images/tick.png")
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                      "assets/images/barcode-scanner.png")
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 16.h,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 435.h,
                    ),
                    GestureDetector(
                      onTap: () {
                        nextScreen(context, HomePage());
                      },
                      child: Container(
                        height: 43.h,
                        width: 339.w,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(85, 163, 255, 1),
                          borderRadius: BorderRadius.circular(22.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              spreadRadius: 0,
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                            child: Row(
                          children: [
                            SizedBox(
                              width: 78.5.w,
                            ),
                            Text(
                              "Finish setup & start exploring",
                              style: TextStyle(
                                  fontFamily: globalfontfamily,
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              width: 46.5.w,
                            ),
                          ],
                        )),
                      ),
                    ),
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
