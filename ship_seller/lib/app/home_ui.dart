import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ship_seller/app/dashboard_ui.dart';
import 'package:ship_seller/app/home_controller.dart';
import 'package:ship_seller/app/map_ui.dart';
import 'package:ship_seller/app/profile_ui.dart';
import 'package:ship_seller/utils/colors_themes.dart';

class HomeUI extends StatefulWidget {
  const HomeUI({ Key? key }) : super(key: key);

  @override
  State<HomeUI> createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {

  late HomeController homeController;

  late int selectedIndex;

  late List<Widget> widgets;

  @override
  void initState() {
    super.initState();

    init();
  }

  void init(){
    try{
      homeController = Get.find();
    }catch(e){
      homeController = Get.put(HomeController());
    }

    homeController.initForProfile();

    selectedIndex = 0;

    widgets = [
      DashboradUI(),
      MapUI(),
      ProfileUI()
    ];
  }

  void onItemTapped(index){
    if(mounted){
      setState(() {
        selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text('Ship Seller', style: TextStyle(color: Color(white),)),
        //   backgroundColor: Color(blue),
        // ),
        body: Dashboard(),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(boxBlueHigh).withAlpha(50),
          elevation: 0,
          selectedItemColor: Color(blue),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_rounded),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          type: BottomNavigationBarType.fixed,
          currentIndex: selectedIndex,
          onTap: onItemTapped,
        ),
      ),
    );
  }

  Widget Dashboard(){
    return widgets[selectedIndex];
  }
}