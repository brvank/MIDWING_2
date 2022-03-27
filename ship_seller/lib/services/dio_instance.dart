import 'package:dio/dio.dart';
import 'package:ship_seller/services/apis.dart';

class DioInstance{

  Dio dio = Dio(BaseOptions(
      baseUrl: BASE_URL
  ));

  Dio createDio(){
    return dio;
  }

}
