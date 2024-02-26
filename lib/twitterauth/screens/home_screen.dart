// import 'package:openbook/twitterauth/screens/login_screen.dart';
// import 'package:openbook/twitterauth/utils/global_data.dart';
// import 'package:openbook/twitterauth/utils/next_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:openbook/twitterauth/provider/sign_in_provider.dart';
// import 'package:flutter/material.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   Future getData() async {
//     final sp = context.read<SignInProvider>();
//     sp.getDataFromSharedPreferences();
//   }

//   @override
//   void initState() {
//     super.initState();
//     getData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // change read to watch!!!!
//     final sp = context.watch<SignInProvider>();
//     // print(sp.uid);
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: <Widget>[
//             CircleAvatar(
//               backgroundColor: Colors.white,
//               backgroundImage: NetworkImage(userglobalData!.imageurl),
//               radius: 50,
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             Text(
//               "Welcome ${userglobalData!.username}",
//               style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             Text(
//               "${sp.email}",
//               style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             Text(
//               "${sp.uid}",
//               style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text("PROVIDER:"),
//                 const SizedBox(
//                   width: 5,
//                 ),
//                 Text("${sp.provider}".toUpperCase(),
//                     style: const TextStyle(color: Colors.red)),
//               ],
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             ElevatedButton(
//                 onPressed: () {
//                   sp.userSignOut();
//                   nextScreenReplace(context, const LoginScreen());
//                 },
//                 child: const Text("SIGNOUT",
//                     style: TextStyle(
//                       color: Colors.white,
//                     )))
//           ],
//         ),
//       ),
//     );
//   }
// }
