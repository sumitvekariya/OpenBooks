import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openbook/Models/rquest_book_model.dart';
import 'package:openbook/utils/globalvar.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';

import '../Screens/bookdetails.dart';
import '../Widgets/widgets.dart';
import '../utils/global_data.dart';

class RequestBookwidget extends StatefulWidget {
  final RequestedBook book;

  const RequestBookwidget({
    super.key,
    required this.book,
  });

  @override
  State<RequestBookwidget> createState() => _RequestBookwidgetState();
}

class _RequestBookwidgetState extends State<RequestBookwidget> {
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(context, BookDetails(book: widget.book.convertToBook()));
      },
      child: Row(
        children: [
          Image.network(widget.book.imageCover,
              fit: BoxFit.cover, height: 60.h, width: 40.w),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "requested by: ",
                      style: TextStyle(
                        fontFamily: globalfontfamily,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w200,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: Image.network(
                            widget.book.userimage,
                            fit: BoxFit.cover,
                          ).image,
                          radius: 4.r),
                    ),
                    Expanded(
                      child: Text(
                        " ${widget.book.username}, ${widget.book.userLocation}",
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: TextStyle(
                          fontFamily: globalfontfamily,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w200,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.book.bookName,
                  style: TextStyle(
                      fontFamily: globalfontfamily,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  "Author: ${widget.book.authorName}",
                  style: TextStyle(
                    fontFamily: globalfontfamily,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w200,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          userglobalData?.uid != widget.book.userUid
              ? Container()
              : TapBounceContainer(
                  child: GestureDetector(
                    onTap: () async {
                      showSnackbar(context, Colors.blue,
                          'Great! ${widget.book.bookName} successfully rented to ${widget.book.requestusername}');

                      setState(() {
                        isloading = true;
                      });

                      print("Bookname :  ${widget.book.bookName}");

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
                        rentedusername: widget.book.requestusername,
                        renteduserimage: widget.book.requestuserimage,
                        renteduseruid: widget.book.requestuseruid,
                        renteduserlocation: widget.book.requestuserlocation,
                        rentedtuserlat: widget.book.requestuserlat,
                        renteduserlong: widget.book.requestuserlong,
                        bookdesc: widget.book.bookdesc,
                      );

                      setState(() {
                        isloading = false;
                      });
                      // warningNoTask(context);
                    },
                    child: isloading
                        ? SizedBox(
                            height: 19.h,
                            width: 19.w,
                            child: const CircularProgressIndicator(),
                          )
                        : const Icon(CupertinoIcons.check_mark_circled,
                            color: Colors.blueAccent),
                  ),
                ),
          SizedBox(width: 10.w)
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

  Future saveDataToFirestore({
    required String bookid,
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
    required double rentedtuserlat,
    required double renteduserlong,
    required String bookdesc,
  }) async {
    final DocumentReference r = FirebaseFirestore.instance
        .collection("users")
        .doc(useruid)
        .collection("RentedBooks")
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
      "rentedusername": rentedusername,
      "renteduserimage": renteduserimage,
      "renteduseruid": renteduseruid,
      "renteduserlocation": renteduserlocation,
      "rentedtuserlat": rentedtuserlat,
      "renteduserlong": renteduserlong,
      "bookdesc": bookdesc,
    });

    final DocumentReference br = FirebaseFirestore.instance
        .collection("users")
        .doc(renteduseruid)
        .collection("RecievedBooks")
        .doc(bookid);

    await br.set({
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
      "recievedusername": rentedusername,
      "recieveduserimage": renteduserimage,
      "recieveduseruid": renteduseruid,
      "recieveduserlocation": renteduserlocation,
      "recievedtuserlat": rentedtuserlat,
      "recieveduserlong": renteduserlong,
      "bookdesc": bookdesc,
    });

    final DocumentReference dl = FirebaseFirestore.instance
        .collection("users")
        .doc(useruid)
        .collection("RequestedBooks")
        .doc(bookid);

    await dl.delete();

    print("THis 1 runs");

    final DocumentReference del = FirebaseFirestore.instance
        .collection("users")
        .doc(useruid)
        .collection("Books")
        .doc(bookid);

    await del.delete();

    print("THis 2 runs");

    await FirebaseFirestore.instance.collection("Books").doc(bookid).update({
      "isrented": true,
    });

    print("THis 3 runs");
  }
}
