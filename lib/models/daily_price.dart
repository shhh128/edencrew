// 일별 시세 모델
class DailyPrice {
  const DailyPrice({
    required this.localDate, // yyyyMMdd
    required this.closePrice, // 종가
    required this.changeAmount,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
  });

  final String localDate;
  final int closePrice;
  final int changeAmount;
  final int openPrice;
  final int highPrice;
  final int lowPrice;
  final int volume;
}