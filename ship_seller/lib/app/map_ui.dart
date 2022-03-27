import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:ship_seller/utils/widgets.dart';

class MapUI extends StatefulWidget {
  const MapUI({ Key? key }) : super(key: key);

  @override
  State<MapUI> createState() => _MapUIState();
}

class _MapUIState extends State<MapUI> {

  MapController mapController = MapController();
  late List<Marker> markers;
  late Image placeHolder, error;

  @override
  void initState() {
    super.initState();

    placeHolder = Image.asset('assets/login_image.svg');
    error = Image.asset('assets/login_image.svg');

    markers = [];

    mapController.onReady.then((value){
      setState(() {
        markers.add(Marker(
          width: 80.0,
          height: 80.0,
          point: ll.LatLng(28.7041,77.1025),
          builder: (ctx) =>
              Container(
                child: FlutterLogo(),
              ),
        ));
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return map();
  }

  Widget map(){
    return FlutterMap(
      options: MapOptions(
        center: ll.LatLng(28.7041,77.1025),
        zoom: 5.0,
      ),
      mapController: mapController,
      layers: [
        TileLayerOptions(
          urlTemplate: "https://api.mapbox.com/styles/v1/stsanary/cl18s6nki001w14pll3kthqdt/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic3RzYW5hcnkiLCJhIjoiY2wxOHNrNnBjMGd6dzNqbW14dXV3ODM4ZCJ9.oyjCkxkSVs59i_jyMndOqQ",
          additionalOptions: {
            'accessToken':'pk.eyJ1Ijoic3RzYW5hcnkiLCJhIjoiY2wxOHNrNnBjMGd6dzNqbW14dXV3ODM4ZCJ9.oyjCkxkSVs59i_jyMndOqQ',
            'id':'mapbox.mapbox-streets-v8'
          },
          placeholderImage: Image.asset('assets/login_image.svg').image,
          errorImage: Image.asset('assets/login_image.svg').image,

        ),
        MarkerLayerOptions(
          markers: markers,
        ),
      ],
    );
  }
}