import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openbook/Models/recieved_book_model.dart';
import 'package:openbook/utils/globalvar.dart';

import '../Screens/bookdetails.dart';
import '../Widgets/widgets.dart';

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
    String userNameLoc = "${widget.book.username}, ${widget.book.userLocation}";
    userNameLoc = userNameLoc.length <= 44 ? userNameLoc : "${userNameLoc.substring(0, 41)}...";
    return GestureDetector(
      onTap: () {
        nextScreen(context, BookDetails(book: widget.book.convertToBook()));
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50.h, width: 50.w, child: Image.network(widget.book.imageCover)),
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
                                color: const Color.fromRGBO(0, 0, 0, 1),
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                            SizedBox(
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
                              userNameLoc,
                              // "${widget.book.username}, ${widget.book.userLocation}",
                              style: TextStyle(
                                fontFamily: globalfontfamily,
                                color: const Color.fromRGBO(0, 0, 0, 1),
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 180.w,
                          child: Text(
                            widget.book.bookName,
                            style: TextStyle(
                              fontFamily: globalfontfamily,
                              color: const Color.fromRGBO(0, 0, 0, 1),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Text(
                          "Author: ${widget.book.authorName}",
                          style: TextStyle(
                            fontFamily: globalfontfamily,
                            color: const Color.fromRGBO(0, 0, 0, 1),
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
                color: const Color.fromRGBO(198, 198, 200, 1),
              ),
              SizedBox(
                height: 12.h,
              ),
            ],
          ),
          SizedBox(
            height: 12.h,
          ),
          Container(
            height: 1,
            color: const Color.fromRGBO(198, 198, 200, 1),
          ),
          SizedBox(
            height: 12.h,
          ),
        ],
      ),
    );
  }
}
