import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openbook/Models/user_model.dart';
import 'package:openbook/utils/globalvar.dart';

import '../Chat/chat.dart';

class UserTile extends StatelessWidget {
  final UserPeopleModel userModel;
  final types.User typeUser;
  const UserTile({super.key, required this.userModel, required this.typeUser});

  void _handlePressed(types.User otherUser, BuildContext context, UserPeopleModel userData) async {
    final navigator = Navigator.of(context);
    final room = await FirebaseChatCore.instance.createRoom(otherUser);

    //navigator.pop();
    await navigator.push(
      MaterialPageRoute(
        builder: (context) => ChatPage(room: room, userModel: userData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
      margin: EdgeInsets.symmetric(vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 22.w,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: userModel.imageurl.isNotEmpty ? userModel.imageurl : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                width: ScreenUtil().screenWidth * 0.2,
                height: ScreenUtil().screenWidth * 0.2,
                fit: BoxFit.cover,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => Image.network(
                  'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png', // Placeholder image
                  width: ScreenUtil().screenWidth * 0.2,
                  height: ScreenUtil().screenWidth * 0.2,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  userModel.name,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(fontFamily: globalfontfamily, fontSize: 13.sp, fontWeight: FontWeight.bold),
                ),
                Text(
                  userModel.locationname,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(fontFamily: globalfontfamily, color: Colors.grey, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          IconButton(
              onPressed: () {
                _handlePressed(typeUser, context, userModel);
              },
              icon: Icon(CupertinoIcons.chat_bubble_text, color: Colors.blue, size: 20.w))
        ],
      ),
    );
  }
}
