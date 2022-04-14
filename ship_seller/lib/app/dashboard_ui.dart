import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:ship_seller/app/home_controller.dart';
import 'package:ship_seller/app/single_order/single_order.dart';
import 'package:ship_seller/app/single_order/track_webview.dart';
import 'package:ship_seller/services/connectivity.dart';
import 'package:ship_seller/utils/colors_themes.dart';
import 'package:ship_seller/utils/constants.dart';
import 'package:ship_seller/utils/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboradUI extends StatefulWidget {
  const DashboradUI({Key? key}) : super(key: key);

  @override
  State<DashboradUI> createState() => _DashboradUIState();
}

class _DashboradUIState extends State<DashboradUI> {
  late HomeController homeController;
  late NetworkConnectivityController networkConnectivityController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    try {
      homeController = Get.find();
    } catch (e) {
      homeController = Get.put(HomeController());
    }

    try {
      networkConnectivityController = Get.find();
    } catch (e) {
      networkConnectivityController = Get.put(NetworkConnectivityController());
    }

    if (homeController.orders.isEmpty) {
      homeController.getAllOrders().then((value) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        dashboard(),
        Obx(() =>
            homeController.orders.isEmpty && !homeController.dLoading.value
                ? Positioned(
                    bottom: 16,
                    right: 16,
                    child: InkWell(
                      onTap: () {
                        if (networkConnectivityController.connected.value) {
                          homeController.getAllOrders();
                        } else {
                          alertBox('Error', 'No internet connection!');
                        }
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Color(white)),
                        child: Icon(
                          Icons.refresh,
                          color: Color(blue),
                        ),
                      ),
                    ),
                  )
                : SizedBox())
      ],
    );
  }

  Widget dashboard() {
    double dimension = min(Get.width, Get.height) / 4;

    return Column(
      children: [
        MediaQuery.of(context).size.width > webRefWidth
            ? SizedBox()
            : userNameHi(),
        Obx(() => countBlocks()),
        allOrdersAndPage(),
        Expanded(
          flex: 1,
          child: Obx(() => homeController.dLoading.value
              ? Center(
                  child: Lottie.asset('assets/animations/final_loading.json',
                      width: dimension, height: dimension),
                )
              : homeController.orders.isNotEmpty
                  ? orders()
                  : error()),
        ),
      ],
    );
  }

  Widget error() {
    double dimension = min(Get.width, Get.height) / 6;

    return Container(
      color: Colors.white,
      child: Center(
        child: Lottie.asset('assets/animations/final_error.json',
            width: dimension, height: dimension),
      ),
    );
  }

  Widget userNameHi() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Hi ' + homeController.name,
              style: TextStyle(
                  color: Color(black),
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            width: Get.width * (0.5),
            height: 4,
            color: Color(black).withOpacity(0.3),
          )
        ],
      ),
    );
  }

  Widget countBlocks() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Wrap(
        children: [
          block('orders in count', homeController.orders.length, boxBlueLow),
          block(
              'orders on way',
              homeController.orders
                  .where((p0) => p0.deliveredDate == 'ON WAY')
                  .toList()
                  .length,
              boxBlueMedium),
          block(
              'orders delivered',
              homeController.orders
                  .where((p0) => p0.deliveredDate != 'ON WAY')
                  .toList()
                  .length,
              boxBlueHigh),
        ],
      ),
    );
  }

  Widget block(String title, int count, int color) {
    return Obx(() => Container(
          margin: EdgeInsets.symmetric(horizontal: 2),
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
              color: Color(color),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Color(color).withAlpha(50),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: Offset(0, 2),
                )
              ]),
          child: Column(children: [
            homeController.dLoading.value
                ? Text(
                    '---',
                    style: TextStyle(
                        color: Color(white),
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  )
                : Text(
                    count.toString(),
                    style: TextStyle(
                        color: Color(white),
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
            Text(
              title,
              style: TextStyle(color: Color(white), fontSize: 12),
            ),
          ]),
        ));
  }

  Widget allOrdersAndPage() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [allOrdersTag(), nextPrev()],
      ),
    );
  }

  Widget allOrdersTag() {
    return Container(
      margin: EdgeInsets.all(16),
      alignment: Alignment.centerLeft,
      child: Text(
        'All Orders',
        style: TextStyle(
            color: Color(black), fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget orders() {
    return Obx(() => RefreshIndicator(
          color: Color(blue),
          onRefresh: () async {
            if (networkConnectivityController.connected.value) {
              homeController.getAllOrders();
            } else {
              alertBox('Error', 'No internet connection!');
            }
          },
          child: ListView.builder(
              physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              itemCount: homeController.orders.length,
              itemBuilder: (context, index) {
                return order(index);
              }),
        ));
  }

  Widget order(int index) {
    return InkWell(
      onTap: () {
        Get.to(() => SingleOrderUI(order: homeController.orders[index]));
      },
      child: LayoutBuilder(
        builder: (context, size) {
          return Container(
            height: 100,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Stack(children: [
              Positioned(
                left: 0,
                right: 0,
                top: 14,
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8)),
                      color: Color(white),
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(0, -2),
                            blurRadius: 2,
                            spreadRadius: 1,
                            color: Color(black).withAlpha(50))
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      text('Id', homeController.orders[index].id.toString()),
                      SizedBox(
                        height: 4,
                      ),
                      text(
                          'Product', homeController.orders[index].product.name),
                      SizedBox(
                        height: 4,
                      ),
                      text('Customer', homeController.orders[index].custName),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 14,
                child: ClipPath(
                  clipper: SectionClipper(),
                  child: Container(
                    alignment: Alignment.centerRight,
                    decoration:
                        BoxDecoration(color: Color(boxBlueHigh), boxShadow: [
                      BoxShadow(
                          offset: Offset(0, -2),
                          blurRadius: 2,
                          spreadRadius: 1,
                          color: Color(black).withAlpha(50))
                    ]),
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        iconText(homeController.orders[index].paymentMethod,
                            Icons.attach_money_rounded),
                        SizedBox(
                          height: 4,
                        ),
                        iconText(homeController.orders[index].city, Icons.map),
                        SizedBox(
                          height: 4,
                        ),
                        iconText(homeController.orders[index].deliveredDate,
                            Icons.place),
                      ],
                    ),
                  ),
                ),
              ),
              homeController.orders[index].custPhone.length == 0
                  ? SizedBox()
                  : Positioned(
                      left: size.maxWidth * (0.45),
                      child: GestureDetector(
                        onTap: () async {
                          var temp = await launch(
                              'tel://${homeController.orders[index].custPhone}');
                        },
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Color(white),
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(0, -2),
                                    blurRadius: 2,
                                    spreadRadius: 1,
                                    color: Color(black).withAlpha(50))
                              ]),
                          child: Row(
                            children: [
                              Icon(
                                Icons.phone,
                                color: Color(black),
                                size: 12,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                homeController.orders[index].custPhone,
                                style: TextStyle(
                                    color: Color(boxBlueHigh), fontSize: 12),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
            ]),
          );
        },
      ),
    );
  }

  Widget text(String title, String data) {
    if (data.length >= 15) {
      List<String> temp = data.split(' ');
      temp.removeWhere((element) => element == ' ' || element.isEmpty);

      if (temp.length > 2) {
        data = '';
        for (int i = 0; i < 2; i++) {
          try {
            data += temp[i].substring(0, 1).toUpperCase();
          } on Exception catch (e) {
            data += '-';
          }
        }
      } else {
        data = data.substring(0, 13);
      }
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
              color: Color(black), fontSize: 12, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 4,
        ),
        Text(
          data,
          style: TextStyle(
            color: Color(black),
            fontSize: 12,
          ),
        )
      ],
    );
  }

  Widget iconText(String data, IconData icon) {
    if (data.length >= 15) {
      List<String> temp = data.split(' ');

      if (temp.length > 2) {
        data = '';
        for (int i = 0; i < 2; i++) {
          data += temp[i].substring(0, 1).toUpperCase();
        }
      } else {
        data = data.substring(0, 15);
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Color(white),
          size: 12,
        ),
        SizedBox(width: 4),
        Text(
          data.toUpperCase(),
          style: TextStyle(color: Color(white), fontSize: 12),
        ),
      ],
    );
  }

  Widget nextPrev() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            child: Obx(() => homeController.dLoading.value
                ? Container(
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Color(black).withAlpha(100),
                    ),
                  )
                : Container(
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Color(black),
                    ),
                  )),
            onTap: () {
              if (!homeController.dLoading.value) {
                getNextAlerts(false);
              }
            },
          ),
          Obx(() => Text(
                '${homeController.page}/${homeController.total}',
                style:
                    TextStyle(color: Color(black).withAlpha(200), fontSize: 12),
              )),
          InkWell(
            child: Obx(() => homeController.dLoading.value
                ? Container(
                    child: Icon(Icons.arrow_forward_ios_rounded,
                        color: Color(black).withAlpha(100)),
                  )
                : Container(
                    child: Icon(Icons.arrow_forward_ios_rounded,
                        color: Color(black)),
                  )),
            onTap: () {
              if (!homeController.dLoading.value) {
                getNextAlerts(true);
              }
            },
          )
        ],
      ),
    );
  }

  void getNextAlerts(bool next) {
    if (networkConnectivityController.connected.value) {
      if (next) {
        homeController.nextPage();
      } else {
        homeController.prevPage();
      }
    } else {
      alertBox('Error', 'No internet connection!');
    }
  }
}

class SectionClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.moveTo(size.width * (0.4), 0);

    path.lineTo(size.width * (0.6), size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
