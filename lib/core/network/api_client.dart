import 'package:dio/dio.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> healthCheck() {
    return _dio.get<dynamic>('/health');
  }
}
