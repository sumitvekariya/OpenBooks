import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:openbook/Models/user_data_models.dart';
import 'package:openbook/Screens/demologinscreen.dart';
import 'package:openbook/Screens/homepage.dart';
import 'package:openbook/Screens/setupaccount.dart';
import 'package:openbook/TwitterAuth/provider/internet_provider.dart';
import 'package:openbook/TwitterAuth/provider/sign_in_provider.dart';
import 'package:openbook/Widgets/widgets.dart';
import 'package:openbook/utils/global_data.dart';
import 'package:openbook/utils/globalvar.dart';
import 'package:openbook/utils/snack_bar.dart';
import 'package:provider/provider.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  bool isTwitterLoading = false;
  bool showDemoLoginButton = false;

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

  @override
  void initState() {
    checkDemoButton();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 160.h,
              ),
              SizedBox(
                  height: 265.h,
                  width: 258.w,
                  child: SvgPicture.asset("assets/images/grp1.svg")),
              SizedBox(
                height: 194.h,
              ),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    isTwitterLoading = true;
                  });
                  await handleTwitterAuth();
                },
                child: Container(
                  height: 43.h,
                  width: 339.w,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(85, 163, 255, 1),
                    borderRadius: BorderRadius.circular(22.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                      child: isTwitterLoading
                          ? Center(
                              child: SizedBox(
                                height: 18.h,
                                width: 18.w,
                                child: const CircularProgressIndicator(
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
              showDemoLoginButton
                  ? Padding(
                      padding: EdgeInsets.only(top: 20.h),
                      child: InkWell(
                        onTap: () async {
                          nextScreen(
                            context,
                            DemoLoginScreen(
                                handleAfterSignIn: handleAfterSignIn),
                          );
                        },
                        borderRadius: BorderRadius.circular(22.r),
                        child: Container(
                          height: 43.h,
                          width: 339.w,
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(22.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                spreadRadius: 0,
                                blurRadius: 4,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "Sign in as Demo user",
                              style: TextStyle(
                                  fontFamily: globalfontfamily,
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
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
    } else {
      await sp.firebasesignInWithTwitter().then((value) {
        if (sp.hasError == true) {
          setState(() {
            isTwitterLoading = false;
          });
          openSnackbar(context, sp.errorCode.toString(), Colors.red);
        } else {
          // checking whether user exists or not
          sp.checkUserExists().then((value) async {
            if (value == true) {
              // user exists
              await sp.getUserDataFromFirestore(sp.uid).then((value) async => sp
                  .saveDataToSharedPreferences()
                  .then((value) async => sp.setSignIn().then((value) async {
                        await handleAfterSignIn();
                      })));
            } else {
              // user does not exist
              sp.saveDataToFirestore().then((value) async => sp
                  .saveDataToSharedPreferences()
                  .then((value) async => sp.setSignIn().then((value) async {
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
    String? currentUserUID = FirebaseAuth.instance.currentUser?.uid;
    await getUserData(currentUserUID!);

    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      print("user globalData!.fillDetails : ${userglobalData!.fillDetails} ");
      if (userglobalData!.fillDetails == true) {
        nextScreenReplace(context, const HomePage());
      } else {
        nextScreenReplace(context, const SetupAccount());
      }
    });
  }

  checkDemoButton() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentSnapshot snapshot =
        await firestore.collection('config').doc('showDemoButton').get();

    if (snapshot.exists) {
      showDemoLoginButton = snapshot['showDemoButton'];
      setState(() {});
    }
  }
}
