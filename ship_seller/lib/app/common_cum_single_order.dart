import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:ship_seller/app/common_orders.dart';
import 'package:ship_seller/app/home_controller.dart';
import 'package:ship_seller/app/single_order/single_order.dart';
import 'package:ship_seller/utils/colors_themes.dart';
import 'package:ship_seller/utils/constants.dart';

class CommonSingleOrderUI extends StatefulWidget {
  String city;
  CommonSingleOrderUI({Key? key, required this.city}) : super(key: key);

  @override
  State<CommonSingleOrderUI> createState() => _CommonSingleOrderUIState();
}

class _CommonSingleOrderUIState extends State<CommonSingleOrderUI> {
  late HomeController homeController;
  Widget? common;

  @override
  void initState() {
    super.initState();

    try {
      homeController = Get.find();
    } catch (e) {
      homeController = Get.put(HomeController());
    }

    homeController.selectedOrder.value = -1;
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > webRefWidth
        ? webView()
        : mobileView();
  }

  Widget webView() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(blueBg),
        title: Text(
          widget.city,
          style: TextStyle(color: Color(blue), fontSize: 20),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 32,
            color: Color(blue),
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: commonOrder(),
    );
  }

  Widget mobileView() {
    return CommonOrdersUI(city: widget.city);
  }

  Widget commonOrder() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: CommonOrdersUI(
            city: widget.city
          ),
        ),
        Expanded(
            flex: MediaQuery.of(context).size.width > 1300
                ? 3
                : MediaQuery.of(context).size.width > 700
                    ? 2
                    : 1,
            child: Obx(() => homeController.selectedOrder.value == -1
                ? noneSelected()
                : common!))
      ],
    );
  }

  Widget noneSelected() {
    double dimension = min(Get.width, Get.height) / 4;

    return Container(
      color: Colors.white,
      child: Center(
        child: Lottie.asset('assets/animations/please_select.json',
            width: dimension, height: dimension),
      ),
    );
  }
}
