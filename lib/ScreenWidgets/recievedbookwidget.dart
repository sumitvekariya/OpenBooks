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
    return GestureDetector(
      onTap: () {
        nextScreen(context, BookDetails(book: widget.book.convertToBook()));
      },
      child: Row(
        children: [
          Image.network(widget.book.imageCover, fit: BoxFit.cover, height: 60.h, width: 40.w),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Borrow from: ",
                      style: TextStyle(fontFamily: globalfontfamily, fontSize: 8.sp, fontWeight: FontWeight.w200),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: Image.network(
                            widget.book.recieveduserimage,
                            fit: BoxFit.cover,
                          ).image,
                          radius: 4.r),
                    ),
                    Expanded(
                      child: Text(
                        " ${widget.book.recievedusername}, ${widget.book.recieveduserlocation}",
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: TextStyle(fontFamily: globalfontfamily, fontSize: 8.sp, fontWeight: FontWeight.w200),
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.book.bookName,
                  style: TextStyle(fontFamily: globalfontfamily, fontSize: 16.sp, fontWeight: FontWeight.w400),
                ),
                Text(
                  "Author: ${widget.book.authorName}",
                  style: TextStyle(fontFamily: globalfontfamily, fontSize: 12.sp, fontWeight: FontWeight.w200),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
