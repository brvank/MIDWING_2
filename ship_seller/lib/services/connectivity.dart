import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class NetworkConnectivityController extends GetxController {
  var connected = true.obs;
  var exception = false.obs;

  final Connectivity _connectivity = Connectivity();
  @override
  void onInit() {
    checkConnectivity();
    _connectivity.onConnectivityChanged.listen((_connectivityResult) {
      _updateState(_connectivityResult);
    });
  }

  Future<void> checkConnectivity() async {
    var _connectivityResult;
    try {
      _connectivityResult = await _connectivity.checkConnectivity();
      _updateState(_connectivityResult);
    } catch (e) {
      print(e);
      exception.value = true;
    }
  }

  Future<void> _updateState(ConnectivityResult _connectivityResult) async {
    switch (_connectivityResult) {
      case ConnectivityResult.none:
        connected.value = true;
        await Future.delayed(Duration(milliseconds: 500));
        //NOTE: YOU CAN REMOVE THIS DELAY STATEMENT. SINCE I AM USING
        //THIS LOGIC IN MY PROJECT I USED IT TO HAVE SOME DELAY WHEN
        //USER TAPS ON NETWORK RETRY BUTTON(IN MY PROJECT APPLICATION)
        connected.value = false;
        break;
      case ConnectivityResult.mobile:
      case ConnectivityResult.wifi:
        connected.value = true; //await _checkIfWifiHasInternetAccess();
        break;
    }
    print('connection status' + connected.value.toString());
  }

  Future<bool> _checkIfWifiHasInternetAccess() async {
    try {
      var dio = Dio();
      var result = await dio.head('https://www.google.com/');
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void onClose() {}
}