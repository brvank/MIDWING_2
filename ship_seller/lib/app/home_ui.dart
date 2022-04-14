import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ship_seller/app/dashboard_ui.dart';
import 'package:ship_seller/app/home_controller.dart';
import 'package:ship_seller/app/home_networking.dart';
import 'package:ship_seller/app/map_ui.dart';
import 'package:ship_seller/app/profile_ui.dart';
import 'package:ship_seller/app/returned_orders_ui.dart';
import 'package:ship_seller/app/search_order_ui.dart';
import 'package:ship_seller/app/webMapUI.dart';
import 'package:ship_seller/authorization/login_page_ui.dart';
import 'package:ship_seller/utils/colors_themes.dart';
import 'package:ship_seller/utils/constants.dart';
import 'package:ship_seller/utils/models/order.dart';
import 'package:ship_seller/utils/widgets.dart';

import 'single_order/single_order.dart';

class HomeUI extends StatefulWidget {
  const HomeUI({Key? key}) : super(key: key);

  @override
  State<HomeUI> createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  late HomeController homeController;
  bool hovered = false;
  double width = 0;
  late TextEditingController searchTextEditingController;

  late int selectedIndex;

  List<Widget> widgets = [
    DashboradUI(),
    MapUI(),
    SearchOrderUI(),
    ReturnedOrdersUI(),
    ProfileUI(),
  ];



  @override
  void initState() {
    super.initState();

    init();
  }

  void init() {
    try {
      homeController = Get.find();
    } catch (e) {
      homeController = Get.put(HomeController());
    }

    homeController.initForProfile();
    searchTextEditingController = TextEditingController();

    selectedIndex = 0;
  }

  void onItemTapped(index) {
    if (mounted) {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return MediaQuery.of(context).size.width > webRefWidth
        ? webView()
        : mobileView();

  }

  Widget mobileView() {
    return SafeArea(
      child: Scaffold(
        body: Dashboard(),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(boxBlueHigh).withAlpha(50),
          elevation: 0,
          selectedItemColor: Color(blue),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                size: 40,
                color: Color(boxBlueHigh),
              ),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_return),
              label: 'Return',
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

  Widget webView() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(blueBg),
        title: Container(
          padding: EdgeInsets.all(4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  logo(),
                  appName(),
                  searchBox(),
                ],
              ),
              Row(
                children: [
                  returnScreen(),
                  SizedBox(
                    width: 16,
                  ),
                  personLogo(),
                ],
              ),
            ],
          ),
        ),
      ),
      body: webDashBoardBody(),
    );
  }

  Widget searchBox() {
    return Container(
      child: Center(
        child: Container(
          width: 250,
          height: 36,
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: 16),
          padding: EdgeInsets.only(bottom: 6, left: 16, right: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  expands: false,
                  controller: searchTextEditingController,
                  cursorColor: Color(yellow),
                  style: TextStyle(color: Color(yellow), fontSize: 16),
                  decoration: InputDecoration(
                      hintText: 'Search by order id',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                          color: Color(black).withAlpha(100), fontSize: 16)),
                  maxLines: 1,
                  onFieldSubmitted: (value){
                    search();
                  },
                ),
              ),
              InkWell(
                  child: Icon(
                Icons.search,
                color: Color(blue),
                    size: 24,
              ),
              onTap: (){
                    search();
              },)
            ],
          ),
        ),
      ),
    );
  }

  Future<void> search() async {
    if(searchTextEditingController.text.isEmpty){
      return;
    }
    loadingWidget('Please wait...');
    HomeNetworking().searchOrder(searchTextEditingController.text).then((res){
      Get.back();

      try{
        if(res == 0){
          alertBox('Oops!', 'Order ID not found!');
        }else if(res == 1){
          alertBox('Error', 'Something went wrong!');
        }else{
          Order order = HomeController().createOrder(res.data['data']);
          Get.to(SingleOrderUI(order: order));
        }
      }catch(e){
        alertBox('Error', 'Something went wrong!');
      }
    });
  }

  Widget returnScreen() {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hovered = true;
          width = 60;
        });
      },
      onExit: (_) {
        setState(() {
          hovered = false;
          width = 0;
        });
      },
      child: GestureDetector(
        onTap: () {
          Get.to(ReturnedOrdersUI());
        },
        child: Chip(
          backgroundColor: Colors.white,
          avatar: Icon(
            Icons.assignment_return,
            color: Color(blue),
          ),
          label: AnimatedContainer(
              curve: Curves.easeIn,
              width: width,
              duration: Duration(milliseconds: 200),
              child: Container(
                child: Center(
                  child: FittedBox(
                    child: Text(
                      'RETURNS',
                      style: TextStyle(color: Color(blue)),
                    ),
                  ),
                ),
              )),
        ),
      ),
    );
  }

  Widget webDashBoardBody() {
    return Row(
      children: [
        Expanded(flex: 1, child: DashboradUI()),
        Expanded(
            flex: MediaQuery.of(context).size.width > 1300
                ? 3
                : MediaQuery.of(context).size.width > 700
                    ? 2
                    : 1,
            child: WebMapUI())
      ],
    );
  }

  Widget personLogo() {
    String profileImagePath = 'assets/male.svg';
    return Container(
      margin: EdgeInsets.all(4),
      alignment: Alignment.center,
      child: PopupMenuButton(
          child: SvgPicture.asset(
            profileImagePath,
            height: 30,
            width: 30,
          ),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                  child: Container(
                alignment: Alignment.center,
                child: Text(
                  homeController.name,
                  style: TextStyle(
                      color: Color(black),
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              )),
              PopupMenuItem(
                  child: Container(
                alignment: Alignment.center,
                child: Text(
                  homeController.email,
                  style: TextStyle(
                      color: Color(black),
                      fontSize: 14,
                      fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              )),
              PopupMenuItem(
                  child: GestureDetector(
                child: Container(
                  alignment: Alignment.center,
                  margin:
                      EdgeInsets.only(left: 16, right: 16, top: 32, bottom: 16),
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
                  child: FittedBox(
                    child: Text(
                      'Logout',
                      style: TextStyle(color: Color(white), fontSize: 16),
                    ),
                  ),
                ),
                onTap: logout,
              ))
            ];
          }),
    );
  }

  Widget logo() {
    return Container(
      width: 30,
      height: 30,
      margin: EdgeInsets.all(4),
      alignment: Alignment.center,
      child: SvgPicture.asset('assets/logo.svg'),
    );
  }

  Widget appName() {
    return MediaQuery.of(context).size.width < 600 ? SizedBox() : Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      alignment: Alignment.center,
      child: FittedBox(
        child: Text(
          'Ship Seller',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(blue),
            fontSize: 24,
          ),
        ),
      ),
    );
  }

  Widget Dashboard() {
    return widgets[selectedIndex];
  }

  Future<void> logout() async {
    var result =
        await confirmationDialogBox('Logout', 'Do you really want to logout?');
    if (result != null) {
      if (result == true) {
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
