import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openbook/Models/book_model.dart';
import 'package:openbook/utils/global_data.dart';
import 'package:openbook/utils/globalvar.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';

import '../Screens/bookdetails.dart';
import '../Widgets/widgets.dart';

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
    return GestureDetector(
      onTap: () {
        nextScreen(context, BookDetails(book: widget.book));
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
                      "By: ",
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
                  style: TextStyle(fontFamily: globalfontfamily, fontSize: 12.sp, fontWeight: FontWeight.w500),
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
                      showSnackbar(context, Colors.blue, '${widget.book.bookName} deleted Successfully !');
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
                    },
                    child: isloading
                        ? SizedBox(height: 19.h, width: 19.w, child: const CircularProgressIndicator())
                        : SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const Icon(Icons.delete, color: Colors.red),
                          ),
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
      message: "There is no Task For Delete!\n Try adding some and then try to delete it!",
      buttonText: "Okay",
      onTapDismiss: () async {
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.success,
    );
  }
}
