import 'dart:convert'; // API가 보내준 JSON 문자열을 Dart 데이터로 변환

import 'package:http/http.dart' as http; // 인터넷으로 API 요청 전송

import '../models/stock_search_result.dart'; // DTO, 모델 사용

// 검색 API 관련 작업
class StockSearchService {
  Future<List<StockSearchResult>> search(String keyword) async {
    final String trimmedKeyword = keyword.trim(); // trim 검색어 앞뒤 공백 없앰

    if (trimmedKeyword.isEmpty) {
      return [];
    }

    final Uri uri = Uri.https(
      'ac.stock.naver.com',
      '/ac', // 검색 자동완성 API 경로
      {
        'q': trimmedKeyword, // 사용자 입력 검색어
        'target': 'stock,ipo,index,marketindicator', // 검색할 데이터 종류
      },
    );

    final http.Response response = await http.get(uri); // 해당 주소로 데이터 요청

    // 네이버 응답
    if (response.statusCode != 200) {
      // == 200 요청 성공
      throw Exception('검색 요청에 실패했습니다.');
    }

    // 응답 > JSON으로
    final Map<String, dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    // 검색 결과 목록
    final List<dynamic> items = data['items'] as List<dynamic>? ?? [];

    // 변환 코드
    return items
        .map(
          (item) => StockSearchDto.fromJson(item as Map<String, dynamic>),
        ) // 각 JSON 데이터 > StockSearchDto
        .where((item) => item.isDomesticStock) // 국내 주식 6자리
        .map((item) => item.toModel()) // DTO > StockSearchResult
        .toList() // 최종 결과들을 하나의 목록으로
        ;
  }
}
