import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openbook/utils/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  bool _isSignedIn = false;

  bool get isSignedIn => _isSignedIn;

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

  String? _wallet_address;

  String? get wallet_address => _wallet_address;

  String? _token;

  String? get token => _token;

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

  // Future<void> thissignInWithTwitter() async {
  //   TwitterAuthProvider twitterProvider = TwitterAuthProvider();

  //   if (kIsWeb) {
  //     await FirebaseAuth.instance.signInWithPopup(twitterProvider);
  //   } else {
  //     await FirebaseAuth.instance.signInWithProvider(twitterProvider);
  //   }
  // }

  firebaseDemoSignInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: email, password: password);

      final userDetails = userCredential.user;
      // Extract the necessary information
      _username = userCredential.additionalUserInfo!.username ??
          userDetails?.displayName;
      _name = userDetails?.displayName;
      _email = userDetails?.email;
      _imageUrl = userDetails?.photoURL;
      _uid = userDetails?.uid;
      _provider = "Email";
      _isFilled = false;
      _locationname = "location";
      _hasError = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _errorCode = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        _errorCode = "Wrong password provided for that user.";
      } else {
        _errorCode = e.toString();
      }
      _hasError = true;
      notifyListeners();
    }
  }

  Future<void> firebasesignInWithTwitter() async {
    try {
      // Trigger Twitter OAuth flow using Firebase
      final twitterAuthProvider = TwitterAuthProvider();
      // twitterAuthProvider.setCustomParameters({'force_login': 'true'});

      final authResult =
          await FirebaseAuth.instance.signInWithProvider(twitterAuthProvider);

      // Get user details from the authentication result
      final userDetails = authResult.user;

      // Print or use the user details as needed
      print("authResult.user: $userDetails");
      print("userDetails!.name: ${userDetails!.displayName}");
      print(
          "userDetails!.username: ${authResult.additionalUserInfo!.username}");
      print(
          "firebaseAuth.currentUser!.email: ${firebaseAuth.currentUser!.email}");

      // Extract the necessary information
      _username =
          authResult.additionalUserInfo!.username ?? userDetails.displayName;
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
              _locationname = snapshot['location_name'],
              // _wallet_address = snapshot['wallet_address'] ?? ""
            });
    Response response = await ApiClient().login(_username!, _name!, _imageUrl!);
    final data = response.data;
    if (data.containsKey('data')) {
      Map<String, dynamic> loginData = data['data'];
      _wallet_address = loginData['publicKey'];
      _token = loginData['token'];
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({"wallet_address": _wallet_address}, SetOptions(merge: true));

      log("Logged in user's wallet: $wallet_address");
      log("Logged in user's token: $token");
    }
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
      "wallet_address": _wallet_address
    });
    Response response = await ApiClient().login(_username!, _name!, _imageUrl!);
    final data = response.data;
    if (data.containsKey('data')) {
      Map<String, dynamic> loginData = data['data'];
      _wallet_address = loginData['publicKey'];
      _token = loginData['token'];
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({"wallet_address": _wallet_address}, SetOptions(merge: true));

      log("Logged in user's wallet: $wallet_address");
      log("Logged in user's token: $token");
    }
    notifyListeners();
  }

  Future saveDataToSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();

    await s.setString('uid', _uid!);
    await s.setString('username', _username ?? _name!);
    await s.setString('name', _name!);
    await s.setString('image_url', _imageUrl!);
    await s.setBool('isfilled', _isFilled!);
    await s.setString('provider', _provider!);
    await s.setString('location_name', _locationname!);
    await s.setString('wallet_address', _wallet_address!);
    await s.setString('token', _token!);
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
    _token = s.getString('token');
    _wallet_address = s.getString('wallet_address');

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
}
