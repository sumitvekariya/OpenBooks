import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
      _username = authResult.additionalUserInfo!.username;
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
