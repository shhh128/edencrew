// 화면용
class StockSearchResult {
  // 데이터 만들 때
  const StockSearchResult({
    required this.id,
    required this.code,
    required this.name,
    required this.market,
  });

  // 보관할 실제 값
  final String id;
  final String code;
  final String name;
  final String market;
}

// 네이버 API 응답용
class StockSearchDto {
  const StockSearchDto({
    required this.code,
    required this.name,
    required this.typeCode,
    required this.nationCode,
    required this.category,
  });

  final String code;
  final String name;
  final String typeCode;
  final String nationCode;
  final String category;

  // JSON > DTO 변환
  // Map<> JSON 객체 하나를 Dart에서 표현하는 형태
  factory StockSearchDto.fromJson(Map<String, dynamic> json) {
    return StockSearchDto(
      // 값이 문자열이면 사용, 없거나 null이면 빈 문자열 사용
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      typeCode: json['typeCode'] as String? ?? '',
      nationCode: json['nationCode'] as String? ?? '',
      category: json['category'] as String? ?? '',
    );
  }

  // 국내 주식인지 검사
  bool get isDomesticStock {
    return nationCode == 'KOR' && // 대한민국
        category == 'stock' && // 주식
        RegExp(r'^\d{6}$').hasMatch(code); // 6자리
  }

  // DTO > 화면 모델로 바꿈
  StockSearchResult toModel() {
    return StockSearchResult(
      id: 'domestic:$code',
      code: code,
      name: name,
      market: typeCode,
    );
  }
}
