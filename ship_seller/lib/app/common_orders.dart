import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ship_seller/app/dashboard_ui.dart';
import 'package:ship_seller/app/home_controller.dart';
import 'package:ship_seller/app/single_order/single_order.dart';
import 'package:ship_seller/utils/colors_themes.dart';
import 'package:ship_seller/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class CommonOrdersUI extends StatefulWidget {
  String city;
  Function? function;
  CommonOrdersUI({Key? key, required this.city, this.function})
      : super(key: key);

  @override
  State<CommonOrdersUI> createState() => _CommonOrdersUIState();
}

class _CommonOrdersUIState extends State<CommonOrdersUI> {
  late HomeController homeController;
  bool loading = true;

  @override
  void initState() {
    try {
      homeController = Get.find();
    } catch (e) {
      homeController = Get.put(HomeController());
    }

    homeController.filterOrders(widget.city).then((value) {
      print(widget.city);
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            MediaQuery.of(context).size.width > webRefWidth
                ? SizedBox()
                : cityName(),
            Expanded(
              flex: 1,
              child: loading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Color(blue),
                      ),
                    )
                  : filteredOrders(),
            )
          ],
        ),
      ),
    );
  }

  Widget cityName() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              widget.city,
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

  Widget filteredOrders() {
    return ListView.builder(
      itemCount: homeController.filteredOrders.length,
      itemBuilder: (context, index) {
        print(homeController.filteredOrders[index].id);
        print(homeController.filteredOrders[index].city);
        print(homeController.filteredOrders[index].custName);
        return order(index);
      },
    );
  }

  Widget order(int index) {
    return InkWell(
      onTap: () {
        if (widget.function != null) {
          widget.function!(homeController.filteredOrders[index]);
        }

        if (MediaQuery.of(context).size.width > 500) {
          homeController.selectedOrder.value = index;
        } else {
          Get.to(
              () => SingleOrderUI(order: homeController.filteredOrders[index]));
        }
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
                      text('Id',
                          homeController.filteredOrders[index].id.toString()),
                      SizedBox(
                        height: 4,
                      ),
                      text('Product',
                          homeController.filteredOrders[index].product.name),
                      SizedBox(
                        height: 4,
                      ),
                      text('Customer',
                          homeController.filteredOrders[index].custName),
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
                        iconText(
                            homeController.filteredOrders[index].paymentMethod,
                            Icons.attach_money_rounded),
                        SizedBox(
                          height: 4,
                        ),
                        iconText(homeController.filteredOrders[index].city,
                            Icons.map),
                        SizedBox(
                          height: 4,
                        ),
                        iconText(
                            homeController.filteredOrders[index].deliveredDate,
                            Icons.place),
                      ],
                    ),
                  ),
                ),
              ),
              homeController.filteredOrders[index].custPhone.length == 0
                  ? SizedBox()
                  : Positioned(
                      left: size.maxWidth * (0.45),
                      child: GestureDetector(
                        onTap: () async {
                          var temp = await launch(
                              'tel://${homeController.filteredOrders[index].custPhone}');
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
                                homeController.filteredOrders[index].custPhone,
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
}
