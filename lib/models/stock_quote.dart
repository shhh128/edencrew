// 실시간 시세 모델
class StockQuote {
  const StockQuote({
    required this.code,
    required this.currentPrice,
    required this.previousClose,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
    required this.listedStockCount,
  });

  final String code; // 종목 코드
  final int currentPrice; // 현재가
  final int previousClose; // 전일 종가
  final int openPrice; // 시가
  final int highPrice; // 고가
  final int lowPrice; // 저가
  final int volume; // 거래량
  final int listedStockCount; // 상장 주식 수

  // 전일 대비 등락액
  int get changeAmount {
    return currentPrice - previousClose; // 현재가 - 전일 종가
  }

  // 전일 대비 등락률
  double get changeRate {
    if (previousClose == 0) {
      return 0;
    }

    return changeAmount / previousClose * 100; // 등락액 / 전일 종가 * 100
  }

  // 시가총액
  int get marketCap {
    return currentPrice * listedStockCount; // 현재가 * 상장 주식 수
  }
}