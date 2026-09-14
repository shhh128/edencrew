import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import '../models/daily_price.dart';

class DailyPriceService {
  // 종목별 이미 조회 페이지 저장해 중복 요청 방지
  final Map<String, Map<int, List<DailyPrice>>> _pageCache = {};
  // 종목별 실제 마지막 페이지 저장
  final Map<String, int> _lastPages = {};

  Future<List<DailyPrice>> fetchDailyPrices({
    required String code,
    required int pageCount,
  }) async {
    final List<DailyPrice> result = [];

    // 기간에 필요한 페이지 수만큼 순서대로 조회
    // 일별 시세는 한 페이지에 약 10거래일
    for (int page = 1; page <= pageCount; page++) {
      final int? lastPage = _lastPages[code];

      // lastPage보다 뒤 페이지 요청x
      if (lastPage != null && page > lastPage) {
        break;
      }

      // 캐시된 페이지 있으면 재사용, 없을 때만 API 요청
      final List<DailyPrice> prices =
          _pageCache[code]?[page] ?? await _fetchPage(code, page);

      result.addAll(prices);
    }

    return result;
  }

  Future<List<DailyPrice>> _fetchPage(
    String code,
    int page,
  ) async {
    // 네이버 일별 시세 API 주소 생성
    final Uri uri = Uri.https(
      'finance.naver.com',
      '/item/sise_day.naver',
      {
        'code': code,
        'page': '$page',
      },
    );

    final http.Response response = await http.get(
      uri,
      headers: {
        'User-Agent': 'Mozilla/5.0',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('일별 시세 조회 실패: ${response.statusCode}');
    }

    // 숫자와 HTML 구조만 사용하므로 latin1로 안전하게 읽음
    final String responseText = latin1.decode(response.bodyBytes);
    // 문자열 형태 HTML > 탐색 가능 Document 변환
    final Document document = html_parser.parse(responseText);

    _lastPages[code] = _parseLastPage(document);

    // 시세 있는 표의 각 행 > DailyPrice 모델 변환
    final List<DailyPrice> prices = document
        .querySelectorAll('table.type2 tr')
        .map(_parseRow)
        .whereType<DailyPrice>()
        .toList();

    _pageCache.putIfAbsent(code, () => {});
    _pageCache[code]![page] = prices;

    return prices;
  }

  DailyPrice? _parseRow(Element row) {
    final List<Element> cells = row.querySelectorAll('td');

    // 날짜, 종가, 전일비, 시가, 고가, 저가, 거래량
    if (cells.length < 7) {
      return null;
    }

    final String rawDate = cells[0].text.trim();

    if (rawDate.isEmpty) {
      return null;
    }

    final Element changeCell = cells[2];
    final String changeHtml = changeCell.innerHtml.toLowerCase();

    int changeAmount = _parseNumber(changeCell.text);

    // 하락 표시 있는 경우 전일 대비 값에 - 적용
    if (changeHtml.contains('down') || changeHtml.contains('nv01')) {
      changeAmount = -changeAmount;
    }

    return DailyPrice(
      localDate: rawDate.replaceAll('.', ''),
      closePrice: _parseNumber(cells[1].text),
      changeAmount: changeAmount,
      openPrice: _parseNumber(cells[3].text),
      highPrice: _parseNumber(cells[4].text),
      lowPrice: _parseNumber(cells[5].text),
      volume: _parseNumber(cells[6].text),
    );
  }

  int _parseLastPage(Document document) {
    final String? href = document
        .querySelector('td.pgRR a')
        ?.attributes['href'];

    if (href == null) {
      return 1;
    }

    final Uri uri = Uri.parse(href);
    return int.tryParse(uri.queryParameters['page'] ?? '') ?? 1;
  }

  int _parseNumber(String value) {
    // 쉼표 포함 문자열에서 숫자만 추출
    final String numbers = value.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    return int.tryParse(numbers) ?? 0;
  }
}