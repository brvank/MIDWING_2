import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:lottie/lottie.dart' as lottie;
import 'package:ship_seller/app/common_orders.dart';
import 'package:ship_seller/app/dashboard_ui.dart';
import 'package:ship_seller/app/home_controller.dart';
import 'package:ship_seller/app/single_order/single_order.dart';
import 'package:ship_seller/utils/colors_themes.dart';
import 'package:ship_seller/utils/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class WebMapUI extends StatefulWidget {
  const WebMapUI({Key? key}) : super(key: key);

  @override
  State<WebMapUI> createState() => _WebMapUIState();
}

class _WebMapUIState extends State<WebMapUI> {
  late HomeController homeController;
  // late Image placeHolder, error;
  double zoom = 3.0;

  @override
  void initState() {
    super.initState();

    try {
      homeController = Get.find();
    } catch (e) {
      homeController = Get.put(HomeController());
    }

    homeController.mapController = MapController();

    // placeHolder = Image.asset('assets/login_image.png');
    // error = Image.asset('assets/login_image.png');
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance
        ?.addPostFrameCallback((_){
      setState(() {

      });
    });
    return mapContainer();
  }

  Widget mapContainer() {
    return Stack(
      children: [
        map(),
        Positioned(
          child: compass(),
          right: 16,
          top: 16,
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: zoomControl(),
        ),
        Obx(() => homeController.mLoading.value
            ? loading()
            : homeController.mError.value
            ? error()
            : SizedBox())
      ],
    );
  }

  Widget loading() {
    double dimension = min(Get.width, Get.height) / 4;

    return Container(
      color: Colors.white,
      child: Center(
        child: lottie.Lottie.asset('assets/animations/map_loading.json',
            width: dimension, height: dimension),
      ),
    );
  }

  Widget error() {
    double dimension = min(Get.width, Get.height) / 4;

    return Container(
      color: Colors.white,
      child: Center(
        child: lottie.Lottie.asset('assets/animations/final_error.json',
            width: dimension, height: dimension),
      ),
    );
  }

  Widget compass() {
    BorderSide borderSide = BorderSide(color: Color(white), width: 2);
    return Container(
        padding: EdgeInsets.all(4),
        alignment: Alignment.center,
        child: InkWell(
          child: Icon(
            Icons.my_location_rounded,
            color: Color(red),
            size: 24,
          ),
          onTap: () {
            homeController.mapController
                .moveAndRotate(ll.LatLng(28.7041, 77.1025), zoom, 0);
          },
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
          // borderRadius: BorderRadius.circular(32),
          border: Border(
              top: borderSide,
              bottom: borderSide,
              left: borderSide,
              right: borderSide),
        ));
  }

  Widget zoomControl(){
    BorderSide borderSide = BorderSide(color: Color(blue), width: 2);
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
              border: Border.all(color: Color(blue), width: 2),
              color: Color(mapYellow)
          ),
          padding: EdgeInsets.all(4),
          child: InkWell(
            child: Icon(
              Icons.add,
              size: 24,
              color: Color(blue),
            ),
            onTap: (){
              if(homeController.mapController.zoom >= 15){
                return;
              }
              homeController.mapController.move(homeController.mapController.center, homeController.mapController.zoom + 0.5);
            },
          ),
        ),
        SizedBox(height: 4,),
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
              border: Border(left: borderSide, right: borderSide, bottom: borderSide, top: borderSide),
              color: Color(mapYellow)
          ),
          padding: EdgeInsets.all(4),
          child: InkWell(
            child: Icon(
              Icons.remove,
              size: 24,
              color: Color(blue),
            ),
            onTap: (){
              if(homeController.mapController.zoom <= 2){
                return;
              }
              homeController.mapController.move(homeController.mapController.center, homeController.mapController.zoom - 0.5);
            },
          ),
        )
      ],
    );
  }

  Widget map() {
    return FlutterMap(
      options: MapOptions(
        center: ll.LatLng(28.7041, 77.1025),
        zoom: zoom,
      ),
      mapController: homeController.mapController,
      layers: [
        TileLayerOptions(
          backgroundColor: Color(blue).withAlpha(50),
          keepBuffer: 0,
          urlTemplate:
          "https://api.mapbox.com/styles/v1/stsanary/cl18s6nki001w14pll3kthqdt/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic3RzYW5hcnkiLCJhIjoiY2wxOHNrNnBjMGd6dzNqbW14dXV3ODM4ZCJ9.oyjCkxkSVs59i_jyMndOqQ",
          additionalOptions: {
            'accessToken':
            'pk.eyJ1Ijoic3RzYW5hcnkiLCJhIjoiY2wxOHNrNnBjMGd6dzNqbW14dXV3ODM4ZCJ9.oyjCkxkSVs59i_jyMndOqQ',
            'id': 'mapbox.mapbox-streets-v8'
          },
        ),
        MarkerLayerOptions(
          markers: homeController.markers,
        ),
      ],
    );
  }
}