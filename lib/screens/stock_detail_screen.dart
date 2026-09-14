import 'package:flutter/material.dart';

import '../theme/theme.dart';

import '../models/daily_price.dart';
import '../models/stock_metadata.dart';
import '../models/stock_quote.dart';
import '../models/stock_search_result.dart';
import '../services/daily_price_service.dart';
import '../services/stock_metadata_service.dart';
import '../services/stock_quote_service.dart';
import '../stores/favorite_store.dart';
import '../widgets/candlestick_chart.dart';


// 상세 화면에서 선택할 수 있는 조회 기간
enum StockPeriod {
  oneMonth,
  threeMonths,
  sixMonths,
  oneYear,
}

class StockDetailScreen extends StatefulWidget {
  const StockDetailScreen({
    super.key,
    required this.stock,
    required this.favoriteStore,
  });

  final StockSearchResult stock;
  final FavoriteStore favoriteStore;

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  final StockMetadataService _metadataService = StockMetadataService();
  final StockQuoteService _quoteService = StockQuoteService();
  final DailyPriceService _dailyPriceService = DailyPriceService();

  StockMetadata? _metadata;
  StockQuote? _quote;
  List<DailyPrice> _dailyPrices = [];

  StockPeriod _selectedPeriod = StockPeriod.oneMonth;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // 상세 화면 진입하면서 필요한 데이터 조회
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // 세 API 요청을 동시에 시작해 대기 시간을 줄임
      final List<dynamic> results = await Future.wait<dynamic>([
        _metadataService.fetchMetadata(widget.stock.code),
        _quoteService.fetchQuotes([widget.stock.code]),
        _dailyPriceService.fetchDailyPrices(
          code: widget.stock.code,
          pageCount: _pageCount,
        ),
      ]);

      if (!mounted) return;

      final Map<String, StockQuote> quotes =
          results[1] as Map<String, StockQuote>;

      setState(() {
        _metadata = results[0] as StockMetadata;
        _quote = quotes[widget.stock.code];
        _dailyPrices = results[2] as List<DailyPrice>;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('상세 정보 조회 오류: $error');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // 기간별 필요한 일별 시세 페이지 수
  int get _pageCount {
    switch (_selectedPeriod) {
      case StockPeriod.oneMonth:
        return 2;
      case StockPeriod.threeMonths:
        return 6;
      case StockPeriod.sixMonths:
        return 12;
      case StockPeriod.oneYear:
        return 25;
    }
  }

  Future<void> _changePeriod(StockPeriod period) async {
    if (_selectedPeriod == period) return;

    setState(() {
      _selectedPeriod = period;
      _isLoading = true;
    });

    try {
      // 서비스 내부 캐시가 있어 받은 페이지는 다시 요청x
      final List<DailyPrice> prices =
          await _dailyPriceService.fetchDailyPrices(
        code: widget.stock.code,
        pageCount: _pageCount,
      );

      if (!mounted) return;

      setState(() {
        _dailyPrices = prices;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('기간별 시세 조회 오류: $error');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceBase,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  context.dimens.space4,
                  14,
                  context.dimens.space4,
                  context.dimens.space4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCurrentPrice(context),
                    SizedBox(height: context.dimens.space4),
                    _buildPeriodTabs(context),
                    SizedBox(height: context.dimens.space4),

                    // 실제 캔들 차트로 교체
                    SizedBox(
                      height: 200,
                      child: _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: context.colors.accentDefault,
                              )
                            )
                          : CandlestickChart(
                              prices: _dailyPrices,
                              upColor: context.colors.chartLineUp,
                              downColor: context.colors.chartLineDown,
                              baselineColor: context.colors.chartBaseline,
                            )
                    ),
                    SizedBox(height: context.dimens.space6),

                    // 시가, 고가, 저가, 거래량, 시가총액
                    _buildQuoteSummary(context),

                    SizedBox(height: context.dimens.space6),

                    // 날짜별 종가, 등락, 거래량
                    _buildDailySection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 상단 앱 바
  Widget _buildAppBar(BuildContext context) {
    final String name = _metadata?.name ?? widget.stock.name;
    final String market = _metadata?.market ?? widget.stock.market;

    return Container(
      height: 55,
      padding: EdgeInsets.symmetric(
        horizontal: context.dimens.space4,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colors.borderSubtle,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_rounded,
              color: context.colors.textPrimary,
              size: context.dimens.iconMd,
            ),
          ),
          SizedBox(width: context.dimens.space3),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 15,
                    fontWeight: AppTypography.medium,
                    height: 20 / 15,
                    letterSpacing: -0.1,
                  ),
                ),
                Text(
                  '${widget.stock.code} · $market',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 11,
                    fontWeight: AppTypography.regular,
                    height: 14 / 11,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.dimens.space3),

          // FavoriteStore 감시해 다른 화면과 관심 상태 동기화
          AnimatedBuilder(
            animation: widget.favoriteStore,
            builder: (context, child) {
              final bool isFavorite =
                  widget.favoriteStore.isFavorite(widget.stock.code);

              return InkWell(
                onTap: () {
                  widget.favoriteStore.toggleFavorite(widget.stock);
                },
                child: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite
                      ? context.colors.favoriteActive
                      : context.colors.favoriteInactive,
                  size: 22,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 현재가
  Widget _buildCurrentPrice(BuildContext context) {
    final StockQuote? quote = _quote;

    if (quote == null) {
      return SizedBox(
        height: 36,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _isLoading ? '시세 조회 중' : '시세 정보가 없습니다',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 15,
            ),
          ),
        ),
      );
    }

    final int change = quote.changeAmount;
    final bool isUp = change > 0;
    final bool isDown = change < 0;

    final Color changeColor = isUp
        ? context.colors.priceUpText
        : isDown
            ? context.colors.priceDownText
            : context.colors.priceFlatText;

    final String arrow = isUp
        ? '▲'
        : isDown
            ? '▼'
            : '-';

    final String rateSign = isUp
        ? '+'
        : isDown
            ? '-'
            : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _formatNumber(quote.currentPrice),
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 30,
            fontWeight: AppTypography.bold,
            height: 36 / 30,
            letterSpacing: -0.4,
          ),
        ),
        SizedBox(width: context.dimens.space2),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            '$arrow ${_formatNumber(change.abs())} '
            '($rateSign${quote.changeRate.abs().toStringAsFixed(2)}%)',
            style: TextStyle(
              color: changeColor,
              fontSize: 15,
              fontWeight: AppTypography.medium,
              height: 20 / 15,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ],
    );
  }

  // 기간별 탭
  Widget _buildPeriodTabs(BuildContext context) {
    const List<(StockPeriod, String)> periods = [
      (StockPeriod.oneMonth, '1개월'),
      (StockPeriod.threeMonths, '3개월'),
      (StockPeriod.sixMonths, '6개월'),
      (StockPeriod.oneYear, '1년'),
    ];

    return Row(
      children: periods.map((item) {
        final bool isSelected = _selectedPeriod == item.$1;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              onTap: () => _changePeriod(item.$1),
              borderRadius: BorderRadius.circular(
                context.dimens.radiusMd,
              ),
              child: Container(
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.accentBg
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    context.dimens.radiusMd,
                  ),
                ),
                child: Text(
                  item.$2,
                  style: TextStyle(
                    color: isSelected
                        ? context.colors.accentDefault
                        : context.colors.textSecondary,
                    fontSize: 13,
                    fontWeight: AppTypography.regular,
                    height: 18 / 13,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 요약 카드
  Widget _buildQuoteSummary(BuildContext context) {
    final StockQuote? quote = _quote;

    if (quote == null) {
      return const SizedBox(height: 118);
    }

    return Column(
      children: [
        // 첫줄: 시가, 고가, 저가
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                label: '시가',
                value: _formatNumber(quote.openPrice),
              ),
            ),
            SizedBox(width: context.dimens.space2),
            Expanded(
              child: _buildSummaryCard(
                context,
                label: '고가',
                value: _formatNumber(quote.highPrice),
              ),
            ),
            SizedBox(width: context.dimens.space2),
            Expanded(
              child: _buildSummaryCard(
                context,
                label: '저가',
                value: _formatNumber(quote.lowPrice),
              ),
            ),
          ],
        ),

        SizedBox(height: context.dimens.space2),

        // 둘째줄: 거래량, 시가총액
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                label: '거래량',
                value: '${_formatNumber(quote.volume ~/ 1000)}천',
              ),
            ),
            SizedBox(width: context.dimens.space2),
            Expanded(
              child: _buildSummaryCard(
                context,
                label: '시가총액',
                value: _formatMarketCap(quote.marketCap),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceSunken,
        borderRadius: BorderRadius.circular(
          context.dimens.radiusMd,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 11,
              fontWeight: AppTypography.regular,
              height: 14 / 11,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 15,
              fontWeight: AppTypography.medium,
              height: 20 / 15,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  // yyyyMMdd > MM.DD
  String _formatDate(String date) {
    if (date.length != 8) return date;

    return '${date.substring(4, 6)}.${date.substring(6, 8)}';
  }

  // 시가총액을 조, 억 단위로 축약
  String _formatMarketCap(int marketCap) {
    const int trillion = 1000000000000;
    const int hundredMillion = 100000000;

    if (marketCap >= trillion) {
      return '${_formatNumber(marketCap ~/ trillion)}조';
    }

    return '${_formatNumber(marketCap ~/ hundredMillion)}억';
  }

  // 일별 시세 표
  Widget _buildDailySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '일별 시세',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 13,
            fontWeight: AppTypography.bold,
            height: 18 / 13,
          ),
        ),
        SizedBox(height: context.dimens.space1),

        // 전체 기간 데이터 스크롤
        SizedBox(
          height: 192,
          child: Column(
            children: [
              _buildDailyHeader(context),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _dailyPrices.length,
                  itemBuilder: (context, index) {
                    return _buildDailyRow(
                      context,
                      _dailyPrices[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyHeader(BuildContext context) {
    final TextStyle style = TextStyle(
      color: context.colors.textSecondary,
      fontSize: 11,
      fontWeight: AppTypography.regular,
      height: 14 / 11,
    );

    return SizedBox(
      height: 32,
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: Text('날짜', style: style),
          ),
          SizedBox(width: context.dimens.space2),
          Expanded(
            child: Text(
              '종가',
              textAlign: TextAlign.right,
              style: style,
            ),
          ),
          SizedBox(width: context.dimens.space2),
          Expanded(
            child: Text(
              '등락',
              textAlign: TextAlign.right,
              style: style,
            ),
          ),
          SizedBox(width: context.dimens.space2),
          Expanded(
            child: Text(
              '거래량',
              textAlign: TextAlign.right,
              style: style,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRow(
    BuildContext context,
    DailyPrice price,
  ) {
    final int change = price.changeAmount;

    final Color changeColor = change > 0
        ? context.colors.priceUpText
        : change < 0
            ? context.colors.priceDownText
            : context.colors.priceFlatText;

    final String changeText = change > 0
        ? '+${_formatNumber(change)}'
        : _formatNumber(change);

    return Container(
      height: 32,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: context.colors.borderSubtle,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: Text(
              _formatDate(price.localDate),
              style: _dailyTextStyle(
                context.colors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: context.dimens.space2),
          Expanded(
            child: Text(
              _formatNumber(price.closePrice),
              textAlign: TextAlign.right,
              style: _dailyTextStyle(
                context.colors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: context.dimens.space2),
          Expanded(
            child: Text(
              changeText,
              textAlign: TextAlign.right,
              style: _dailyTextStyle(changeColor),
            ),
          ),
          SizedBox(width: context.dimens.space2),
          Expanded(
            child: Text(
              _formatNumber(price.volume),
              textAlign: TextAlign.right,
              style: _dailyTextStyle(
                context.colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _dailyTextStyle(Color color) {
    return TextStyle(
      color: color,
      fontSize: 11,
      fontWeight: AppTypography.regular,
      height: 14 / 11,
    );
  }
}