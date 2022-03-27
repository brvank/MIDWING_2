import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ship_seller/utils/constants.dart';

class HomeController extends GetxController{

  var loading = false.obs;
  String name = '', email = '';

  Future<void> init() async {
    loading.value = true;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? first = sharedPreferences.getString(FIRST_NAME);
    String? last = sharedPreferences.getString(LAST_NAME);
    String? mail = sharedPreferences.getString(EMAIL);

    if(first != null && last != null){
      name = first + ' ' + last;
    }else{
      name = '---';
    }

    if(mail != null){
      email = mail;
    }else{
      email = '---';
    }
    loading.value = false;
  }

}