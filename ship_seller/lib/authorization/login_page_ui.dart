import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ship_seller/app/home_ui.dart';
import 'package:ship_seller/authorization/login_page_controller.dart';
import 'package:ship_seller/services/connectivity.dart';
import 'package:ship_seller/utils/colors_themes.dart';
import 'package:ship_seller/utils/constants.dart';
import 'package:ship_seller/utils/widgets.dart';

class LoginPageUI extends StatefulWidget {
  const LoginPageUI({Key? key}) : super(key: key);

  @override
  State<LoginPageUI> createState() => _LoginPageUIState();
}

class _LoginPageUIState extends State<LoginPageUI> {

  late Color buttonColor;
  late NetworkConnectivityController _networkConnectivityController;
  late TextEditingController emailEditingController, passwordEditingController;
  late LoginPageController loginPageController;

  @override
  void initState() {
    super.initState();

    try {
      _networkConnectivityController = Get.find();
    } catch (e) {
      _networkConnectivityController = Get.put(NetworkConnectivityController());
    }

    try {
      loginPageController = Get.find();
    } catch (e) {
      loginPageController = Get.put(LoginPageController());
    }

    buttonColor = Color(blue);
    loginPageController.initialize();
    emailEditingController = TextEditingController(text: 'ashish.kataria+hackathon@shiprocket.com');
    passwordEditingController = TextEditingController(text: 'hackathon@2022');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(yellow).withAlpha(20),
        body: MediaQuery.of(context).size.width <= webRefWidth ? loginFormMobile() : loginFormWeb(),
      ),
    );
  }

  Widget loginFormWeb(){
    return Row(
      children: [
        Expanded(flex: 3, child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                logo(),
                appName(),
              ],
            ),
            loginImage(),
          ],
        ),),
        Expanded(flex: 2, child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loginMessage(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 64, vertical: 16),
              child: Material(
                color: Color(blueBg),
                shadowColor: Color(blue),
                elevation: 4,
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 24,),
                    emailInputField(),
                    passwordInputField(),
                    loginButton()
                  ],
                ),
              ),
            ),
          ],
        ),)
      ],
    );
  }

  Widget loginMessage(){
    return Container(
      margin: EdgeInsets.all(16),
      child: Text(
        'Please Login',
        style: TextStyle(
          color: Color(blue),
          fontSize: 24,
          shadows: [
            Shadow(color: Color(blue).withAlpha(100), offset: Offset(1,1), blurRadius: 2)
          ]
          // decoration: TextDecoration.underline
        ),
      ),
    );
  }

  Widget loginFormMobile() {
    return SingleChildScrollView(
      child: Column(
        children: [
          logo(),
          appName(),
          loginImage(),
          emailInputField(),
          passwordInputField(),
          loginButton()
        ],
      ),
    );
  }

  Widget logo() {
    return Container(
      width: 80,
      height: 80,
      margin: EdgeInsets.all(16),
      alignment: Alignment.center,
      child: SvgPicture.asset('assets/logo.svg'),
    );
  }

  Widget appName() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      alignment: Alignment.center,
      child:FittedBox(
        child:  Text(
          'Ship Seller',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Color(blue),
              fontSize: MediaQuery.of(context).size.width > webRefWidth ? 32 : 24,
              ),
        ),
      ),
    );
  }

  Widget loginImage() {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 16),
      alignment: Alignment.center,
      child: SvgPicture.asset('assets/login_image.svg',
        width: min(Get.width, Get.height)/(1.3),
        height: min(Get.width, Get.height)/(1.3),),
    );
  }

  Widget emailInputField() {
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          margin: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          decoration: BoxDecoration(
              color: Color(white),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Color(yellow).withAlpha(100),
                  offset: Offset(0, 5),
                  blurRadius: 5,
                  spreadRadius: 0,
                )
              ]),
          child: TextFormField(
            controller: emailEditingController,
            cursorColor: Color(yellow),
            style: TextStyle(color: Color(blue), fontSize: 16),
            decoration: loginPageController.emailError.value
                ? InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Username',
                    hintStyle: TextStyle(
                        color: Color(black).withAlpha(100), fontSize: 16),
                    errorText: 'Email required',
                    errorStyle: TextStyle(
                        color: Color(blue).withOpacity(0.5), fontSize: 12))
                : InputDecoration(
                    hintText: 'Username',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                        color: Color(black).withAlpha(100), fontSize: 16)),
            maxLines: 1,
            onChanged: (value) {
              if (value.isNotEmpty) {
                loginPageController.emailError.value = false;
              } else {
                loginPageController.emailError.value = true;
              }
            },
          ),
        ));
  }

  Widget passwordInputField() {
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          margin: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          decoration: BoxDecoration(
              color: Color(white),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Color(yellow).withAlpha(100),
                  offset: Offset(0, 5),
                  blurRadius: 5,
                  spreadRadius: 0,
                )
              ]),
          child: TextFormField(
            controller: passwordEditingController,
            cursorColor: Color(yellow),
            style: TextStyle(color: Color(blue), fontSize: 16),
            decoration: loginPageController.passwordError.value
                ? InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Password',
                    hintStyle: TextStyle(
                        color: Color(black).withAlpha(100), fontSize: 16),
                    errorText: 'Password required',
                    errorStyle: TextStyle(
                        color: Color(blue).withOpacity(0.5), fontSize: 12))
                : InputDecoration(
                    hintText: 'Password',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                        color: Color(black).withAlpha(100), fontSize: 16)),
            maxLines: 1,
            onChanged: (value) {
              if (value.isNotEmpty) {
                loginPageController.passwordError.value = false;
              } else {
                loginPageController.passwordError.value = true;
              }
            },
          ),
        ));
  }

  Widget loginButton() {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16, top: 32, bottom: 16),
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: buttonColor,
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 5),
                  color: Color(blue).withOpacity(0.3),
                  blurRadius: 10)
            ]),
        child: FittedBox(child: Text(
          'Sign in',
          style: TextStyle(color: Color(white), fontSize: 16),
        ),),
      ),
      onTap: login,
    );
  }

  void login() async {

    if(mounted){
      setState((){
        buttonColor = Color(blue).withAlpha(100);
      });
    }

    if (_networkConnectivityController.connected.value) {
      if (emailEditingController.text.isEmpty ||
          passwordEditingController.text.isEmpty) {
        if (emailEditingController.text.isEmpty) {
          loginPageController.emailError.value = true;
          loginPageController.passwordError.value = true;
        }
      } else {
        loadingWidget('Logging in...');
        loginPageController
            .login(emailEditingController.text, passwordEditingController.text)
            .then((value) {
          Get.back();
          if (loginPageController.message.isEmpty) {
            Get.offAll(HomeUI());
          } else {
            alertBox('Error', loginPageController.message);
          }
        });
      }
    } else {
      alertBox('No Internet', 'Please check your internet connection!');
    }

    if(mounted){
      setState(() {
        buttonColor = Color(blue);
      });
    }

  }
}
