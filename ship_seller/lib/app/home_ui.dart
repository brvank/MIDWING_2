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

    homeController.init();

    selectedIndex = 2;

    widgets = [
      DashboradUI(),
      MapUI(),
      ProfileUI()
    ];
  }

  void onItemTapped(index){
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ship Seller', style: TextStyle(color: Color(white),)),
        backgroundColor: Color(blue),
      ),
      body: Dashboard(),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(blue),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded),
            label: 'Map',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.purple,
          ),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }

  Widget Dashboard(){
    return widgets[selectedIndex];
  }
}