import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ship_seller/authorization/login_page_networking.dart';
import 'package:ship_seller/utils/constants.dart';

class LoginPageController extends GetxController{

  var emailError = false.obs;
  var passwordError = false.obs;

  var message = '';

  late LoginPageNetworking loginPageNetworking;

  void initialize(){
    loginPageNetworking = LoginPageNetworking();
  }

  Future<void> login(String email, String password) async {

    message = '';

    try{
      dio.Response response = await loginPageNetworking.login(email, password);

      if(response.statusCode == 200){
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString(TOKEN, response.data[TOKEN]);
        sharedPreferences.setInt(ID, response.data[ID]);
        sharedPreferences.setString(FIRST_NAME, response.data[FIRST_NAME]);
        sharedPreferences.setString(LAST_NAME, response.data[LAST_NAME]);
        sharedPreferences.setString(EMAIL, response.data[EMAIL]);
      }else if(response.statusCode == 400){
        message = 'Invalid email or password!';
      }else{
        message = 'Something went wrong!\nPlease check your internet connection.';
      }
    }on dio.DioError catch(e){
      try {
        if(e.response!.statusCode == 400){
          message = 'Invalid email or password!';
        }else{
          message = 'Something went wrong!\nPlease check your internet connection.';
        }
      }catch (e) {
        message = 'Something went wrong!\nPlease check your internet connection.';
      }
    }on SocketException {
      message = 'Network problem!\nPlease check your internet connection';
    }catch(e){
      print(e);
      message = 'Something went wrong!';
    }

  }

}