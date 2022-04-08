import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ship_seller/app/home_controller.dart';
import 'package:ship_seller/authorization/login_page_ui.dart';
import 'package:ship_seller/utils/colors_themes.dart';
import 'package:ship_seller/utils/widgets.dart';

class ProfileUI extends StatefulWidget {
  const ProfileUI({Key? key}) : super(key: key);

  @override
  State<ProfileUI> createState() => _ProfileUIState();
}

class _ProfileUIState extends State<ProfileUI> {

  late HomeController homeController;

  late String profileImagePath;


  @override
  void initState() {
    super.initState();

    try{
      homeController = Get.find();
    }catch(e){
      homeController = Get.put(HomeController());
    }

    profileImagePath = 'assets/male.svg';

  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => homeController.pLoading.value ? Center(
      child: CircularProgressIndicator(
        color: Colors.red,
        strokeWidth: 5,
      ),
    ): SingleChildScrollView(child: Column(
      children: [
        personLogo(),
        userDetails(),
        logoutButton()
      ],
    )));
  }

  Widget personLogo(){
    return Container(
      margin: EdgeInsets.all(16),
      alignment: Alignment.center,
      child: SvgPicture.asset(profileImagePath, height: 200, width: 200,),
    );
  }

  Widget userDetails(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Color(white),
        boxShadow: [
          BoxShadow(
            color: Color(blue).withAlpha(100), spreadRadius: 1, blurRadius: 5
          )
        ]
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(homeController.name, style: TextStyle(color: Color(black), fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(homeController.email, style: TextStyle(color: Color(black), fontSize: 14, fontStyle: FontStyle.italic), textAlign: TextAlign.center,),
          )
        ],
      ),
    );
  }

  Widget logoutButton() {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16, top: 32, bottom: 16),
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Color(blue),
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 5),
                  color: Color(blue).withOpacity(0.3),
                  blurRadius: 10)
            ]),
        child: FittedBox(child: Text(
          'Logout',
          style: TextStyle(color: Color(white), fontSize: 16),
        ),),
      ),
      onTap: logout,
    );
  }

  Future<void> logout() async {

    var result = await confirmationDialogBox('Logout', 'Do you really want to logout?');
    if(result != null){
      if(result == true){
        loadingWidget('Logging out...');
        await Future.delayed(Duration(seconds: 1));
        SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
        await sharedPreferences.clear();
        Get.offAll(LoginPageUI());
      }
    }
  }
}
