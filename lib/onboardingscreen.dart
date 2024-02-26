import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:openbook/globalvar.dart';
import 'package:openbook/homepage.dart';
import 'package:openbook/setupaccount.dart';
import 'package:openbook/twitterauth/Models/user_data_models.dart';
import 'package:openbook/twitterauth/provider/internet_provider.dart';
import 'package:openbook/twitterauth/provider/sign_in_provider.dart';
import 'package:openbook/twitterauth/utils/global_data.dart';
import 'package:openbook/twitterauth/utils/snack_bar.dart';
import 'package:openbook/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class OnBoradingScreen extends StatefulWidget {
  const OnBoradingScreen({super.key});

  @override
  State<OnBoradingScreen> createState() => _OnBoradingScreenState();
}

class _OnBoradingScreenState extends State<OnBoradingScreen> {
  bool isloading = false;
  Future<UserData> getUserData(String uid) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentSnapshot userSnapshot =
          await firestore.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        userglobalData = UserData.fromSnapshot(userSnapshot);
        print('uid : ${userglobalData!.uid}');
        print('username: ${userglobalData!.username}');
        print('name: ${userglobalData!.name}');
        print('imageurl: ${userglobalData!.imageurl}');
        print('provider: ${userglobalData!.provider}');
        print('locationname: ${userglobalData!.locationname}');

        return userglobalData!;
      } else {
        print('User document does not exist');
        return UserData("", "", "", "", false, "", "", 0.0, 0.0);
      }
    } catch (e) {
      print('Error retrieving user data: $e');
      return UserData("", "", "", "", false, "", "", 0.0, 0.0);
    }
  }

  final RoundedLoadingButtonController twitterController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController googleController =
      RoundedLoadingButtonController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 160.h,
                ),
                Container(
                    height: 265.h,
                    width: 258.w,
                    child: SvgPicture.asset("assets/images/grp1.svg")),
                SizedBox(
                  height: 194.h,
                ),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      isloading = true;
                    });
                    await handleTwitterAuth();
                    // nextScreen(context, SetupupAccount());
                    // setState(() {
                    //   isloading = false;
                    // });
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
                        child: isloading
                            ? Center(
                                child: Container(
                                  height: 18.h,
                                  width: 18.w,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                children: [
                                  SizedBox(
                                    width: 32.w,
                                  ),
                                  Image.asset(
                                    "assets/images/tw.png",
                                    height: 16.h,
                                    width: 16.w,
                                  ),
                                  SizedBox(
                                    width: 78.w,
                                  ),
                                  Text(
                                    "Login with X",
                                    style: TextStyle(
                                        fontFamily: globalfontfamily,
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              )),
                  ),
                ),
                SizedBox(height: 11.h),
                Text(
                  "Skip and explore books",
                  style: TextStyle(
                      color: Color.fromRGBO(87, 128, 199, 1),
                      fontFamily: globalfontfamily,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future handleTwitterAuth() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      openSnackbar(context, "Check your Internet connection", Colors.red);
      googleController.reset();
    } else {
      await sp.signInWithTwitter().then((value) {
        if (sp.hasError == true) {
          openSnackbar(context, sp.errorCode.toString(), Colors.red);
          twitterController.reset();
        } else {
          // checking whether user exists or not
          sp.checkUserExists().then((value) async {
            if (value == true) {
              // user exists
              await sp.getUserDataFromFirestore(sp.uid).then((value) async => sp
                  .saveDataToSharedPreferences()
                  .then((value) async => sp.setSignIn().then((value) async {
                        twitterController.success();
                        await handleAfterSignIn();
                      })));
            } else {
              // user does not exist
              sp.saveDataToFirestore().then((value) async => sp
                  .saveDataToSharedPreferences()
                  .then((value) async => sp.setSignIn().then((value) async {
                        twitterController.success();
                        await handleAfterSignIn();
                      })));
            }
          });
        }
      });
    }
  }

  Future handleAfterSignIn() async {
    print("Handle runs");
    String? currentUserUID = await FirebaseAuth.instance.currentUser?.uid;
    await getUserData(currentUserUID!);

    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      print("userglobalData!.fillDetails : ${userglobalData!.fillDetails} ");
      if (userglobalData!.fillDetails == true) {
        nextScreenReplace(context, HomePage());
      } else {
        nextScreenReplace(context, SetupupAccount());
      }
    });
  }
}
