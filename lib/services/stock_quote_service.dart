import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../models/stock_quote.dart';
import '../models/stock_quote_dto.dart';

// 관심종목 여러 개의 실시간 시세 한 번에 요청
class StockQuoteService {
  Future<Map<String, StockQuote>> fetchQuotes(
    List<String> stockCodes,
  ) async {
    // 관심종목 없으면 API 호출하지 않음
    if (stockCodes.isEmpty) {
      return {};
    }

    final String query = 'SERVICE_ITEM:${stockCodes.join(',')}';

    final Uri uri = Uri.https(
      'polling.finance.naver.com',
      '/api/realtime',
      {
        'query': query
      }
    );

    final http.Response response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('실시간 시세 요청에 실패했습니다.');
    }

    final String responseText = latin1.decode(response.bodyBytes);

    final Map<String, dynamic> data = 
        jsonDecode(responseText) as Map<String, dynamic>;

    final Map<String, dynamic> result =
        data['result'] as Map<String, dynamic>;
      
    final List<dynamic> areas =
        result['areas'] as List<dynamic>;

    if (areas.isEmpty) {
      return {};
    }

    final Map<String, dynamic> area =
        areas.first as Map<String, dynamic>;

    final List<dynamic> items =
        area['datas'] as List<dynamic>;

    final Map<String, StockQuote> quotes = {};

    for (final dynamic item in items) {
      final StockQuote quote = StockQuoteDto.fromJson(
        item as Map<String, dynamic>,
      ).toModel();

      quotes[quote.code] = quote;
    }

    return quotes;
  }
}