import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:openbook/twitterauth/utils/config.dart';
import 'package:random_string/random_string.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twitter_login/twitter_login.dart';

class SignInProvider extends ChangeNotifier {
  // instance of firebaseauth, facebook and google
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FacebookAuth facebookAuth = FacebookAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final twitterLogin = TwitterLogin(
      apiKey: Config.apikey_twitter,
      apiSecretKey: Config.secretkey_twitter,
      redirectURI: "flutter-twitter-login://");

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  //hasError, errorCode, provider,uid, email, name, imageUrl
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _provider;
  String? get provider => _provider;

  String? _uid;
  String? get uid => _uid;

  String? _name;
  String? get name => _name;

  String? _username;
  String? get username => _username;

  String? _email;
  String? get email => _email;

  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  String? _partnercode;
  String? get partnecode => _partnercode;

  bool? _isFilled;
  bool? get isFilled => _isFilled;

  String? _locationname;
  String? get locationname => _locationname;

  SignInProvider() {
    checkSignInUser();
  }

  Future checkSignInUser() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("signed_in") ?? false;
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("signed_in", true);
    _isSignedIn = true;
    notifyListeners();
  }

  // sign in with google
  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      // executing our authentication
      try {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // signing to firebase user instance
        final User userDetails =
            (await firebaseAuth.signInWithCredential(credential)).user!;

        // now save all values

        _name = userDetails.displayName;
        _email = userDetails.email;
        _imageUrl = userDetails.photoURL;
        _provider = "GOOGLE";
        _uid = userDetails.uid;
        _partnercode = "${randomNumeric(6)}";
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode =
                "You already have an account with us. Use correct provider";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in";
            _hasError = true;
            notifyListeners();
            break;
          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  Future<void> thissignInWithTwitter() async {
    TwitterAuthProvider twitterProvider = TwitterAuthProvider();

    if (kIsWeb) {
      await FirebaseAuth.instance.signInWithPopup(twitterProvider);
    } else {
      await FirebaseAuth.instance.signInWithProvider(twitterProvider);
    }
  }

  Future<void> firebasesignInWithTwitter() async {
    try {
      // Trigger Twitter OAuth flow using Firebase
      final twitterAuthProvider = TwitterAuthProvider();
      twitterAuthProvider.setCustomParameters({'force_login': 'true'});

      final authResult =
          await FirebaseAuth.instance.signInWithProvider(twitterAuthProvider);

      // Get user details from the authentication result
      final userDetails = authResult.user;

      // Print or use the user details as needed
      print("authResult.user: $userDetails");
      print("userDetails!.name: ${userDetails!.displayName}");
      print(
          "firebaseAuth.currentUser!.email: ${firebaseAuth.currentUser!.email}");

      // Extract the necessary information
      _username = userDetails.displayName;
      _name = userDetails.displayName;
      _email = firebaseAuth.currentUser!.email ?? "twitter";
      _imageUrl = userDetails.photoURL;
      _uid = userDetails.uid;
      _provider = "TWITTER";
      _isFilled = false;
      _locationname = "location";
      _hasError = false;

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "account-exists-with-different-credential":
          _errorCode =
              "You already have an account with us. Use correct provider";
          _hasError = true;
          notifyListeners();
          break;

        case "null":
          _errorCode = "Some unexpected error while trying to sign in";
          _hasError = true;
          notifyListeners();
          break;
        default:
          _errorCode = e.toString();
          _hasError = true;
          notifyListeners();
      }
    } catch (e) {
      // Handle other exceptions
      print("Error: $e");
      _hasError = true;
      notifyListeners();
    }
  }

  // sign in with twitter
  Future signInWithTwitter() async {
    final authResult = await twitterLogin.loginV2(forceLogin: true);
    if (authResult.status == TwitterLoginStatus.loggedIn) {
      try {
        final credential = TwitterAuthProvider.credential(
            accessToken: authResult.authToken!,
            secret: authResult.authTokenSecret!);
        await firebaseAuth.signInWithCredential(credential);

        String? userUid = await FirebaseAuth.instance.currentUser?.uid;

        print("firebase useruid : ${userUid}");

        final userDetails = authResult.user;

        print("authResult.user : ${authResult.user}");

        print("userDetails!.name:  ${userDetails!.name}");
        print(
            "firebaseAuth.currentUser!.email:   ${firebaseAuth.currentUser!.email}");
        print("userDetails.thumbnailImage: ${userDetails.thumbnailImage}");
        print("userDetails.id.toString(): ${userDetails.id.toString()}");
        // save all the data

        print("userDetails.screenName : ${userDetails.screenName}");

        _username = userDetails.screenName;
        _name = userDetails.name;
        _email = firebaseAuth.currentUser!.email ?? "twitter";
        _imageUrl = userDetails.thumbnailImage;
        _uid = userUid.toString();
        _provider = "TWITTER";
        _isFilled = false;
        _locationname = "location";
        _hasError = false;
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode =
                "You already have an account with us. Use correct provider";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in";
            _hasError = true;
            notifyListeners();
            break;
          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  // // sign in with facebook
  // Future signInWithFacebook() async {
  //   final LoginResult result = await facebookAuth.login();
  //   // getting the profile
  //   final graphResponse = await http.get(Uri.parse(
  //       'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),first_name,last_name,email&access_token=${result.accessToken!.token}'));

  //   final profile = jsonDecode(graphResponse.body);

  //   if (result.status == LoginStatus.success) {
  //     try {
  //       final OAuthCredential credential =
  //           FacebookAuthProvider.credential(result.accessToken!.token);
  //       await firebaseAuth.signInWithCredential(credential);
  //       // saving the values
  //       _name = profile['name'];
  //       _email = profile['email'];
  //       _imageUrl = profile['picture']['data']['url'];
  //       _uid = profile['id'];
  //       _hasError = false;
  //       _provider = "FACEBOOK";
  //       notifyListeners();
  //     } on FirebaseAuthException catch (e) {
  //       switch (e.code) {
  //         case "account-exists-with-different-credential":
  //           _errorCode =
  //               "You already have an account with us. Use correct provider";
  //           _hasError = true;
  //           notifyListeners();
  //           break;

  //         case "null":
  //           _errorCode = "Some unexpected error while trying to sign in";
  //           _hasError = true;
  //           notifyListeners();
  //           break;
  //         default:
  //           _errorCode = e.toString();
  //           _hasError = true;
  //           notifyListeners();
  //       }
  //     }
  //   } else {
  //     _hasError = true;
  //     notifyListeners();
  //   }
  // }

  // ENTRY FOR CLOUDFIRESTORE
  Future getUserDataFromFirestore(uid) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get()
        .then((DocumentSnapshot snapshot) => {
              _uid = snapshot['uid'],
              _username = snapshot['username'],
              _name = snapshot['name'],
              _imageUrl = snapshot['image_url'],
              _isFilled = snapshot['isfilled'],
              _provider = snapshot['provider'],
              _locationname = snapshot['location_name']
            });
  }

  Future saveDataToFirestore() async {
    final DocumentReference r =
        FirebaseFirestore.instance.collection("users").doc(uid);
    await r.set({
      "uid": _uid,
      "username": _username,
      "name": _name,
      "image_url": _imageUrl,
      "isfilled": isFilled,
      "provider": _provider,
      "location_name": _locationname,
      "user_lat": 0.0.toDouble(),
      "user_long": 0.0.toDouble(),
    });
    notifyListeners();
  }

  Future saveDataToSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString('uid', _uid!);
    await s.setString('username', _username!);
    await s.setString('name', _name!);
    await s.setString('image_url', _imageUrl!);
    await s.setBool('isfilled', _isFilled!);
    await s.setString('provider', _provider!);
    await s.setString('location_name', _locationname!);
    notifyListeners();
  }

  Future getDataFromSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _uid = s.getString('uid');
    _username = s.getString('username');
    _name = s.getString('name');
    _imageUrl = s.getString('image_url');
    _isFilled = s.getBool('isfilled');
    _provider = s.getString('provider');
    _locationname = s.getString('location_name');

    notifyListeners();
  }

  // checkUser exists or not in cloudfirestore
  Future<bool> checkUserExists() async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    if (snap.exists) {
      print("EXISTING USER");
      return true;
    } else {
      print("NEW USER");
      return false;
    }
  }

  // signout
  Future userSignOut() async {
    await firebaseAuth.signOut;
    await googleSignIn.signOut();
    // await facebookAuth.logOut();

    _isSignedIn = false;
    notifyListeners();
    // clear all storage information
    clearStoredData();
  }

  Future clearStoredData() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.clear();
  }

  // void phoneNumberUser(User user, email, name) {
  //   _name = name;
  //   _email = email;
  //   _imageUrl =
  //       "https://winaero.com/blog/wp-content/uploads/2017/12/User-icon-256-blue.png";
  //   _uid = user.phoneNumber;
  //   _provider = "PHONE";
  //   notifyListeners();
  // }
}
