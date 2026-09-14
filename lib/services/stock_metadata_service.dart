import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/stock_metadata.dart';

class StockMetadataService {
  Future<StockMetadata> fetchMetadata(String code) async {
    final Uri uri = Uri.parse(
      'https://stock.naver.com/api/securityFe/api/fchart/domestic/stock/$code',
    );

    final http.Response response = await http.get(
      uri,
      headers: {
        'User-Agent': 'Mozilla/5.0',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('종목 정보 조회 실패: ${response.statusCode}');
    }

    final Map<String, dynamic> json = jsonDecode(
      utf8.decode(response.bodyBytes),
    ) as Map<String, dynamic>;

    return StockMetadata.fromJson(json);
  }
}