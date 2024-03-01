import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:openbook/Screens/homepage.dart';
import 'package:openbook/Screens/onboardingscreen.dart';
import 'package:openbook/Screens/setupaccount.dart';

import 'package:openbook/Widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:openbook/Models/user_data_models.dart';
import 'package:openbook/TwitterAuth/provider/sign_in_provider.dart';

import 'package:openbook/utils/global_data.dart';

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
    Timer(const Duration(seconds: 1), () async {
      if (sp.isSignedIn == true) {
        Future.delayed(Duration(seconds: 1), () async {
          String? userUid = FirebaseAuth.instance.currentUser?.uid;
          print(userUid);
          await getUserData(userUid!);

          if (userglobalData!.fillDetails == true) {
            nextScreenpushandremove(context, HomePage());
          } else {
            nextScreenpushandremove(context, SetupupAccount());
          }

          // nextScreen(context, HomeScreen());
        });
      } else {
        nextScreenpushandremove(context, OnBoradingScreen());
      }
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
