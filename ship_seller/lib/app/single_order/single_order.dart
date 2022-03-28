import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ship_seller/app/home_controller.dart';
import 'package:ship_seller/app/single_order/single_order_map.dart';
import 'package:ship_seller/app/single_order/track_webview.dart';
import 'package:ship_seller/utils/colors_themes.dart';
import 'package:ship_seller/utils/models/order.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:ship_seller/utils/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class SingleOrderUI extends StatefulWidget {
  Order order;
  SingleOrderUI({Key? key, required this.order}) : super(key: key);

  @override
  State<SingleOrderUI> createState() => _SingleOrderUIState();
}

class _SingleOrderUIState extends State<SingleOrderUI> {
  late HomeController homeController;
  late String url;

  bool loading = false;
  late ll.LatLng latLng1, latLng2;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    try {
      homeController = Get.find();
    } catch (e) {
      homeController = Get.put(HomeController());
    }

    getLatLong();
  }

  Future<void> getLatLong() async {
    setState(() {
      loading = true;
    });

    var response = await homeController.prepareLatLong(widget.order.city);
    if (response != null) {
      latLng1 = response;
    }

    response = await homeController.prepareLatLong(widget.order.pickup.city);
    if (response != null) {
      latLng2 = response;
    }

    url = await homeController.track();

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: singleOrder()),
    );
  }

  Widget singleOrder() {
    return Column(
        children: [productId(), map(), Expanded(flex: 1, child: details())]);
  }

  Widget productId() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Order #' + widget.order.product.id.toString(),
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

  Widget map() {
    return Container(
      margin: EdgeInsets.all(16),
      width: min(Get.width, Get.height) * (0.8),
      height: min(Get.width, Get.height) * (0.8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Color(white),
          boxShadow: [
            BoxShadow(
                color: Color(black).withAlpha(150),
                blurRadius: 5,
                spreadRadius: 1,
                offset: Offset(1, 1))
          ]),
      child: loading
          ? Center(
              child: CircularProgressIndicator(color: Color(blue)),
            )
          : latLng1 == null || latLng2 == null
              ? SizedBox()
              : SingleOrderMapUI(
                  latLng1: latLng1,
                  latLng2: latLng2,
                ),
    );
  }

  Widget details() {
    return ListView(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              tractThisOrder(),
              delivery(),
            ],
          ),
        ),
        detail('Product id: ', widget.order.product.id.toString()),
        detail('Product name: ', widget.order.product.name),
        detail('Customer name: ', widget.order.custName),
        detail(
            'Customer address: ',
            widget.order.addr +
                ', ' +
                widget.order.city +
                ', ' +
                widget.order.state),
        detail('Delivery status: ', widget.order.deliveredDate),
        detail('Payment status: ', widget.order.paymentStatus),
        detail('Payment method: ', widget.order.paymentMethod),
      ],
    );
  }

  Widget detail(String title, String data) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
                color: Color(black), fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: 4,
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: Text(
                data,
                style: TextStyle(
                  color: Color(black),
                  fontSize: 14,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget tractThisOrder() {
    return TextButton(
        onPressed: () {
          if (url != null) {
            if (url.isNotEmpty) {
              Get.to(TrackWebViewUI(url: url));
            } else {
              dialogBox('Error', 'Tracking details not available!');
            }
          } else {
            dialogBox('Error', 'Tracking details not available!');
          }
        },
        child: loading ? Text('---', style: TextStyle(color: Colors.grey),) : Text(
          'Track Order',
          style: TextStyle(
              color: Color(blue),
              fontSize: 18,
              decoration: TextDecoration.underline),
        ));
  }

  Widget delivery() {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Color(blue),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.phone,
              color: Color(white),
              size: 16,
            ),
            SizedBox(
              width: 4,
            ),
            Text(
              'Contact ',
              style: TextStyle(color: Color(white), fontSize: 16),
            )
          ],
        ),
      ),
      onTap: () async {
        var temp = await launch('tel://${widget.order.custPhone}');
      },
    );
  }
}
