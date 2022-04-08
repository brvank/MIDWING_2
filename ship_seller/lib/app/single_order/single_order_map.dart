import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:ship_seller/utils/colors_themes.dart';

class SingleOrderMapUI extends StatefulWidget {
  ll.LatLng latLng1, latLng2;
  SingleOrderMapUI({Key? key, required this.latLng1, required this.latLng2})
      : super(key: key);

  @override
  State<SingleOrderMapUI> createState() => _MapUIState();
}

class _MapUIState extends State<SingleOrderMapUI> {
  MapController mapController = MapController();
  late List<Marker> markers;

  @override
  void initState() {
    super.initState();

    markers = [];

    mapController.onReady.then((value) {
      // prepareMarkers();

      if (widget.latLng1 != null) {
        markers.add(Marker(
            point: widget.latLng1,
            builder: (context) => Container(
                  child: SvgPicture.asset('assets/waypoint_red.svg'),
                )));
      }

      if (widget.latLng2 != null) {
        markers.add(Marker(
            point: widget.latLng2,
            builder: (context) => Container(
                  child: SvgPicture.asset('assets/waypoint.svg'),
                )));
      }
      if(mounted){
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        map(),
        Positioned(
          left: 16,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: Color(red),
                    size: 14,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    'Destinatioin',
                    style: TextStyle(
                      color: Color(black).withAlpha(150),
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: Color(blue),
                    size: 14,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    'Pickup Location',
                    style: TextStyle(
                      color: Color(black).withAlpha(150),
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        Positioned(
          child: compass(),
          right: 16,
          top: 16,
        ),
      ],
    );
  }

  Widget compass() {
    BorderSide borderSide = BorderSide(color: Color(white), width: 2);
    return InkWell(
      onTap: () {
        mapController.moveAndRotate(widget.latLng1, 4.0, 0);
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
        center: widget.latLng1,
        zoom: 4.0,
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
        ),
        MarkerLayerOptions(
          markers: markers,
        ),
      ],
    );
  }
}
