import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:openbook/utils/globalvar.dart';

import 'package:openbook/Models/recieved_book_model.dart';

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
                    Container(
                        height: 50.h,
                        width: 50.w,
                        child: Image.network(widget.book.imageCover)),
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
