import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Models/user_model.dart';
import '../ScreenWidgets/peoplescreenwidget.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  Future<UserPeopleModel> getUserData(types.User user) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('users').doc(user.id).get();
    if (snapshot.exists) {
      return UserPeopleModel.fromMap(snapshot.data()!, snapshot.id);
    } else {
      throw Exception('User not found');
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<List<types.User>>(
        stream: FirebaseChatCore.instance.users(),
        initialData: const [],
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(bottom: 200.h),
              child: const Text('No users'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final user = snapshot.data![index];
              return FutureBuilder<UserPeopleModel>(
                future: getUserData(user),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AspectRatio(aspectRatio: 1, child: Center(child: CircularProgressIndicator()));
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  final userData = snapshot.data!;
                  return GestureDetector(onTap: () {}, child: UserTile(typeUser: user, userModel: userData));
                },
              );
            },
          );
        },
      );
}
