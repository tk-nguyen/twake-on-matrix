import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluffychat/data/network/dio_client.dart';
import 'package:fluffychat/data/network/interceptor/dynamic_url_interceptor.dart';
import 'package:fluffychat/di/base_di.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

class NetworkDI extends BaseDI {

  static const tomServerUrlInterceptorName = 'tomServerDynamicUrlInterceptor';
  static const tomServerDioName = 'tomServerDioName';

  static const identityServerUrlInterceptorName = 'identityDynamicUrlInterceptor';
  static const identityServerDioName = 'identityServerName';

  static const acceptHeaderDefault = 'application/json';
  static const contentTypeHeaderDefault = 'application/json';

  @override
  void setUp(GetIt get) {
    _bindBaseOption(get);
    _bindInterceptor(get);
    _bindDio(get);
    _bindDioClient(get);
  }

  void _bindBaseOption(GetIt get) {
    final headers = <String, dynamic>{
      HttpHeaders.acceptHeader: acceptHeaderDefault,
      HttpHeaders.contentTypeHeader: contentTypeHeaderDefault
    };

    get.registerLazySingleton<BaseOptions>(() => BaseOptions(headers: headers));
  }

  void _bindInterceptor(GetIt get) {
    get.registerLazySingleton(
      () => DynamicUrlInterceptors(),
      instanceName: tomServerUrlInterceptorName,
    );
    get.registerLazySingleton(
      () => DynamicUrlInterceptors(),
      instanceName: identityServerUrlInterceptorName,
    );
  }

  void _bindDio(GetIt get) {
    _bindDioForTomServer(get);
    _bindDioForIdentityServer(get);
  }

  void _bindDioForTomServer(GetIt get) {
    final dio = Dio(get.get<BaseOptions>());
    dio.interceptors.add(get.get<DynamicUrlInterceptors>(instanceName: tomServerUrlInterceptorName));
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    }
    get.registerLazySingleton<Dio>(() => dio, instanceName: tomServerDioName);
  }

  void _bindDioForIdentityServer(GetIt get) {
    final dio = Dio(get.get<BaseOptions>());
    dio.interceptors.add(get.get<DynamicUrlInterceptors>(instanceName: identityServerUrlInterceptorName));
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    }
    get.registerLazySingleton<Dio>(() => dio, instanceName: identityServerDioName);
  }

  void _bindDioClient(GetIt get) {
    get.registerLazySingleton(() => DioClient(get.get<Dio>()));
  }

  @override
  String get scopeName => 'networkScope';
}