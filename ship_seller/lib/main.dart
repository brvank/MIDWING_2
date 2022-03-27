import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ship_seller/authorization/login_page_ui.dart';
import 'package:ship_seller/app/home_ui.dart';
import 'package:ship_seller/services/connectivity.dart';
import 'package:ship_seller/utils/colors_themes.dart';
import 'package:ship_seller/utils/constants.dart';

void main() {
  runApp(shipSeller());
}

class NetworkConnectivityBinding extends Bindings{

  @override
  void dependencies() {
    Get.lazyPut<NetworkConnectivityController>(() => NetworkConnectivityController());

  }


}

class shipSeller extends StatefulWidget {
  const shipSeller({Key? key}) : super(key: key);

  @override
  State<shipSeller> createState() => _shipSellerState();
}

class _shipSellerState extends State<shipSeller> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: NetworkConnectivityBinding(),
      debugShowCheckedModeBanner: false,
      title: 'Ship Seller',
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    goToMainPage();
  }

  void goToMainPage() async {
    await Future.delayed(Duration(seconds: 1));
    SharedPreferences preferences = await SharedPreferences.getInstance();

    try {
      var token = preferences.getString(TOKEN);

      if (token != null) {
        if(mounted){
          Get.offAll(HomeUI());
        }
      } else {
        if (mounted) {
          Get.offAll(LoginPageUI(), transition: Transition.fadeIn, duration: Duration(seconds: 1));
        }
      }
    } catch (e) {
      preferences.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Colors.white,
      child: Center(
        child: SvgPicture.asset('assets/logo.svg'),
      ),
    ));
  }
}
