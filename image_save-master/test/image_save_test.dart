import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_save/image_save.dart';

void main() {
  const MethodChannel channel = MethodChannel('image_save');
  Uint8List? data;

  setUp(() async {
    Response<List<int>> res = await Dio().get<List<int>>(
        "http://img.youai123.com/1507615921-5474.gif",
        options: Options(responseType: ResponseType.bytes));
    data = Uint8List.fromList(res.data!);
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
    data = null;
  });

  test('saveImage', () async {
    expect(await ImageSave.saveImage(data, "gif", albumName: "demo"), isTrue);
  });

  test('saveImageToSandbox', () async {
    expect(await ImageSave.saveImageToSandbox(data, "test.gif"), isTrue);
  });
}
