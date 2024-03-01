import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:openbook/utils/globalvar.dart';

import 'package:openbook/Models/user_model.dart';
import 'package:openbook/Widgets/widgets.dart';
import 'package:openbook/Screens/youraccountscreen.dart';

class PeopleWidget extends StatelessWidget {
  final UserPeopleModel usermodel;
  const PeopleWidget({
    super.key,
    required this.usermodel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    // margin: EdgeInsets.symmetric(horizontal: 16),
                    height: 30.h,
                    width: 30.w,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: Image.network(
                          usermodel.imageurl,
                          fit: BoxFit.cover,
                        ).image,
                        radius: 50,
                        // child: Image.file(
                        //   selectedImage!,
                        //   fit: BoxFit.cover,
                        // ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 12.0.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${usermodel.username}",
                          style: TextStyle(
                            fontFamily: globalfontfamily,
                            color: Color.fromRGBO(0, 0, 0, 1),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          "${usermodel.locationname}",
                          style: TextStyle(
                            fontFamily: globalfontfamily,
                            color: Color.fromRGBO(0, 0, 0, 1),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                        // SizedBox(
                        //   height: 12.h,
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                height: 1,
                color: Color.fromRGBO(198, 198, 200, 1),
              ),
              SizedBox(
                height: 12.h,
              ),
              Image.asset("assets/images/msg.png")
            ],
          ),
        ),
        SizedBox(
          height: 12.h,
        ),
        Container(
          height: 1,
          color: Color.fromRGBO(198, 198, 200, 1),
        ),
        SizedBox(
          height: 12.h,
        ),
      ],
    );
  }
}

class PeopleBox extends StatelessWidget {
  const PeopleBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(context, YourAccountScreen());
      },
      child: Container(
        // color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset("assets/images/people.png"),
                Padding(
                  padding: EdgeInsets.only(left: 12.0.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Aisha Mukherjee",
                        style: TextStyle(
                          fontFamily: globalfontfamily,
                          color: Color.fromRGBO(0, 0, 0, 1),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        "320+ books",
                        style: TextStyle(
                          fontFamily: globalfontfamily,
                          color: Color.fromRGBO(0, 0, 0, 1),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      // SizedBox(
                      //   height: 12.h,
                      // ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              height: 1,
              color: Color.fromRGBO(198, 198, 200, 1),
            ),
            SizedBox(
              height: 12.h,
            ),
            Image.asset("assets/images/msg.png")
          ],
        ),
      ),
    );
  }
}
