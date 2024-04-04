import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openbook/firebase_options.dart';

import 'package:openbook/utils/globalvar.dart';

import 'package:openbook/TwitterAuth/provider/internet_provider.dart';
import 'package:openbook/TwitterAuth/provider/sign_in_provider.dart';
import 'package:openbook/TwitterAuth/screens/flashscreen.dart';

import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: ((context) => SignInProvider()),
              ),
              ChangeNotifierProvider(
                create: ((context) => InternetProvider()),
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'OpenBooks',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
              ),
              home: Builder(
                builder: (context) {
                  screenHeight = MediaQuery.of(context).size.height;
                  screenWidth = MediaQuery.of(context).size.width;
                  return AnimatedSplashScreen(
                    splashIconSize: 800,
                    splashTransition: SplashTransition.fadeTransition,
                    backgroundColor: Colors.black,
                    splash: Container(
                      margin: const EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: Image.asset(
                        "assets/images/book.png",
                        height: 800,
                        width: 800,
                      ),
                    ),
                    nextScreen: const FlashScreen(),
                  );
                },
              ),
            ),
          );
        });
  }
}
