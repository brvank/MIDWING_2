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
  var pLoading = false.obs;
  String name = '', email = '';

  Future<void> initForProfile() async {
    pLoading.value = true;
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
    pLoading.value = false;
  }

  //for orders

  HomeNetworking homeNetworking = HomeNetworking();

  var orders = <Order>[].obs;
  var filteredOrders = <Order>[].obs;
  var dLoading = false.obs;
  var dError = false.obs;
  var page = 1.obs;
  var total = 0.obs;

  var dListStatus = 0;
  var mapStatus = 0;

  void nextPage() {
    if(page.value >= total.value){
      page.value = 1;
    }else{
      page++;
    }
    getAllOrders();
  }

  void prevPage() {
    if(page.value <= 1){
      page.value = total.value;
    }else{
      page--;
    }
    getAllOrders();
  }

  Future<void> filterOrders(String city) async {
    filteredOrders.clear();

    filteredOrders.value = orders.where((p0) {
      return p0.city == city;
    }).toList();
  }

  Future<void> getAllOrders() async {
    if (dLoading.value) return;

    orders.clear();
    dLoading.value = true;
    dError.value = false;

    try {
      await Future.delayed(Duration(seconds: 1));
      dio.Response response = await homeNetworking.getAllOrders(page.value);
      if (response.statusCode == 200) {
        page.value = response.data['meta']['pagination']['current_page'];
        total.value = response.data['meta']['pagination']['total_pages'];

        int len = response.data['data'].length;

        for (int i = 0; i < len; i++) {
          orders.add(createOrder(response.data['data'][i]));
        }

        dListStatus++;
        dListStatus = dListStatus%2;
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
    int id = response['id'] ?? 0;
    int channelId = response['channel_id'] ?? 0;
    String custName = response['customer_name'] ?? '---';
    String custPhone = response['customer_phone'] ?? '---';
    if (response['customer_address'] == null) {
      response['customer_address'] = [];
    }
    List<String> latLngList =
        response['customer_address'].toString().split(' ');
    String addr = '';
    for (int i = 0; i < 2; i++) {
      if (i < latLngList.length) {
        addr += latLngList[i];
        if (i == 0) addr += ' ';
      } else {
        continue;
      }
    }
    String city = response['customer_city'] ?? '---';
    String state = response['customer_state'] ?? '---';
    String paymentStatus = response['payment_status'] ?? '---';
    String deliveredDate =
        response['delivered_date'] == null ? 'ON WAY' : 'DELIVERED';
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
    if (response == null || response.length == 0) {
      response[0] = [
        {'id': 123456, 'name': 'Product', 'status': 'DELIVERED'}
      ];
    }
    Product product = Product(
        id: response['id'] ?? 0,
        name: response['name'] ?? '---',
        status: response['status'] ?? '---');
    return product;
  }

  Pickup createPickup(var response) {
    int id = response['id'] ?? 0;
    List<String> latLngList =
        response['customer_address'].toString().split(' ');
    String addr = '';
    for (int i = 0; i < 2; i++) {
      if (i < latLngList.length) {
        addr += latLngList[i];
        if (i == 0) addr += ' ';
      } else {
        continue;
      }
    }
    String city = response['city'] ?? '---';
    String state = response['state'] ?? '---';
    String country = response['country'] ?? '---';
    String pincode = response['pin_code'] ?? '---';
    String delvName = response['delvName'] ?? '---';
    String delvPhone = response['delvPhone'] ?? '---';
    Pickup pickup = Pickup(
        id: id,
        address: addr,
        city: city,
        state: state,
        country: country,
        pincode: pincode,
        delvName: delvName,
        delvPhone: delvPhone);
    return pickup;
  }

  //for logout
  Future<void> logout() async {
    loadingWidget('Logging out...');
    await Future.delayed(Duration(seconds: 1));
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    Get.offAll(LoginPageUI());
  }

  //location data
  var latLngList = <ll.LatLng>[].obs;

  Future<dynamic> prepareLatLong(String city) async {
    try {
      dio.Response response = await homeNetworking.getLatLong(city);

      if (response.data['data'].isNotEmpty) {
        var temp = response.data['data'][0];
        ll.LatLng latLng = ll.LatLng(temp['latitude'], temp['longitude']);
        return latLng;
      }
    } catch (e) {
      return;
    }
  }

  //tracking data
  Future<dynamic> track() async {
    try {
      dio.Response response = await homeNetworking.track();

      if (response.data.isNotEmpty) {
        String temp = response.data['tracking_data']['track_url'];
        return temp;
      } else {
        return;
      }
    } catch (e) {
      print('error');
      print(e.toString());
      return;
    }
  }
}

class SafeValues {
  static Pickup pickup = Pickup(
      id: 123,
      address: 'Sector 3A',
      city: 'Varanasi',
      state: 'Uttar Pradesh',
      country: 'India',
      pincode: '221004',
      delvName: 'John David',
      delvPhone: '9876543210');
  static Product product = Product(id: 456, name: 'Box', status: 'status');
  static Order order = Order(
      id: 789,
      channelId: 1234321,
      custName: 'Frady Dam',
      custPhone: '9854763210',
      addr: 'Sector 16A',
      city: 'Gorakhpur',
      state: 'Uttar Pradesh',
      paymentStatus: 'Pending',
      deliveredDate: '30/04/2022',
      paymentMethod: 'COD',
      product: product,
      pickup: pickup);
}
