import 'package:flutter/material.dart';

class DashboradUI extends StatefulWidget {
  const DashboradUI({ Key? key }) : super(key: key);

  @override
  State<DashboradUI> createState() => _DashboradUIState();
}

class _DashboradUIState extends State<DashboradUI> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home'),
    );
  }
}