import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openbook/utils/api_client.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Models/book_model.dart';
import '../TwitterAuth/provider/sign_in_provider.dart';
import '../utils/globalvar.dart';

class BookDetails extends StatefulWidget {
  final Book book;

  const BookDetails({super.key, required this.book});

  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  String? token;

  fetchToken() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    final t = s.getString('token');
    setState(() {
      token = t;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(249, 249, 249, 1),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 20.h),
              height: 350.h,
              child: Column(
                children: [
                  // Row(
                  //   children: [
                  //     const Spacer(),
                  //     Text(
                  //       "owned by : ${widget.book.username}",
                  //       style: TextStyle(
                  //         fontFamily: globalfontfamily,
                  //         fontWeight: FontWeight.w300,
                  //         fontSize: 10.sp,
                  //         color: Colors.blue[800],
                  //       ),
                  //     ),
                  //   ],
                  // ),
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
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                height: MediaQuery.of(context).size.height - 350.h,
                //- kToolbarHeight,
                width: 370.w,
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
                        style: TextStyle(
                            fontFamily: globalfontfamily,
                            fontWeight: FontWeight.w800,
                            fontSize: 26.sp),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        widget.book.authorName,
                        style: TextStyle(
                            fontFamily: globalfontfamily,
                            fontWeight: FontWeight.w500,
                            fontSize: 20.sp),
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
                      SizedBox(height: 15.h),
                      Row(
                        children: [
                          Text(
                            "Owners:",
                            style: TextStyle(
                              fontFamily: globalfontfamily,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      token != null
                          ? FutureBuilder(
                              future: ApiClient()
                                  .getBookDetails(token!, widget.book.bookId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const AspectRatio(
                                      aspectRatio: 1,
                                      child: Center(
                                          child: CircularProgressIndicator()));
                                }
                                if (snapshot.hasError) {
                                  return Container();
                                }
                                log(snapshot.data.toString());
                                final data = snapshot.data;
                                final userData = data?.data;
                                if (userData.containsKey('data')) {
                                  Map<String, dynamic> loginData =
                                      userData['data'];
                                  log("Logged in user's data: $loginData");
                                }
                                return buildUsers(userData['data']['users']);
                              },
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildUsers(users) {
    return Container(
      height: 200.h,
      // decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.grey[100]),
      // padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        itemCount: users.length,
        // separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
            margin: EdgeInsets.symmetric(vertical: 1.h),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 16.w,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: users[index]['userData']['profilePicture']
                              .isNotEmpty
                          ? users[index]['userData']['profilePicture']
                          : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                      width: ScreenUtil().screenWidth * 0.2,
                      height: ScreenUtil().screenWidth * 0.2,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Image.network(
                        'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png', // Placeholder image
                        width: ScreenUtil().screenWidth * 0.2,
                        height: ScreenUtil().screenWidth * 0.2,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        users[index]['userData']['name'],
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: TextStyle(
                            fontFamily: globalfontfamily,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        users[index]['userData']['username'],
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: TextStyle(
                            fontFamily: globalfontfamily,
                            color: Colors.grey,
                            fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        if (!await launchUrl(Uri.parse(
                            "https://translator.shyft.to/address/${users[index]['mintAddress']}?cluster=devnet&compressed=true" ??
                                ""))) {
                          throw Exception(
                              'Could not launch ${users[index]['mintAddress']} this NFT');
                        }
                      } catch (e) {
                        // Handle any exception
                        print('Error: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white30, elevation: 1),
                    icon: Image.asset("assets/images/solana.png",
                        height: 25.h, width: 25.w),
                    label: const Text(
                      "NFT",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
