import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:openbook/homepage.dart';
import 'package:openbook/onboardingscreen.dart';
import 'package:openbook/setupaccount.dart';

import 'package:provider/provider.dart';
import 'package:openbook/twitterauth/Models/user_data_models.dart';
import 'package:openbook/twitterauth/provider/sign_in_provider.dart';
import 'package:openbook/twitterauth/screens/home_screen.dart';
import 'package:openbook/twitterauth/screens/login_screen.dart';
import 'package:openbook/twitterauth/utils/global_data.dart';
import 'package:openbook/twitterauth/utils/next_screen.dart';

class FlashScreen extends StatefulWidget {
  const FlashScreen({super.key});

  @override
  State<FlashScreen> createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen> {
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
    final sp = context.read<SignInProvider>();
    super.initState();
    // create a timer of 2 seconds
    Timer(const Duration(seconds: 3), () async {
      // if (sp.isSignedIn == true) {
      //   // String? currentUserUID = FirebaseAuth.instance.currentUser?.uid;

      //   // CollectionReference usersCollection =
      //   //     FirebaseFirestore.instance.collection('users');
      //   // DocumentReference userDocument = usersCollection.doc(currentUserUID);
      //   // DocumentSnapshot documentSnapshot = await userDocument.get();

      //   // fillDetails = documentSnapshot.get('fillDetails');

      //   // print("the value of fillDetails : ${fillDetails}");

      // }

      if (sp.isSignedIn == true) {
        Future.delayed(Duration(seconds: 1), () async {
          String? userUid = FirebaseAuth.instance.currentUser?.uid;
          print(userUid);
          await getUserData(userUid!);

          if (userglobalData!.fillDetails == true) {
            nextScreen(context, HomePage());
          } else {
            nextScreen(context, SetupupAccount());
          }

          // nextScreen(context, HomeScreen());
        });
      } else {
        nextScreen(context, OnBoradingScreen());
      }

      // sp.isSignedIn == false
      //     ? nextScreen(
      //         context,
      //         WelcomeScreen(
      //           checkpartnercodevalue: 1,
      //         ))
      //     : nextScreen(context, HomeScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: CircularProgressIndicator(
              // color: Color.fromRGBO(234, 192, 42, 1),/

              ),
        ),
      ],
    ));
  }
}
