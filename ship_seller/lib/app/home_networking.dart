import 'package:dio/dio.dart';
import 'package:ship_seller/services/apis.dart';
import 'package:ship_seller/services/dio_instance.dart';
import 'package:ship_seller/services/interceptor.dart';

class HomeNetworking{

  Future<Response> getAllOrders(int page) async {

    DioInstance dioInstance = DioInstance();
    Dio dio = dioInstance.createDio();
    dio.interceptors.add(DioInterceptor());

    Response response = await dio.get(ORDERS, queryParameters: {'page':page});

    return response;

  }

  Future<Response> getAllReturnOrders(int page) async {

    DioInstance dioInstance = DioInstance();
    Dio dio = dioInstance.createDio();
    dio.interceptors.add(DioInterceptor());

    Response response = await dio.get(RETURNS, queryParameters: {'page':page});

    return response;

  }

  Future<Response> getLatLong(String place) async {

    Dio dio = Dio();

    String url = 'http://api.positionstack.com/v1/forward?access_key=372b25811dce4b9e220a1164ac789427&query=' + place;

    Response response = await dio.get(url);

    return response;

  }

  Future<Response> track() async {

    DioInstance dioInstance = DioInstance();
    Dio dio = Dio();
    dio.interceptors.add(DioInterceptor());
    
    Response response = await dio.get('https://apiv2.shiprocket.in/v1/external/courier/track/shipment/191686343');

    return response;

  }

  Future<dynamic> downloadLink(List<String> ids) async {

      DioInstance dioInstance = DioInstance();
      Dio dio = dioInstance.createDio();
      dio.interceptors.add(DioInterceptor());

      print(ids);
      print(ids.length);
      var response;
      try {
        response = await dio.post(INVOICE,  data: {'ids':ids});
      } on DioError catch(e){
        if(!e.response!.data['is_invoice_created']){
          return 0;
        }else{
          return 1;
        }
      }catch(e){
        return 1;
      }

      return response;
  }

  Future<dynamic> searchOrder(String id) async {

    DioInstance dioInstance = DioInstance();
    Dio dio = dioInstance.createDio();
    dio.interceptors.add(DioInterceptor());

    var response;
    try {
      response = await dio.get(SEARCH + id);
    } on DioError catch(e){
      if(e.response!.statusCode == 400){
        return 0;
      }
    }catch(e){
      return 1;
    }

    return response;
  }

}