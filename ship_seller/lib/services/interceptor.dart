import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ship_seller/utils/constants.dart';

class DioInterceptor extends Interceptor{

  @override
  Future<dynamic> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try{
      var sharedPreferences = await SharedPreferences.getInstance();
      var token = sharedPreferences.getString(TOKEN);
      print('token = ${token}');
      options.headers.addAll({'Authorization':'Bearer ' + token!});
    }catch(e){
      var sharedPreferences = await SharedPreferences.getInstance();
      var temp = await sharedPreferences.setString(TOKEN, "");
    }
    return super.onRequest(options, handler);
  }

  @override
  Future<dynamic> onError(DioError err, ErrorInterceptorHandler handler) async {
    return super.onError(err, handler);
  }

  @override
  Future<dynamic> onResponse(Response response, ResponseInterceptorHandler handler) async {
    print(response.realUri.toString());
    print('response received');
    print(response.data);
    return super.onResponse(response, handler);
  }
}
