import 'package:dio/dio.dart';
import 'package:ship_seller/services/apis.dart';
import 'package:ship_seller/services/dio_instance.dart';

class LoginPageNetworking{

  Future<Response> login(String email, String password) async {

    DioInstance dioInstance = DioInstance();
    Dio dio = dioInstance.createDio();

    Map<String, dynamic> data = <String, dynamic>{};
    data.addAll({'email':email});
    data.addAll({'password': password});

    Response response = await dio.post(LOGIN, data: data);

    return response;

  }

}