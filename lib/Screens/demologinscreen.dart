import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../TwitterAuth/provider/internet_provider.dart';
import '../TwitterAuth/provider/sign_in_provider.dart';
import '../utils/globalvar.dart';
import '../utils/snack_bar.dart';

class DemoLoginScreen extends StatefulWidget {
  final Future Function() handleAfterSignIn;

  const DemoLoginScreen({Key? key, required this.handleAfterSignIn})
      : super(key: key);

  @override
  State<DemoLoginScreen> createState() => _DemoLoginScreenState();
}

class _DemoLoginScreenState extends State<DemoLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: 160.h,
                  bottom: 70.h,
                ),
                height: 265.h,
                width: 258.w,
                child: SvgPicture.asset("assets/images/grp1.svg"),
              ),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: emailTextField(
                  _emailController,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.w),
                child: passwordTextField(
                  _passwordController,
                  obscurity: true,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (_formKey.currentState?.validate() == true && !isLoading) {
                    setState(() {
                      isLoading = true;
                    });
                    await handleDemoLogin();
                  }
                },
                child: Container(
                  height: 43.h,
                  width: 339.w,
                  decoration: BoxDecoration(
                    color: Colors.black87,
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
                    child: isLoading
                        ? Center(
                            child: SizedBox(
                              height: 18.h,
                              width: 18.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            "Sign in",
                            style: TextStyle(
                                fontFamily: globalfontfamily,
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
            ],
          ),
        ),
      ),
    );
  }

  handleDemoLogin() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (!ip.hasInternet) {
      openSnackbar(context, "Check your Internet connection", Colors.red);
    } else {
      await sp.firebaseDemoSignInWithEmail(
          _emailController.text.trim(), _passwordController.text.trim());
      if (sp.hasError == true) {
        setState(() {
          isLoading = false;
        });
        openSnackbar(context, "Invalid email or password", Colors.red);
        return;
      }
      sp.getUserDataFromFirestore(sp.uid).then((value) => sp
          .saveDataToSharedPreferences()
          .then((value) => sp.setSignIn().then((value) {
                widget.handleAfterSignIn.call();
              })));
    }
  }

  /// Email text field with appropriate validation
  Widget emailTextField(
    TextEditingController controller, {
    FocusNode? thisFocus,
    FocusNode? nextFocus,
  }) {
    return TextFormField(
      key: const Key('emailTextfield'),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      focusNode: thisFocus,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        fillColor: Colors.white70,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.fromLTRB(12.h, 12.h, 8.h, 12.h),
          child: const Icon(Icons.email),
        ),
        hintText: 'Enter Email',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
      validator: (val) {
        const pattern =
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
        final regex = RegExp(pattern);
        if (!regex.hasMatch(val!)) {
          return 'Not a valid email';
        } else {
          return null;
        }
      },
      onFieldSubmitted: (val) {
        nextFocus?.requestFocus();
      },
    );
  }

  /// Password text field
  Widget passwordTextField(
    TextEditingController controller, {
    Key? key,
    required bool obscurity,
    FocusNode? thisFocus,
    FocusNode? nextFocus,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        return TextFormField(
          key: key ?? const Key('passwordTextfield'),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: controller,
          focusNode: thisFocus,
          obscureText: obscurity,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.fromLTRB(12.h, 12.h, 8.h, 12.h),
              child: const Icon(Icons.lock),
            ),
            hintText: 'Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.r)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            suffixIcon: IconButton(
              icon: Icon(obscurity
                  ? CupertinoIcons.eye_fill
                  : CupertinoIcons.eye_slash_fill),
              // ignore: parameter_assignments
              onPressed: () => setState(() => obscurity = !obscurity),
            ),
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          validator: (val) =>
              (controller.text.isEmpty || controller.text.length < 4)
                  ? 'Not a valid password'
                  : null,
          onFieldSubmitted: (val) {
            nextFocus?.requestFocus();
          },
        );
      },
    );
  }
}
