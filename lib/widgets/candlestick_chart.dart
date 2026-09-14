import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/daily_price.dart';

class CandlestickChart extends StatelessWidget {
  const CandlestickChart({
    super.key,
    required this.prices,
    required this.upColor,
    required this.downColor,
    required this.baselineColor
  });

  final List<DailyPrice> prices;
  final Color upColor;
  final Color downColor;
  final Color baselineColor;

  @override
  Widget build(BuildContext context) {
    if (prices.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: 200,
      child: CustomPaint(
        painter: _CandlestickPainter(
          prices: prices,
          upColor: upColor,
          downColor: downColor,
          baselineColor: baselineColor,
        ),
      ),
    );
  }
}

class _CandlestickPainter extends CustomPainter {
  const _CandlestickPainter({
    required this.prices,
    required this.upColor,
    required this.downColor,
    required this.baselineColor,
  });

  final List<DailyPrice> prices;
  final Color upColor;
  final Color downColor;
  final Color baselineColor;

  @override
  void paint(Canvas canvas, Size size) {
    // API는 최신 날짜부터 옴 > 오래된 날짜부터 보이도록 순서 뒤집음
    final List<DailyPrice> chartPrices = prices.reversed.toList();

    final int highestPrice = chartPrices
        .map((price) => price.highPrice)
        .reduce(math.max);

    final int lowestPrice = chartPrices
        .map((price) => price.lowPrice)
        .reduce(math.min);

    final double priceRange =
        math.max(1, highestPrice - lowestPrice).toDouble();

    const double verticalPadding = 8;
    final double chartHeight = size.height - (verticalPadding * 2);
    final double candleStep = size.width / chartPrices.length;

    // 가격을 차트의 세로 위치로 변환
    double priceToY(int price) {
      final double ratio = (highestPrice - price) / priceRange;
      return verticalPadding + (ratio * chartHeight);
    }

    for (int index = 0; index < chartPrices.length; index++) {
      final DailyPrice price = chartPrices[index];

      final double centerX = (index + 0.5) * candleStep;
      final double highY = priceToY(price.highPrice);
      final double lowY = priceToY(price.lowPrice);
      final double openY = priceToY(price.openPrice);
      final double closeY = priceToY(price.closePrice);

      // 상승은 빨강, 하락은 파랑, 시가와 종가가 같으면 회색
      final Color candleColor = price.closePrice > price.openPrice
          ? upColor
          : price.closePrice < price.openPrice
              ? downColor
              : baselineColor;

      // 고가와 저가를 연결하는 선은 피그마의 회색 사용
      final Paint baselinePaint = Paint()
        ..color = baselineColor
        ..strokeWidth = 0.3;

      // 시가와 종가 사이의 몸통은 상승·하락 색상 사용
      final Paint candlePaint = Paint()
        ..color = candleColor;

      // 고가-저가를 이어주는 회색 선
      canvas.drawLine(
        Offset(centerX, highY),
        Offset(centerX, lowY),
        baselinePaint,
      );

      // 시가, 종가 사이 캔들 몸통
      final double bodyWidth = math.max(
        1,
        candleStep * 0.55,
      );

      final double bodyTop = math.min(openY, closeY);
      final double bodyHeight = math.max(
        1.5,
        (openY - closeY).abs(),
      );

      canvas.drawRect(
        Rect.fromLTWH(
          centerX - (bodyWidth / 2),
          bodyTop,
          bodyWidth,
          bodyHeight,
        ),
        candlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CandlestickPainter oldDelegate) {
    // 기간, 색상 바뀌면 차트 다시 그림
    return oldDelegate.prices != prices ||
        oldDelegate.upColor != upColor ||
        oldDelegate.downColor != downColor ||
        oldDelegate.baselineColor != baselineColor;
  }
}