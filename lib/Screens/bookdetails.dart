import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openbook/utils/globalvar.dart';

import '../Models/book_model.dart';

class BookDetails extends StatefulWidget {
  final Book book;
  const BookDetails({super.key, required this.book});

  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(249, 249, 249, 1),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(10.w, 5.h, 10.w, 30.h),
              height: screenHeight! * 0.40,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      Text(
                        "By : ${widget.book.username}",
                        style: TextStyle(
                          fontFamily: globalfontfamily,
                          fontWeight: FontWeight.w300,
                          fontSize: 10.sp,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Center(
                    child: Card(
                      elevation: 25.0,
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        widget.book.imageCover,
                        fit: BoxFit.fill,
                        height: 300.h,
                        width: 200.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                  height: screenHeight! * 0.509,
                  width: screenWidth! * 0.95,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32.r),
                      topRight: Radius.circular(32.r),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          widget.book.bookName,
                          style: TextStyle(fontFamily: globalfontfamily, fontWeight: FontWeight.w800, fontSize: 26.sp),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          widget.book.authorName,
                          style: TextStyle(fontFamily: globalfontfamily, fontWeight: FontWeight.w500, fontSize: 20.sp),
                        ),
                        SizedBox(height: 15.h),
                        Text(
                          widget.book.bookdesc,
                          style: TextStyle(
                            fontFamily: globalfontfamily,
                            fontWeight: FontWeight.w300,
                            fontSize: 13.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
