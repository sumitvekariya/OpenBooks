import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openbook/Models/book_model.dart';
import 'package:openbook/utils/globalvar.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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
    String userNameLoc = "${widget.book.username}, ${widget.book.userLocation}";
    userNameLoc = userNameLoc.length <= 44 ? userNameLoc : "${userNameLoc.substring(0, 41)}...";

    return Column(
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
                            "By: ",
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
                          SizedBox(
                            width: 180.w,
                            child: Text(
                              "${widget.book.username}, ${widget.book.userLocation}",
                              style: TextStyle(
                                fontFamily: globalfontfamily,
                                color: const Color.fromRGBO(0, 0, 0, 1),
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 200.w,
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
            TapBounceContainer(
              child: GestureDetector(
                onTap: () async {
                  showTopSnackBar(
                    Overlay.of(context),
                    CustomSnackBar.error(
                      message: '${widget.book.bookName} deleted Successfully !',
                    ),
                  );
                  setState(() {
                    isloading = true;
                  });

                  final DocumentReference dl = FirebaseFirestore.instance.collection("users").doc(widget.book.userUid).collection("Books").doc(widget.book.bookId);

                  await dl.delete();

                  final DocumentReference del = FirebaseFirestore.instance.collection("Books").doc(widget.book.bookId);

                  await del.delete();

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
                    : SizedBox(
                        height: 24.h,
                        width: 24.w,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
              ),
            )
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
    );
  }

  Future warningNoTask(BuildContext context) async {
    return PanaraInfoDialog.showAnimatedGrow(
      noImage: true,
      context,
      title: "Normal",
      message: "There is no Task For Delete!\n Try adding some and then try to delete it!",
      buttonText: "Okay",
      onTapDismiss: () async {
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.success,
    );
  }
}
