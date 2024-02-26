import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:openbook/homepage.dart';
import 'package:openbook/setupaccount.dart';
import 'package:openbook/twitterauth/Models/user_data_models.dart';
import 'package:openbook/twitterauth/provider/internet_provider.dart';
import 'package:openbook/twitterauth/provider/sign_in_provider.dart';
import 'package:openbook/twitterauth/screens/home_screen.dart';
// import 'package:wetime/screens/phoneauth_screen.dart';

import 'package:openbook/twitterauth/utils/config.dart';
import 'package:openbook/twitterauth/utils/global_data.dart';
import 'package:openbook/twitterauth/utils/next_screen.dart';
import 'package:openbook/twitterauth/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  final RoundedLoadingButtonController googleController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController facebookController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController twitterController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController phoneController =
      RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Padding(
        padding:
            const EdgeInsets.only(left: 40, right: 40, top: 90, bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image(
                    image: AssetImage(Config.app_icon),
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text("Welcome ",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
                  const SizedBox(
                    height: 10,
                  ),
                  // Text(
                  //   "Learn Authentication with Provider",
                  //   style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  // )
                ],
              ),
            ),

            // roundedbutton
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundedLoadingButton(
                  onPressed: () {
                    // handleGoogleSignIn();
                  },
                  controller: googleController,
                  successColor: Colors.red,
                  width: MediaQuery.of(context).size.width * 0.80,
                  elevation: 0,
                  borderRadius: 25,
                  color: Colors.red,
                  child: Wrap(
                    children: const [
                      Icon(
                        FontAwesomeIcons.google,
                        size: 20,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text("Sign in with Google",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                // // facebook login button
                // RoundedLoadingButton(
                //   onPressed: () {
                //     handleFacebookAuth();
                //   },
                //   controller: facebookController,
                //   successColor: Colors.blue,
                //   width: MediaQuery.of(context).size.width * 0.80,
                //   elevation: 0,
                //   borderRadius: 25,
                //   color: Colors.blue,
                //   child: Wrap(
                //     children: const [
                //       Icon(
                //         FontAwesomeIcons.facebook,
                //         size: 20,
                //         color: Colors.white,
                //       ),
                //       SizedBox(
                //         width: 15,
                //       ),
                //       Text("Sign in with Facebook",
                //           style: TextStyle(
                //               color: Colors.white,
                //               fontSize: 15,
                //               fontWeight: FontWeight.w500)),
                //     ],
                //   ),
                // ),
                const SizedBox(
                  height: 10,
                ),

                // twitter loading button
                RoundedLoadingButton(
                  onPressed: () {
                    handleTwitterAuth();
                  },
                  controller: twitterController,
                  successColor: Colors.lightBlue,
                  width: MediaQuery.of(context).size.width * 0.80,
                  elevation: 0,
                  borderRadius: 25,
                  color: Colors.lightBlue,
                  child: Wrap(
                    children: const [
                      Icon(
                        FontAwesomeIcons.twitter,
                        size: 20,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text("Continue with Twitter",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),

                // phoneAuth loading button
                // RoundedLoadingButton(
                //   onPressed: () {
                //     nextScreenReplace(context, const PhoneAuthScreen());
                //     phoneController.reset();
                //   },
                //   controller: phoneController,
                //   successColor: Colors.black,
                //   width: MediaQuery.of(context).size.width * 0.80,
                //   elevation: 0,
                //   borderRadius: 25,
                //   color: Colors.black,
                //   child: Wrap(
                //     children: const [
                //       Icon(
                //         FontAwesomeIcons.phone,
                //         size: 20,
                //         color: Colors.white,
                //       ),
                //       SizedBox(
                //         width: 15,
                //       ),
                //       Text("Sign in with Phone",
                //           style: TextStyle(
                //               color: Colors.white,
                //               fontSize: 15,
                //               fontWeight: FontWeight.w500)),
                //     ],
                //   ),
                // ),
              ],
            )
          ],
        ),
      )),
    );
  }

  // handling twitter auth
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

  // // handling google sigin in
  // Future handleGoogleSignIn() async {
  //   final sp = context.read<SignInProvider>();
  //   final ip = context.read<InternetProvider>();
  //   await ip.checkInternetConnection();

  //   if (ip.hasInternet == false) {
  //     openSnackbar(context, "Check your Internet connection", Colors.red);
  //     googleController.reset();
  //   } else {
  //     await sp.signInWithGoogle().then((value) {
  //       if (sp.hasError == true) {
  //         openSnackbar(context, sp.errorCode.toString(), Colors.red);
  //         googleController.reset();
  //       } else {
  //         // checking whether user exists or not
  //         sp.checkUserExists().then((value) async {
  //           if (value == true) {
  //             // user exists
  //             await sp.getUserDataFromFirestore(sp.uid).then((value) => sp
  //                 .saveDataToSharedPreferences()
  //                 .then((value) => sp.setSignIn().then((value) {
  //                       googleController.success();
  //                       handleAfterSignIn();
  //                     })));
  //           } else {
  //             // user does not exist
  //             sp.saveDataToFirestore().then((value) => sp
  //                 .saveDataToSharedPreferences()
  //                 .then((value) => sp.setSignIn().then((value) {
  //                       googleController.success();
  //                       handleAfterSignIn();
  //                     })));
  //           }
  //         });
  //       }
  //     });
  //   }
  // }

  // handling facebookauth
  // handling google sigin in
  // Future handleFacebookAuth() async {
  //   final sp = context.read<SignInProvider>();
  //   final ip = context.read<InternetProvider>();
  //   await ip.checkInternetConnection();

  //   if (ip.hasInternet == false) {
  //     openSnackbar(context, "Check your Internet connection", Colors.red);
  //     facebookController.reset();
  //   } else {
  //     await sp.signInWithFacebook().then((value) {
  //       if (sp.hasError == true) {
  //         openSnackbar(context, sp.errorCode.toString(), Colors.red);
  //         facebookController.reset();
  //       } else {
  //         // checking whether user exists or not
  //         sp.checkUserExists().then((value) async {
  //           if (value == true) {
  //             // user exists
  //             await sp.getUserDataFromFirestore(sp.uid).then((value) => sp
  //                 .saveDataToSharedPreferences()
  //                 .then((value) => sp.setSignIn().then((value) {
  //                       facebookController.success();
  //                       handleAfterSignIn();
  //                     })));
  //           } else {
  //             // user does not exist
  //             sp.saveDataToFirestore().then((value) => sp
  //                 .saveDataToSharedPreferences()
  //                 .then((value) => sp.setSignIn().then((value) {
  //                       facebookController.success();
  //                       handleAfterSignIn();
  //                     })));
  //           }
  //         });
  //       }
  //     });
  //   }
  // }

  // handle after signin
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
