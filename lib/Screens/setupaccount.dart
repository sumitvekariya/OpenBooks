import 'dart:convert';
import 'dart:developer';
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

class SetupAccount extends StatefulWidget {
  const SetupAccount({super.key});

  @override
  State<SetupAccount> createState() => _SetupAccountState();
}

class _SetupAccountState extends State<SetupAccount> {
  bool kisloading = false;
  bool isimageloading = false;
  bool isuploaded = false;
  File? selectedImage;
  int bookCount = 0;

  static const underdogApiEndpoint = "https://devnet.underdogprotocol.com";
  static const UNDERDOG_API_KEY = 'your_api_key_here';
  static const projectId = 1;

  String? avatarurl =
      "https://firebasestorage.googleapis.com/v0/b/easyed-prod.appspot.com/o/account.png?alt=media&token=85b40cb4-c4d2-4946-9317-e6aed240948d";

  void showSnackBar({required BuildContext context, required String content}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
      ),
    );
  }

  double? userlat = 19.0760;
  double? userlong = 72.8777;
  String? userlocationname;
  bool isloading = true;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<String> getLocationName(double latitude, double longitude) async {
    try {
      List<geo.Placemark> placemarks =
          await geo.placemarkFromCoordinates(latitude, longitude);

      if (placemarks != null && placemarks.isNotEmpty) {
        geo.Placemark place = placemarks[0];
        String locationName =
            "${place.subLocality}, ${place.locality}, ${place.country}";

        setState(() {
          isloading = false;
        });
        return locationName;
      } else {
        return "Location not found";
      }
    } catch (e) {
      log("An error occurred: $e");
      return "Error retrieving location";
    }
  }

  Future<void> getLocation() async {
    double latitude = userlat!;
    double longitude = userlong!;

    userlocationname = await getLocationName(latitude, longitude);
    log("location details are : $userlocationname");

    locationcontroller.text = userlocationname!;
  }

  Future<File?> pickImageFromGallery(BuildContext context) async {
    File? image;
    try {
      // final pickedImage =
      //     await ImagePicker().pickImage(source: ImageSource.gallery);
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);

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

    log(selectedImage as String);
  }

  Future uploadavatar() async {
    if (selectedImage != null) {
      setState(() {});

      Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child("UserAvatarImages")
          .child(userglobalData!.uid)
          .child("${randomAlphaNumeric(9)}.jpg");

      ///create a task to upload this data to our storage
      final UploadTask task = firebaseStorageRef.putFile(selectedImage!);

      var downoadUrl = await (await task).ref.getDownloadURL();
      log("this is url $downoadUrl");

      avatarurl = downoadUrl;
    } else {}
  }

  Future<http.Response> createNft(
      String name, String isbn, String image, String author, String desc, String minter, String receiver) async {
    final nftData = {
       "name": name,
      "isbn": isbn,
      "image": image,
      "author": author,
      "description": desc,
      "minter": minter,
      "receiver": {"identifier": receiver,"namespace": minter}
    };

    final response = await http.post(
      Uri.parse('$underdogApiEndpoint/v2/projects/$projectId/nfts'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $UNDERDOG_API_KEY',
      },
      body: jsonEncode(nftData),
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, then parse the JSON.
      return response;
    } else {
      // If the server did not return a 200 OK response, then throw an exception.
      throw Exception('Failed to create NFT');
    }
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
    final DocumentReference r = FirebaseFirestore.instance
        .collection("users")
        .doc(userglobalData!.uid)
        .collection("Books")
        .doc(bookid);

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

    final DocumentReference br =
        FirebaseFirestore.instance.collection("Books").doc(bookid);

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

      DocumentSnapshot userSnapshot =
          await firestore.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        userglobalData = UserData.fromSnapshot(userSnapshot);
        log('uid : ${userglobalData!.uid}');
        log('username: ${userglobalData!.username}');
        log('name: ${userglobalData!.name}');
        log('imageurl: ${userglobalData!.imageurl}');
        log('provider: ${userglobalData!.provider}');
        log('locationname: ${userglobalData!.locationname}');

        return userglobalData!;
      } else {
        log('User document does not exist');
        return UserData("", "", "", "", false, "", "", 0.0, 0.0);
      }
    } catch (e) {
      log('Error retrieving user data: $e');
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
    final DocumentReference r = FirebaseFirestore.instance
        .collection("users")
        .doc(userglobalData!.uid)
        .collection("Books")
        .doc(bookid);

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

    final DocumentReference br =
        FirebaseFirestore.instance.collection("Books").doc(bookid);

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
      log("Error: $e");
      return const LatLng(0, 0);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(const Duration(microseconds: 1), () async {
      await _determinePosition().then((value) async {
        log("my current location");
        log("${value.latitude} ${value.longitude}");

        userlat = value.latitude;
        userlong = value.longitude;
        await getLocation();
      });
    }).onError((error, stackTrace) async {
      log(error.toString());
      await getLocation();
    });
  }

  Future<Map<String, dynamic>> getBookDetails(String isbn) async {
    const apiKey =
        'AIzaSyDGiEMiI9r7CMcBS1RAJgvSp6kKxKeBt2M'; // Replace with your Google Books API key
    final apiUrl =
        'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn&key=$apiKey';

    //https://www.googleapis.com/books/v1/volumes?q=isbn:9781612680019&key=AIzaSyDGiEMiI9r7CMcBS1RAJgvSp6kKxKeBt2M

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
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 60.h),
                      Row(
                        children: [
                          Text(
                            "Set up your account",
                            style: TextStyle(
                                fontFamily: globalfontfamily,
                                color: Colors.black,
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_forward_ios_rounded),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            style: const ButtonStyle(
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap),
                          ),
                        ],
                      ),
                      Text(
                        "Welcome you are the books you read",
                        style: TextStyle(
                            fontFamily: globalfontfamily,
                            color: Colors.black,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w300),
                      ),
                      SizedBox(height: 20.h),
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
                                  child: CircularProgressIndicator(
                                      color: Color.fromRGBO(38, 90, 232, 1)),
                                )
                              : selectedImage != null
                                  ? Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 16.w),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: CircleAvatar(
                                            backgroundColor: Colors.white,
                                            backgroundImage: Image.file(
                                              selectedImage!,
                                              fit: BoxFit.cover,
                                            ).image,
                                            radius: 50),
                                      ),
                                    )
                                  : Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: CircleAvatar(
                                              backgroundColor: Colors.white,
                                              backgroundImage: Image.network(
                                                userglobalData!
                                                        .imageurl.isNotEmpty
                                                    ? userglobalData!.imageurl
                                                    : avatarurl!,
                                                fit: BoxFit.cover,
                                              ).image,
                                              radius: 50),
                                        ),
                                        const CircleAvatar(
                                          radius: 12,
                                          // backgroundColor: CupertinoColors.activeBlue,
                                          backgroundColor: Colors.blue,
                                          child: Icon(Icons.edit_rounded,
                                              color: Colors.white, size: 16),
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey[100]),
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 12.h),
                        child: Row(
                          children: [
                            Text(
                              "Name",
                              style: TextStyle(
                                  fontFamily: globalfontfamily,
                                  color: Colors.black,
                                  fontSize: 16.sp),
                            ),
                            SizedBox(width: 60.w),
                            Expanded(
                              child: Text(
                                userglobalData!.name,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyle(
                                    fontFamily: globalfontfamily,
                                    color: Colors.black,
                                    fontSize: 16.sp),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Location*",
                              style: TextStyle(
                                  fontFamily: globalfontfamily,
                                  fontSize: 14.sp)),
                          SizedBox(height: 5.h),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey[100],
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 6.h),
                            child: GooglePlaceAutoCompleteTextField(
                              textEditingController: locationcontroller,
                              googleAPIKey:
                                  "AIzaSyC1xIPJQYPYjT83ki9L1d0-NgiejK8loNw",
                              inputDecoration: InputDecoration(
                                border: InputBorder.none,
                                suffixIcon: const Icon(Icons.near_me_rounded,
                                    color: Colors.blue),
                                hintText: "Location",
                                hintStyle: TextStyle(
                                    fontFamily: globalfontfamily,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w300),
                                labelStyle: TextStyle(
                                    fontFamily: globalfontfamily,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w300),
                              ),
                              boxDecoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0x00f9f9f9))),
                              debounceTime: 800,
                              countries: const ["in", "fr"],
                              isLatLngRequired: true,
                              getPlaceDetailWithLatLng:
                                  (Prediction prediction) {
                                log("placeDetails${prediction.lng}");
                              },
                              itemClick: (Prediction prediction) {
                                locationcontroller.text =
                                    prediction.description!;
                                locationcontroller.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset:
                                            prediction.description!.length));
                              },
                              itemBuilder:
                                  (context, index, Prediction prediction) {
                                return Row(
                                  children: [
                                    const Icon(Icons.location_on),
                                    SizedBox(width: 7.w),
                                    Expanded(
                                        child:
                                            Text(prediction.description ?? ""))
                                  ],
                                );
                              },
                              seperatedBuilder: const Divider(),
                              isCrossBtnShown: true,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "Top 3 books that impacted your life",
                        style: TextStyle(
                            fontFamily: globalfontfamily,
                            color: Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 12.h),
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(userglobalData!.uid)
                              .collection('Books')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            List<Book> books =
                                snapshot.data!.docs.map((DocumentSnapshot doc) {
                              Map<String, dynamic> data =
                                  doc.data() as Map<String, dynamic>;
                              return Book.fromMap(data, doc.id);
                            }).toList();

                            usersbooklength = books.length;

                            if (books.isEmpty) {
                              return buildNoBooks();
                            } else {
                              return buildBooks(books);
                            }
                          }),
                      SizedBox(height: 35.h),
                      TapBounceContainer(
                        child: GestureDetector(
                          onTap: () async {
                            var res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SimpleBarcodeScannerPage(
                                          scanType: ScanType.barcode),
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
                                      message: 'Book not Found'),
                                );
                              });
                              try {
                                log('Barcode Result: $res');
                                log('Title: ${bookDetails['title'] ?? "no tittle"}');
                                log('Author(s): ${bookDetails['authors'][0] ?? "no author name"}');
                                log('Description: ${bookDetails['description'] ?? "no description"}');
                                log('Image: ${bookDetails['imageLinks']['thumbnail'] ?? "no image cover"}');

                                String book1id = randomAlphaNumeric(9);
                                String book1name =
                                    bookDetails['title'] ?? "no tittle";
                                String book1authorname = bookDetails['authors']
                                        [0] ??
                                    "no author name";

                                String imgcover = bookDetails['imageLinks']
                                        ['thumbnail'] ??
                                    "https://firebasestorage.googleapis.com/v0/b/openbook-68460.appspot.com/o/cover.png?alt=media&token=63132f9d-b178-4a10-a38d-c59f98b55a09";

                                String bookdesc = bookDetails['description'] ??
                                    "no descriptions";

                                String userloc = locationcontroller.text;

                                LatLng locationcoordinates =
                                    await getLocationFromAddress(userloc);

                                double userlocationlat =
                                    locationcoordinates.latitude;

                                double userlocationlong =
                                    locationcoordinates.longitude;

                                await saveDataToFirestorefromscanner(
                                  bookid: book1id,
                                  bookname: book1name,
                                  authorname: book1authorname,
                                  imgcover: imgcover,
                                  username: userglobalData!.username,
                                  userimage: userglobalData!.imageurl.isEmpty
                                      ? userglobalData!.imageurl
                                      : avatarurl!,
                                  useruid: userglobalData!.uid,
                                  userlocation: userloc,
                                  userlat: userlocationlat,
                                  userlong: userlocationlong,
                                  bookdesc: bookdesc,
                                );

                                createNft(book1name, res, imgcover, book1authorname, bookdesc, "OpenBooks", userglobalData!.username);

                                setState(() {
                                  bookloading = false;
                                });

                                showTopSnackBar(
                                  Overlay.of(context),
                                  CustomSnackBar.success(
                                      message:
                                          '$book1name added Successfully !'),
                                );
                              } catch (e) {
                                setState(() {
                                  bookloading = false;
                                });

                                showTopSnackBar(
                                  Overlay.of(context),
                                  const CustomSnackBar.error(
                                      message:
                                          'An error occurred while processing the book details'),
                                );
                              }
                            }
                          },
                          child: Center(
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
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 5.h, 24.h, 25.h),
          child: ElevatedButton(
            onPressed: () async {
              if (locationcontroller.text.isNotEmpty && usersbooklength != 0) {
                avatarurl = userglobalData!.imageurl.isNotEmpty
                    ? userglobalData?.imageurl
                    : "https://firebasestorage.googleapis.com/v0/b/easyed-prod.appspot.com/o/account.png?alt=media&token=85b40cb4-c4d2-4946-9317-e6aed240948d";

                setState(() {
                  kisloading = true;
                });

                if (!isuploaded) {
                  await uploadavatar();
                }

                String userloc = locationcontroller.text;

                LatLng locationcoordinates =
                    await getLocationFromAddress(userloc);

                double userlocationlat = locationcoordinates.latitude;

                double userlocationlong = locationcoordinates.longitude;

                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(userglobalData!.uid)
                    .update({
                  "isfilled": true,
                  "location_name": userloc,
                  "image_url": avatarurl,
                  "user_lat": userlocationlat,
                  "user_long": userlocationlong,
                });

                if (!isuploaded) {
                  String? userUid = FirebaseAuth.instance.currentUser?.uid;
                  log(userUid!);
                  await getUserData(userUid!);
                }

                setState(() {
                  kisloading = false;
                });
                nextScreenpushandremove(context, const HomePage());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: usersbooklength == 0 ? Colors.grey : Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: kisloading
                ? Center(
                    child: Container(
                      color: Colors.transparent,
                      height: 18.h,
                      width: 18.w,
                      child:
                          const CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const SizedBox(),
                      Text(
                        "Add books to your shelf",
                        style: TextStyle(
                            fontFamily: globalfontfamily,
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600),
                      ),
                      const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 20)
                    ],
                  ),
          ),
        ));
  }

  Container buildBooks(List<Book> books) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.grey[100]),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            return AccountBookwidget(book: books[index]);
          }),
    );
  }

  Container buildNoBooks() {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.grey[100]),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Center(
        child: Text(
          "No books added yet",
          style: TextStyle(
              // fontWeight: FontWeight.bold,
              fontFamily: globalfontfamily,
              fontSize: 13.sp),
        ),
      ),
    );
  }
}
