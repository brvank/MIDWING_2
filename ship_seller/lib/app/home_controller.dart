import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ship_seller/app/home_networking.dart';
import 'package:ship_seller/authorization/login_page_ui.dart';
import 'package:ship_seller/utils/constants.dart';
import 'package:ship_seller/utils/models/order.dart';
import 'package:ship_seller/utils/widgets.dart';
import 'package:latlong2/latlong.dart' as ll;

class HomeController extends GetxController {
  var loading = false.obs;
  String name = '', email = '';

  Future<void> initForProfile() async {
    loading.value = true;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? first = sharedPreferences.getString(FIRST_NAME);
    String? last = sharedPreferences.getString(LAST_NAME);
    String? mail = sharedPreferences.getString(EMAIL);

    if (first != null && last != null) {
      name = first + ' ' + last;
    } else {
      name = '---';
    }

    if (mail != null) {
      email = mail;
    } else {
      email = '---';
    }
    loading.value = false;
  }

  //for orders

  HomeNetworking homeNetworking = HomeNetworking();

  var orders = <Order>[].obs;
  var filteredOrders = <Order>[].obs;
  var dLoading = false.obs;
  var dError = false.obs;
  var page = 0.obs;
  var total = 0.obs;

  void nextPage() {
    page++;
    getAllOrders();
  }

  void prevPage() {
    page--;
    getAllOrders();
  }

  Future<void> filterOrders(String city) async {
    filteredOrders.clear();

    filteredOrders.value = orders.where((p0){
      return p0.city == city;
    }).toList();
  }

  Future<void> getAllOrders() async {

    if(dLoading.value) return;

    orders.clear();
    dLoading.value = true;
    dError.value = false;

    try {
      dio.Response response = await homeNetworking.getAllOrders(page.value);
      if (response.statusCode == 200) {
        page.value = response.data['meta']['pagination']['current_page'];
        total.value = response.data['meta']['pagination']['total'];

        int len = response.data['data'].length;

        for (int i = 0; i < len; i++) {
          orders.add(createOrder(response.data['data'][i]));
          print(orders[i]);
        }
      }
    } on dio.DioError catch (e) {
      if (e.response!.statusCode == 401) {
        logout();
      } else {
        dError.value = true;
      }
    } catch (e) {
      print(e.toString());
      print('error');
      dError.value = true;
    }

    dLoading.value = false;
  }

  Order createOrder(var response) {
    print('order');
    int id = response['id'] ?? 0;
    int channelId = response['channel_id'] ?? 0;
    String custName = response['customer_name'] ?? '---';
    String custPhone = response['customer_phone'] ?? '---';
    List<String> latLngList = response['customer_address'].toString().split(' ');
    String addr = '';
    for (int i = 0; i < 2; i++) {
      if (i < latLngList.length) {
        addr += latLngList[i];
        if (i == 0) addr += ' ';
      } else {
        continue;
      }
    }
    print(latLngList.length);
    print(addr);
    String city = response['customer_city'] ?? '---';
    String state = response['customer_state'] ?? '---';
    String paymentStatus = response['payment_status'] ?? '---';
    String deliveredDate = response['delivered_date'] == null ? 'ON WAY' : 'DELIVERED';
    String paymentMethod = response['payment_method'] ?? 'COD';
    Product product = createProduct(response['products'][0]);
    Pickup pickup = createPickup(response['pickup_address_detail']);
    Order order = Order(
        id: id,
        channelId: channelId,
        custName: custName,
        custPhone: custPhone,
        addr: addr,
        city: city,
        state: state,
        paymentStatus: paymentStatus,
        deliveredDate: deliveredDate,
        paymentMethod: paymentMethod,
        product: product,
        pickup: pickup);
    return order;
  }

  Product createProduct(var response) {
    Product product = Product(
        id: response['id'] ?? 0, name: response['name'] ?? '---', status: response['status'] ?? '---');
    return product;
  }

  Pickup createPickup(var response) {
    print('pickup');
    int id = response['id'] ?? 0;
    List<String> latLngList = response['customer_address'].toString().split(' ');
    String addr = '';
    for (int i = 0; i < 2; i++) {
      if (i < latLngList.length) {
        addr += latLngList[i];
        if (i == 0) addr += ' ';
      } else {
        continue;
      }
    }
    print(latLngList.length);
    print(addr);
    String city = response['city'] ?? '---';
    String state = response['state'] ?? '---';
    String country = response['country'] ?? '---';
    String pincode = response['pin_code'] ?? '---';
    String delvName = response['delvName'] ?? '---';
    String delvPhone = response['delvPhone'] ?? '---';
    Pickup pickup = Pickup(id: id, address: addr, city: city, state: state, country: country, pincode: pincode, delvName: delvName, delvPhone: delvPhone);
    return pickup;
  }

  //for logout
  Future<void> logout() async {
    loadingWidget('Logging out...');
    await Future.delayed(Duration(seconds: 1));
    SharedPreferences sharedPreferences =
    await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    Get.offAll(LoginPageUI());
  }

  //location data
  var latLngList = <ll.LatLng>[].obs;

  Future<dynamic> prepareLatLong(String city) async {
    try{
          dio.Response response = await homeNetworking.getLatLong(city);

          if(response.data['data'].isNotEmpty){
            var temp = response.data['data'][0];
            ll.LatLng latLng = ll.LatLng(temp['latitude'], temp['longitude']);
            return latLng;
          }
        }catch(e){
          return;
        }
  }

  //tracking data
  Future<dynamic> track() async {

    try{
      dio.Response response = await homeNetworking.track();

      if(response.data.isNotEmpty){
        String temp = response.data['tracking_data']['track_url'];
        return temp;
      }else{
        return;
      }
    }catch(e){
      print('error');
      print(e.toString());
      return;
    }

  }

}
