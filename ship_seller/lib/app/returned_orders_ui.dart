import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:ship_seller/app/home_controller.dart';
import 'package:ship_seller/services/connectivity.dart';
import 'package:ship_seller/utils/colors_themes.dart';
import 'package:ship_seller/utils/constants.dart';
import 'package:ship_seller/utils/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class ReturnedOrdersUI extends StatefulWidget {
  const ReturnedOrdersUI({Key? key}) : super(key: key);

  @override
  State<ReturnedOrdersUI> createState() => _ReturnedOrdersUIState();
}

class _ReturnedOrdersUIState extends State<ReturnedOrdersUI> {
  late HomeController homeController;
  late NetworkConnectivityController networkConnectivityController;

  @override
  void initState() {
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

    if (homeController.rOrders.isEmpty) {
      homeController.getAllReturnOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > webRefWidth ? Scaffold(
      appBar: AppBar(
        backgroundColor: Color(blueBg),
        title: Text(
          'Returns',
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
      body: body(),
    ) : Scaffold(
      body: body(),
    );
  }

  Widget body(){
    return Stack(
      children: [
        returnOrder(),
        Obx(() =>
        homeController.rOrders.isEmpty && !homeController.rLoading.value
            ? Positioned(
          bottom: 16,
          right: 16,
          child: InkWell(
            onTap: () {
              if (networkConnectivityController.connected.value) {
                homeController.getAllReturnOrders();
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

  Widget returnOrder() {
    double dimension = min(Get.width, Get.height) / 4;

    return Column(
      children: [
        allOrdersAndPage(),
        Expanded(
          flex: 1,
          child: Obx(() => homeController.rLoading.value
              ? Center(
                  child: Lottie.asset('assets/animations/final_loading.json',
                      width: dimension, height: dimension),
                )
              : homeController.rOrders.isNotEmpty
                  ? returns()
                  : error()),
        ),
      ],
    );
  }

  Widget returns() {
    return Obx(() => RefreshIndicator(
          color: Color(blue),
          onRefresh: () async {
            if (networkConnectivityController.connected.value) {
              homeController.getAllReturnOrders();
            } else {
              alertBox('Error', 'No internet connection!');
            }
          },
          child: ListView.builder(
            physics:
                BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            itemCount: homeController.rOrders.length,
            itemBuilder: (context, index) {
              return returnOrderDetails(index);
            },
          ),
        ));
  }

  Widget returnOrderDetails(int index) {
    double spacing = 4;
    return Container(
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width > webRefWidth ? webRefWidth + MediaQuery.of(context).size.width * (0.1) : webRefWidth + 0,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Color(boxBlueLow).withAlpha(15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(boxBlueHigh).withOpacity(0.5))),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                status(homeController.rOrders[index].status),
                Divider(),
                detailsBox('Order ID ', homeController.rOrders[index].id.toString()),
                SizedBox(height: spacing,),
                detailsBox('Reason ', homeController.rOrders[index].reason),
                SizedBox(height: spacing,),
                detailsBox('Payment Method ', homeController.rOrders[index].payment.toUpperCase(), color: Color(boxBlueHigh)),
                // detailsBox('Status ', homeController.rOrders[index].status),
                Divider(),
                detailsBox(
                    'Customer Name ', homeController.rOrders[index].cName.toString()),
                SizedBox(height: spacing,),
                detailsBoxPhone('Customer Phone ',
                    homeController.rOrders[index].cPhone.toString()),
                SizedBox(height: spacing,),
                detailsBoxEmail('Customer Email ',
                    homeController.rOrders[index].cEmail.toString()),
                SizedBox(height: spacing,),
                detailsBox('Customer Address', homeController.rOrders[index].cAdd),
                Divider(),
                detailsBox(
                    'Pickup Person Name ', homeController.rOrders[index].pName.toString()),
                SizedBox(height: spacing,),
                detailsBoxPhone('Pickup Person Phone ',
                    homeController.rOrders[index].pPhone.toString()),
                SizedBox(height: spacing,),
                detailsBoxEmail('Pickup Person Email ',
                    homeController.rOrders[index].pEmail.toString()),
                SizedBox(height: spacing,),
                detailsBox('Pickup Location', homeController.rOrders[index].pAdd),
                SizedBox(height: spacing,),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget status(String status){
    return Container(
      child: Center(
        child: Text(status, style: TextStyle(color: Color(boxBlueHigh), fontSize: 20),),
      ),
    );
  }

  Widget detailsBox(String title, String data,
      {Color color = const Color(black)}) {
    return Container(
      child: RichText(
          text: TextSpan(
              style: TextStyle(fontSize: 12, color: Color(black)),
              children: [
            TextSpan(text: title + ': ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: data, style: TextStyle(color: color))
          ])),
    );
  }

  Widget detailsBoxPhone(String title, String data) {
    return Container(
      child: Row(
        children: [
          Text(
            title + ': ',
            style: TextStyle(
                fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                var temp = await launch('tel://${data}');
              },
              child: Text(
                data,
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget detailsBoxEmail(String title, String data) {
    return Container(
      child: Row(
        children: [
          Text(
            title + ': ',
            style: TextStyle(
                fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                var temp = await launch('mailto:${data}');
              },
              child: Text(
                data,
                style: TextStyle(
                    fontSize: 12, color: Colors.blue, fontStyle: FontStyle.italic),
              ),
            ),
          )
        ],
      ),
    );
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
        'All Returns',
        style: TextStyle(
            color: Color(black), fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget nextPrev() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            child: Obx(() => homeController.rLoading.value
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
              if (!homeController.rLoading.value) {
                getNextReturnOrders(false);
              }
            },
          ),
          Obx(() => Text(
                '${homeController.rPage}/${homeController.rTotal}',
                style:
                    TextStyle(color: Color(black).withAlpha(200), fontSize: 12),
              )),
          InkWell(
            child: Obx(() => homeController.rLoading.value
                ? Container(
                    child: Icon(Icons.arrow_forward_ios_rounded,
                        color: Color(black).withAlpha(100)),
                  )
                : Container(
                    child: Icon(Icons.arrow_forward_ios_rounded,
                        color: Color(black)),
                  )),
            onTap: () {
              if (!homeController.rLoading.value) {
                getNextReturnOrders(true);
              }
            },
          )
        ],
      ),
    );
  }

  void getNextReturnOrders(bool next) {
    if (networkConnectivityController.connected.value) {
      if (next) {
        homeController.rNextPage();
      } else {
        homeController.rPrevPage();
      }
    } else {
      alertBox('Error', 'No internet connection!');
    }
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
}
