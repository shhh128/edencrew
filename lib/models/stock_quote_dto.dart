import 'stock_quote.dart';

// 네이버 API 짧은 필드명 > StockQuote 모델
class StockQuoteDto {
  const StockQuoteDto({
    required this.code,
    required this.currentPrice,
    required this.previousClose,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
    required this.listedStockCount,
  });

  final String code;
  final int currentPrice;
  final int previousClose;
  final int openPrice;
  final int highPrice;
  final int lowPrice;
  final int volume;
  final int listedStockCount;

  // 네이버 API 응답 > DTO 변환
  factory StockQuoteDto.fromJson(
    Map<String, dynamic> json
  ) {
    return StockQuoteDto(
      code: json['cd'] as String? ?? '',
      currentPrice: _toInt(json['nv']),
      previousClose: _toInt(json['pcv']),
      openPrice: _toInt(json['ov']),
      highPrice: _toInt(json['hv']),
      lowPrice: _toInt(json['lv']),
      volume: _toInt(json['aq']),
      listedStockCount: _toInt(json['countOfListedStock']),
    );
  }

  // DTO > 앱 사용 모델 변환
  StockQuote toModel() {
    return StockQuote(
      code: code,
      currentPrice: currentPrice,
      previousClose: previousClose,
      openPrice: openPrice,
      highPrice: highPrice,
      lowPrice: lowPrice,
      volume: volume,
      listedStockCount: listedStockCount
    );
  }

  // 숫자가 어떤 형태로 와도 int로 변환
  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(
        value.replaceAll(',', '')
      ) ?? 
      0;
    }

    return 0;
  }
}