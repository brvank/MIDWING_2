import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ship_seller/utils/colors_themes.dart';

Future<dynamic> dialogBox(String title, String message, {Color color = Colors.red}){
  return Get.defaultDialog(
    title: title,
    titleStyle: TextStyle(
      color: color,
      fontSize: 16
    ),
    content: Column(
      children: [
        Text(message, style: TextStyle(color: Color(black), fontSize: 14),),
        Container(
          alignment: Alignment.centerRight,
          child: TextButton(onPressed: (){Get.back();}, child: Text('OK', style: TextStyle(color: Color(blue), fontSize: 14),)),
        )
      ],
    )
  );
}

Future<dynamic> confirmationDialogBox(String title, String message, {Color color = const Color(red)}){
  return Get.defaultDialog(
      title: title,
      titleStyle: TextStyle(
          color: color,
          fontSize: 16
      ),
      content: Column(
        children: [
          Text(message, style: TextStyle(color: Color(black), fontSize: 14),),
          Container(
            margin: EdgeInsets.only(top: 16),
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(onPressed: (){Get.back();}, child: Text('CANCEL', style: TextStyle(color: Color(blue), fontSize: 14),)),
                TextButton(onPressed: (){Get.back(result: true);}, child: Text('OK', style: TextStyle(color: Color(blue), fontSize: 14),))
              ],
            ),
          )
        ],
      )
  );
}

Future<dynamic> loadingWidget(String title){
  return Get.defaultDialog(
    onWillPop: () async {
      return false;
    },
    title: title,
    titleStyle: TextStyle(
        color: Color(blue),
        fontSize: 16
    ),
    content: Center(
      child: CircularProgressIndicator(
        color: Color(blue),
        strokeWidth: 1,
      ),
    ),
    barrierDismissible: false
  );
}