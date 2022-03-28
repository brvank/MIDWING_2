import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:ship_seller/app/common_orders.dart';
import 'package:ship_seller/app/dashboard_ui.dart';
import 'package:ship_seller/app/home_controller.dart';
import 'package:ship_seller/app/single_order/single_order.dart';
import 'package:ship_seller/utils/colors_themes.dart';
import 'package:ship_seller/utils/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class MapUI extends StatefulWidget {
  const MapUI({Key? key}) : super(key: key);

  @override
  State<MapUI> createState() => _MapUIState();
}

class _MapUIState extends State<MapUI> {
  late HomeController homeController;
  MapController mapController = MapController();
  late List<Marker> markers;
  late Image placeHolder, error;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    try {
      homeController = Get.find();
    } catch (e) {
      homeController = Get.put(HomeController());
    }

    placeHolder = Image.asset('assets/login_image.png');
    error = Image.asset('assets/login_image.png');

    markers = [];

    mapController.onReady.then((value) {
      prepareMarkers();
    });
  }

  Future<void> prepareMarkers() async {
    setState(() {
      loading = true;
    });

    homeController.latLngList.clear();

    for(int i=0;i<homeController.orders.length;i++){

      var response = await homeController.prepareLatLong(homeController.orders[i].city);

      if(response != null){
        try{
          homeController.latLngList.add(response);


        }catch(e){
          print('error');
          print(e.toString());
        }
      }
    }

    for (int i = 0; i < homeController.latLngList.length; i++) {
      markers.add(Marker(
          point: homeController.latLngList[i],
          builder: (context) {
            return InkWell(
              child: Container(
                child: SvgPicture.asset(
                  'assets/waypoint.svg',
                ),
              ),
              onTap: () {
                Get.to(CommonOrdersUI(city: homeController.orders[i].city));
              },
            );
          }));
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        map(),
        Positioned(
          child: compass(),
          right: 16,
          top: 16,
        ),
        loading
            ? Center(
                child: CircularProgressIndicator(
                color: Color(blue),
              ))
            : SizedBox()
      ],
    );
  }

  Widget compass() {
    BorderSide borderSide = BorderSide(color: Color(white), width: 2);
    return InkWell(
      onTap: () {
        mapController.moveAndRotate(ll.LatLng(28.7041, 77.1025), 5.0, 0);
      },
      child: Container(
          width: 32,
          height: 32,
          child: Icon(
            Icons.my_location_rounded,
            color: Color(red),
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
          )),
    );
  }

  Widget map() {
    return FlutterMap(
      options: MapOptions(
        center: ll.LatLng(28.7041, 77.1025),
        zoom: 5.0,
      ),
      mapController: mapController,
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
          placeholderImage: placeHolder.image,
          errorImage: error.image,
        ),
        MarkerLayerOptions(
          markers: markers,
        ),
      ],
    );
  }
}
