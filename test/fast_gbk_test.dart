import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    Dio testClient;

    setUp(() {
      String baseUrl = "http://www.newsmth.net";
      final String defaultAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) "
          "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.101 Safari/537.36";
      const int secondsUnit = 1000;
      final int connectTimeOut = 10 * secondsUnit;
      final int receiveTimeOut = 15 * secondsUnit;

      BaseOptions options = BaseOptions();
      options.connectTimeout = connectTimeOut;
      options.receiveTimeout = receiveTimeOut;
      options.baseUrl = baseUrl;
      options.headers.addAll({
        HttpHeaders.userAgentHeader: defaultAgent,
      });
      options.responseDecoder = gbkDecoder;
      Dio client = Dio(options);
      client.options.headers.addAll({
        "X-Requested-With": "XMLHttpRequest",
      });

      testClient = client;
    });

    test('decoder test, Get GBK file', () async {
      var begin = DateTime.now().millisecondsSinceEpoch;

      File testFile1 = File("./test/GbkFile/gbk_test_file_1.txt");
      String result1 = testFile1.readAsStringSync(encoding: gbk);
      print(result1);

      File testFile2 = File("./test/GbkFile/gbk_test_file_2.txt");
      String result2 = testFile2.readAsStringSync(encoding: gbk);
      print(result2);

      var end = DateTime.now().millisecondsSinceEpoch;
      print("gbk.decode cost ${end - begin}ms, responseLength = ${result1.length + result2.length}");
    });

    test('Get GBK Html response', () async {
      //String url = "http://www.newsmth.net/nForum/#!article/OurEstate/2611032?ajax";
      String url = "http://www.newsmth.net/";
      const String defaultAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) "
          "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.101 Safari/537.36";

      var httpClient = HttpClient();

      HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
      request.headers.set(HttpHeaders.userAgentHeader, defaultAgent);
      request.headers.add("X-Requested-With", "XMLHttpRequest");
      HttpClientResponse response = await request.close();
      print(response.headers);
      response.listen(
        (data) {
          print("onData");
          print(data.runtimeType);
          String result = gbk.decode(data);
          print("result = " + result);
        },
        onDone: () {
          print("onDone");
        },
        onError: (e) {
          print("onError");
        },
      );

      httpClient.close();
    }, skip: true);

    test('Get GBK Html response by dio client', () async {
      //gbk.decode cost 86ms, responseLength = 41333
      String url = "/nForum/article/Tennis/1119045?ajax";
      //gbk.decode cost 88ms, responseLength = 46345
      //String url = "/nForum/article/Shopping/105645?ajax";
      var response = await testClient.get<String>(url);
      print(response.data);
    }, skip: true);
  });
}

String gbkDecoder (List<int> responseBytes, RequestOptions options,
    ResponseBody responseBody) {
  var begin = DateTime.now().millisecondsSinceEpoch;
  String result =  gbk.decode(responseBytes);
  var end = DateTime.now().millisecondsSinceEpoch;
  print("gbk.decode cost ${end - begin}ms, responseLength = ${responseBytes.length}");
  return result;
}