// 종목 메타데이터 조회
class StockMetadata {
  const StockMetadata({
    required this.code,
    required this.name,
    required this.market,
  });

  final String code;
  final String name;
  final String market;

  factory StockMetadata.fromJson(Map<String, dynamic> json) {
    return StockMetadata(
      code: json['symbolCode'] as String? ?? '', // 종목 코드
      name: json['stockName'] as String? ?? '', // 종목명
      market: json['stockExchangeNameKor'] as String? ?? '', // 시장명
    );
  }
}