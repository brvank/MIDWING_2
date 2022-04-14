import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ship_seller/app/home_controller.dart';
import 'package:ship_seller/app/home_networking.dart';
import 'package:ship_seller/app/single_order/single_order_map.dart';
import 'package:ship_seller/app/single_order/track_webview.dart';
import 'package:ship_seller/utils/colors_themes.dart';
import 'package:ship_seller/utils/constants.dart';
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
  late var url;
  int id = 0;

  bool loading = false, error = false;
  late ll.LatLng latLng1, latLng2;

  @override
  void initState() {
    super.initState();

    try {
      homeController = Get.find();
    } catch (e) {
      homeController = Get.put(HomeController());
    }

    getLatLong();
    print('single order page ');
    print(widget.order.addr);
  }

  Future<void> getLatLong() async {
    id = widget.order.id;
    if (mounted) {
      setState(() {
        loading = true;
        error = false;
      });
    }

    var response = await homeController.prepareLatLong(widget.order.city);
    if (response != null) {
      latLng1 = response;
    } else {
      latLng1 = ll.LatLng(28.7041, 77.1025);
    }

    response = await homeController.prepareLatLong(widget.order.pickup.city);
    if (response != null) {
      latLng2 = response;
    } else {
      latLng2 = ll.LatLng(25.3176, 82.9739);
    }

    try {
      url = await homeController.track();
    } catch (e) {
      error = true;
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (widget.order.id != id) {
        getLatLong();
      }
    });

    return SafeArea(
      child: Scaffold(body: singleOrder()),
    );
  }

  Widget singleOrder() {
    // return MediaQuery.of(context).size.width > webRefWidth.toDouble() ? Column(
    //   children: [
    //     orderId(),
    //     Expanded(
    //       child: Row(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [map(), Expanded(flex: 1, child: details())]),
    //     )
    //   ],
    // ) : Column(
    //     children: [orderId(), map(), Expanded(flex: 1, child: details())]);
    return Column(
        children: [orderId(), map(), Expanded(flex: 1, child: details())]);
  }

  Widget orderId() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            child: SelectableText(
              'Order #' + widget.order.id.toString(),
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
      width: MediaQuery.of(context).size.height * (0.4),
      height: MediaQuery.of(context).size.height * (0.4),
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
        downloadInvoiceButton(),
      ],
    );
  }

  Widget downloadInvoiceButton() {
    return GestureDetector(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Color(blue),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.download_rounded,
                color: Color(white),
                size: 16,
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                'Download Invoice',
                style: TextStyle(color: Color(white), fontSize: 16),
              )
            ],
          ),
        ),
      ),
      onTap: () async {
        loadingWidget('Please wait...');
        HomeNetworking()
            .downloadLink([widget.order.id.toString()]).then((res) async {
          Get.back();
          try {
            if (res == 0) {
              alertBox('No Invoice', 'It is an incomplete order!');
            } else if (res == 1) {
              alertBox('Error', 'Something went wrong!');
            } else {
              bool link = res.data['is_invoice_created'];
              if (link) {
                await launch(res.data['invoice_url']);
              } else {
                alertBox('Oops!', 'It is an incomplete order!');
              }
            }
          } catch (e) {
            print(e.toString());
            print('error');
            alertBox('Error', 'Something went wrong!');
          }
        });
      },
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
        onPressed: () async {
          if (url != null) {
            if (url.isNotEmpty) {
              if (kIsWeb) {
                await launch(url);
              } else {
                Get.to(TrackWebViewUI(url: url));
              }
            } else {
              alertBox('Error', 'Tracking details not available!');
            }
          } else {
            alertBox('Error', 'Tracking details not available!');
          }
        },
        child: loading || error
            ? Text(
                '---',
                style: TextStyle(color: Colors.grey),
              )
            : Text(
                'Track Order',
                style: TextStyle(
                    color: Color(blue),
                    fontSize: 18,
                    decoration: TextDecoration.underline),
              ));
  }

  Widget delivery() {
    return widget.order.custPhone.isEmpty
        ? SizedBox()
        : GestureDetector(
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
                    'Contact',
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
