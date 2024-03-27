import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:openbook/Models/book_model.dart';
import 'package:openbook/Models/user_data_models.dart';
import 'package:openbook/ScreenWidgets/accountbookwidget.dart';
import 'package:openbook/Screens/homepage.dart';
import 'package:openbook/Widgets/widgets.dart';
import 'package:openbook/utils/global_data.dart';
import 'package:openbook/utils/globalvar.dart';
import 'package:random_string/random_string.dart';
import 'package:simple_barcode_scanner/enum.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class SetupupAccount extends StatefulWidget {
  const SetupupAccount({super.key});

  @override
  State<SetupupAccount> createState() => _SetupupAccountState();
}

class _SetupupAccountState extends State<SetupupAccount> {
  bool kisloading = false;
  bool isimageloading = false;
  bool isuploaded = false;
  File? selectedImage;

  String? avatarurl = "https://firebasestorage.googleapis.com/v0/b/easyed-prod.appspot.com/o/account.png?alt=media&token=85b40cb4-c4d2-4946-9317-e6aed240948d";

  void showSnackBar({required BuildContext context, required String content}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
      ),
    );
  }

  double? userlat;
  double? userlong;
  String? userlocationname;
  bool isloading = true;

  Future<Position> getcurrentlocation() async {
    await Geolocator.requestPermission().then((value) {}).onError((error, stackTrace) {
      print("error" + error.toString());
    });

    return Geolocator.getCurrentPosition();
  }

  Future<String> getLocationName(double latitude, double longitude) async {
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(latitude, longitude);

      if (placemarks != null && placemarks.isNotEmpty) {
        geo.Placemark place = placemarks[0];
        String locationName = "${place.subLocality}, ${place.locality}, ${place.country}";

        setState(() {
          isloading = false;
        });
        return locationName;
      } else {
        return "Location not found";
      }
    } catch (e) {
      print("An error occurred: $e");
      return "Error retrieving location";
    }
  }

  Future<void> getLocation() async {
    double latitude = userlat!;
    double longitude = userlong!;

    userlocationname = await getLocationName(latitude, longitude);
    print("location details are : ${userlocationname}");

    locationcontroller.text = userlocationname!;
  }

  Future<File?> pickImageFromGallery(BuildContext context) async {
    File? image;
    try {
      // final pickedImage =
      //     await ImagePicker().pickImage(source: ImageSource.gallery);
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        image = File(pickedImage.path);
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
    return image;
  }

  Future getImage() async {
    var image = await pickImageFromGallery(context);

    setState(() {
      selectedImage = image;
    });

    isuploaded = true;

    print(selectedImage);
  }

  Future uploadavatar() async {
    if (selectedImage != null) {
      setState(() {});

      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child("UserAvatarImages").child(userglobalData!.uid).child("${randomAlphaNumeric(9)}.jpg");

      ///create a task to upload this data to our storage
      final UploadTask task = firebaseStorageRef.putFile(selectedImage!);

      var downoadUrl = await (await task).ref.getDownloadURL();
      print("this is url $downoadUrl");

      avatarurl = downoadUrl;
    } else {}
  }

  final formKey = GlobalKey<FormState>();
  TextEditingController locationcontroller = TextEditingController();

  bool bookloading = false;
  int usersbooklength = 0;

  Future saveDataToFirestore({
    required String bookid,
    required String bookname,
    required String authorname,
    required String imgcover,
    required String username,
    required String userimage,
    required String useruid,
    required String userlocation,
    required double userlat,
    required double userlong,
  }) async {
    final DocumentReference r = FirebaseFirestore.instance.collection("users").doc(userglobalData!.uid).collection("Books").doc(bookid);

    await r.set({
      "book_id": bookid,
      "book_name": bookname,
      "author_name": authorname,
      "image_cover": imgcover,
      "username": username,
      "userimage": userimage,
      "useruid": useruid,
      "user_location": userlocation,
      "user_lat": userlat,
      "user_long": userlong,
      "isrented": false,
    });

    final DocumentReference br = FirebaseFirestore.instance.collection("Books").doc(bookid);

    await br.set({
      "book_id": bookid,
      "book_name": bookname,
      "author_name": authorname,
      "image_cover": imgcover,
      "username": username,
      "userimage": userimage,
      "useruid": useruid,
      "user_location": userlocation,
      "user_lat": userlat,
      "user_long": userlong,
      "isrented": false,
    });
  }

  Future<UserData> getUserData(String uid) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentSnapshot userSnapshot = await firestore.collection('users').doc(uid).get();

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

  Future saveDataToFirestorefromscanner({
    required String bookid,
    required String bookname,
    required String authorname,
    required String imgcover,
    required String username,
    required String userimage,
    required String useruid,
    required String userlocation,
    required double userlat,
    required double userlong,
    required String bookdesc,
  }) async {
    final DocumentReference r = FirebaseFirestore.instance.collection("users").doc(userglobalData!.uid).collection("Books").doc(bookid);

    await r.set({
      "book_id": bookid,
      "book_name": bookname,
      "author_name": authorname,
      "image_cover": imgcover,
      "username": username,
      "userimage": userimage,
      "useruid": useruid,
      "user_location": userlocation,
      "user_lat": userlat,
      "user_long": userlong,
      "isrented": false,
      "bookdesc": bookdesc,
    });

    final DocumentReference br = FirebaseFirestore.instance.collection("Books").doc(bookid);

    await br.set({
      "book_id": bookid,
      "book_name": bookname,
      "author_name": authorname,
      "image_cover": imgcover,
      "username": username,
      "userimage": userimage,
      "useruid": useruid,
      "user_location": userlocation,
      "user_lat": userlat,
      "user_long": userlong,
      "isrented": false,
      "bookdesc": bookdesc,
    });
  }

  Map<String, dynamic> bookDetails = {};

  Future<LatLng> getLocationFromAddress(String address) async {
    try {
      List<geo.Location> locations = await geo.locationFromAddress(address);
      if (locations.isNotEmpty) {
        geo.Location location = locations.first;
        return LatLng(location.latitude, location.longitude);
      }
      throw Exception("Location not found for the given address");
    } catch (e) {
      print("Error: $e");
      return const LatLng(0, 0);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(const Duration(microseconds: 1), () async {
      await getcurrentlocation().then((value) async {
        print("my current loaction");
        print(value.latitude.toString() + " " + value.longitude.toString());

        userlat = value.latitude;
        userlong = value.longitude;
        await getLocation();
      });
    });
  }

  Future<Map<String, dynamic>> getBookDetails(String isbn) async {
    final apiKey = 'AIzaSyDGiEMiI9r7CMcBS1RAJgvSp6kKxKeBt2M'; // Replace with your Google Books API key
    final apiUrl = 'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn&key=$apiKey';

    //https://www.googleapis.com/books/v1/volumes?q=isbn:4577714843828&key=AIzaSyDGiEMiI9r7CMcBS1RAJgvSp6kKxKeBt2M

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('items')) {
          final bookInfo = data['items'][0]['volumeInfo'];
          return bookInfo;
        } else {
          return {'error': 'Book not found'};
        }
      } else {
        return {'error': 'Failed to fetch book details'};
      }
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isloading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: SizedBox(
                // color: Colors.red,
                width: screenWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 48.h,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 24.0.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Set up your account",
                            style: TextStyle(fontFamily: globalfontfamily, color: Colors.black, fontSize: 28.sp, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            width: 300.w,
                            child: Text(
                              "Help us know more about your book preferences so we can let others know about your books",
                              style: TextStyle(fontFamily: globalfontfamily, color: Colors.black, fontSize: 12.sp, fontWeight: FontWeight.w300),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          setState(() {
                            isimageloading = true;
                          });

                          await getImage();
                          setState(() {
                            isimageloading = false;
                          });
                        },
                        child: isimageloading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Color.fromRGBO(38, 90, 232, 1)),
                              )
                            : selectedImage != null
                                ? Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16),
                                    height: 102.h,
                                    width: 102.w,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        backgroundImage: Image.file(
                                          selectedImage!,
                                          fit: BoxFit.cover,
                                        ).image,
                                        radius: 50,
                                        // child: Image.file(
                                        //   selectedImage!,
                                        //   fit: BoxFit.cover,
                                        // ),
                                      ),
                                    ),
                                  )
                                : Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          backgroundImage: Image.network(
                                            userglobalData!.imageurl.isNotEmpty ? userglobalData!.imageurl : avatarurl!,
                                            fit: BoxFit.cover,
                                          ).image,
                                          radius: 50,
                                          // child: Image.file(
                                          //   selectedImage!,
                                          //   fit: BoxFit.cover,
                                          // ),
                                        ),
                                      ),
                                      SizedBox(
                                        // color: Colors.red,
                                        height: 24.h,
                                        width: 24.w,
                                        child: Image.asset("assets/images/edit1.png"),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 24.0.w),
                      child: SizedBox(
                        // color: Colors.red,
                        height: 98.h,
                        width: 342.w,
                        child: Padding(
                          padding: EdgeInsets.only(left: 20.0.w, top: 16.h),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Name",
                                    style: TextStyle(
                                      fontFamily: globalfontfamily,
                                      color: Colors.black,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50.w,
                                  ),
                                  Text(
                                    userglobalData!.name,
                                    style: TextStyle(
                                      fontFamily: globalfontfamily,
                                      color: Colors.black,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Container(
                                height: 1,
                                color: const Color.fromRGBO(198, 198, 200, 1),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "username",
                                    style: TextStyle(
                                      fontFamily: globalfontfamily,
                                      color: Colors.black,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 22.w,
                                  ),
                                  Text(
                                    "@${userglobalData!.username}",
                                    style: TextStyle(
                                      fontFamily: globalfontfamily,
                                      color: Colors.black,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 24.0.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Location*",
                            style: TextStyle(
                              fontFamily: globalfontfamily,
                              color: const Color.fromRGBO(0, 0, 0, 1),
                              fontSize: 14.sp,
                            ),
                          ),
                          // Text(
                          //   "This helps us better match make",
                          //   style: TextStyle(
                          //     fontFamily: globalfontfamily,
                          //     color: Color.fromRGBO(0, 0, 0, 1),
                          //     fontSize: 12.sp,
                          //     fontWeight: FontWeight.w300,
                          //   ),
                          // ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Container(
                            color: const Color.fromRGBO(249, 249, 249, 1),
                            width: 342.w,
                            child: Padding(
                              padding: EdgeInsets.only(left: 8.0.w),
                              child: GooglePlaceAutoCompleteTextField(
                                textEditingController: locationcontroller,
                                googleAPIKey: "AIzaSyC1xIPJQYPYjT83ki9L1d0-NgiejK8loNw",
                                inputDecoration: InputDecoration(
                                  border: InputBorder.none,
                                  suffixIcon: Image.asset("assets/images/loc.png"),

                                  hintText: "Location",
                                  hintStyle: TextStyle(
                                    fontFamily: globalfontfamily,
                                    color: const Color.fromRGBO(0, 0, 0, 1),
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  // labelText: 'Mumbai',
                                  labelStyle: TextStyle(
                                    fontFamily: globalfontfamily,
                                    color: const Color.fromRGBO(0, 0, 0, 1),
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  // border: OutlineInputBorder(
                                  //     borderRadius: BorderRadius.circular(0.0),
                                  //     borderSide: BorderSide.none),
                                ),
                                boxDecoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color.fromRGBO(249, 249, 249, 1),
                                  ),
                                ),
                                debounceTime: 800,
                                countries: const ["in", "fr"],
                                isLatLngRequired: true,
                                getPlaceDetailWithLatLng: (Prediction prediction) {
                                  print("placeDetails${prediction.lng}");
                                },
                                itemClick: (Prediction prediction) {
                                  locationcontroller.text = prediction.description!;
                                  locationcontroller.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description!.length));
                                },
                                itemBuilder: (context, index, Prediction prediction) {
                                  return Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.location_on),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                        Expanded(child: Text(prediction.description ?? ""))
                                      ],
                                    ),
                                  );
                                },
                                seperatedBuilder: const Divider(),
                                isCrossBtnShown: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.only(left: 24.0.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Top 3 books that impacted your life",
                            style: TextStyle(
                              fontFamily: globalfontfamily,
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "This helps us better match make",
                            style: TextStyle(
                              fontFamily: globalfontfamily,
                              color: Colors.black,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          SizedBox(
                            height: 12.h,
                          ),
                          StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance.collection('users').doc(userglobalData!.uid).collection('Books').snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }

                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                List<Book> books = snapshot.data!.docs.map((DocumentSnapshot doc) {
                                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                                  return Book.fromMap(data, doc.id);
                                }).toList();

                                usersbooklength = books.length;

                                if (books.isEmpty) {
                                  return Container(
                                      width: 342.h,
                                      padding: EdgeInsets.only(
                                        left: 20.0.w,
                                        right: 20.0.w,
                                        top: 5.h,
                                      ),
                                      // color: const Color.fromRGBO(249, 249, 249, 1),
                                      child: const Center(
                                        child: Text(
                                          "No books added yet",
                                          style: TextStyle(
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: globalfontfamily,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ));
                                } else {
                                  return Container(
                                    height: 225.h,
                                    width: 342.w,
                                    color: const Color.fromRGBO(249, 249, 249, 1),
                                    padding: EdgeInsets.only(
                                      left: 20.0.w,
                                      right: 20.0.w,
                                    ),
                                    child: ListView.builder(
                                        itemCount: books.length,
                                        itemBuilder: (context, index) {
                                          return AccountBookwidget(
                                            book: books[index],
                                          );
                                        }),
                                  );
                                }
                              }),
                          SizedBox(
                            height: 35.h,
                          ),
                          TapBounceContainer(
                            child: GestureDetector(
                              onTap: () async {
                                var res = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SimpleBarcodeScannerPage(
                                        scanType: ScanType.barcode,
                                      ),
                                    ));

                                if (res != '-1') {
                                  setState(() {
                                    bookloading = true;
                                  });
                                  await getBookDetails(res).then((details) {
                                    setState(() {
                                      bookDetails = details;
                                    });
                                  }).catchError((e) {
                                    setState(() {
                                      bookloading = false;
                                    });

                                    showTopSnackBar(
                                      Overlay.of(context),
                                      const CustomSnackBar.error(
                                        message: 'Book not Found',
                                      ),
                                    );
                                  });
                                  try {
                                    print('Barcode Result: $res');
                                    print('Title: ${bookDetails['title'] ?? "no tittle"}');
                                    print('Author(s): ${bookDetails['authors'][0] ?? "no author name"}');
                                    print('Description: ${bookDetails['description'] ?? "no description"}');
                                    print('Image: ${bookDetails['imageLinks']['thumbnail'] ?? "no imgcovr"}');

                                    String book1id = randomAlphaNumeric(9);
                                    String book1name = bookDetails['title'] ?? "no tittle";
                                    String book1authorname = bookDetails['authors'][0] ?? "no author name";

                                    String imgcover = bookDetails['imageLinks']['thumbnail'] ??
                                        "https://firebasestorage.googleapis.com/v0/b/openbook-68460.appspot.com/o/cover.png?alt=media&token=63132f9d-b178-4a10-a38d-c59f98b55a09";

                                    String bookdesc = bookDetails['description'] ?? "no descriptions";

                                    String userloc = locationcontroller.text;

                                    LatLng locationcoordinates = await getLocationFromAddress(userloc);

                                    double userlocationlat = locationcoordinates.latitude;

                                    double userlocationlong = locationcoordinates.longitude;

                                    await saveDataToFirestorefromscanner(
                                      bookid: book1id,
                                      bookname: book1name,
                                      authorname: book1authorname,
                                      imgcover: imgcover,
                                      username: userglobalData!.username,
                                      userimage: userglobalData!.imageurl.isEmpty ? userglobalData!.imageurl : avatarurl!,
                                      useruid: userglobalData!.uid,
                                      userlocation: userloc,
                                      userlat: userlocationlat,
                                      userlong: userlocationlong,
                                      bookdesc: bookdesc,
                                    );

                                    setState(() {
                                      bookloading = false;
                                    });

                                    showTopSnackBar(
                                      Overlay.of(context),
                                      CustomSnackBar.success(
                                        message: '$book1name added Successfully !',
                                      ),
                                    );

                                    ///
                                  } catch (e) {
                                    setState(() {
                                      bookloading = false;
                                    });

                                    showTopSnackBar(
                                      Overlay.of(context),
                                      const CustomSnackBar.error(
                                        message: 'An error occurred while processing the book details',
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 25.0.w),
                                  child: SizedBox(
                                    // color: Colors.red,
                                    height: 30,
                                    width: 30,
                                    child: bookloading
                                        ? const CircularProgressIndicator()
                                        : Image.asset(
                                            "assets/images/barcode-scanner.png",
                                            fit: BoxFit.cover,
                                            height: 30,
                                            width: 30,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40.h,
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (locationcontroller.text.isNotEmpty && usersbooklength != 0) {
                                print(isuploaded);
                                avatarurl = userglobalData!.imageurl.isNotEmpty
                                    ? userglobalData?.imageurl
                                    : "https://firebasestorage.googleapis.com/v0/b/easyed-prod.appspot.com/o/account.png?alt=media&token=85b40cb4-c4d2-4946-9317-e6aed240948d";

                                setState(() {
                                  kisloading = true;
                                });

                                if (!isuploaded) {
                                  await uploadavatar();
                                }

                                String imgcover =
                                    "https://firebasestorage.googleapis.com/v0/b/openbook-68460.appspot.com/o/cover.png?alt=media&token=63132f9d-b178-4a10-a38d-c59f98b55a09";
                                String userloc = locationcontroller.text;

                                LatLng locationcoordinates = await getLocationFromAddress(userloc);

                                double userlocationlat = locationcoordinates.latitude;

                                double userlocationlong = locationcoordinates.longitude;

                                await FirebaseFirestore.instance.collection("users").doc(userglobalData!.uid).update({
                                  "isfilled": true,
                                  "location_name": userloc,
                                  "image_url": avatarurl,
                                  "user_lat": userlocationlat,
                                  "user_long": userlocationlong,
                                });

                                if (!isuploaded) {
                                  String? userUid = FirebaseAuth.instance.currentUser?.uid;
                                  print(userUid);
                                  await getUserData(userUid!);
                                }

                                setState(() {
                                  kisloading = false;
                                });

                                nextScreenpushandremove(context, const HomePage());
                              }
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
                                  child: kisloading
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
                                              width: 78.5.w,
                                            ),
                                            Text(
                                              "Add books to your shelf",
                                              style: TextStyle(fontFamily: globalfontfamily, color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600),
                                            ),
                                            SizedBox(
                                              width: 46.5.w,
                                            ),
                                            Image.asset("assets/images/icarr.png")
                                          ],
                                        )),
                            ),
                          ),
                          SizedBox(
                            height: 24.h,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
