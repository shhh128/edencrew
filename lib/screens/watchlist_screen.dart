import 'package:flutter/material.dart';

import '../theme/theme.dart';

import 'search_screen.dart';
import '../stores/favorite_store.dart';
import '../models/stock_quote.dart';
import '../services/stock_quote_service.dart';
import '../models/stock_search_result.dart';

// 정렬 종류
enum WatchlistSort {
  currentPrice,
  changeRate,
  name
}

class WatchlistScreen extends StatefulWidget {
  // main.dart의 저장소 전달받음
  const WatchlistScreen({
    super.key,
    required this.favoriteStore
  });

  final FavoriteStore favoriteStore;

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  // 시세 API 호출
  final StockQuoteService _quoteService = StockQuoteService();

  Map<String, StockQuote> _quotes = {}; // 받아온 종목별 시세 보관

  // 현재 정렬 상태
  WatchlistSort _currentSort = WatchlistSort.name;

  @override
  // 관심화면 처음 열릴 때 시세 조회
  void initState() {
    super.initState();

    // 관심종목 바뀌었는지 감지
    widget.favoriteStore.addListener(
      _handleFavoriteChanged
    );

    // 화면 처음 만들어질 때 시세 조회
    _fetchQuotes();
  }

  void _handleFavoriteChanged() {
    _fetchQuotes();
  }

  Future<void> _fetchQuotes() async {
    final List<String> stockCodes = widget
        .favoriteStore
        .favoriteStocks
        .map((stock) => stock.code)
        .toList();

    if (stockCodes.isEmpty) {
      if (!mounted) {
        return;
      }

      setState(() {
        _quotes = {};
      });

      return;
    }

    // 새 시세 기다리는 동안 스켈레톤 표시
    setState(() {
      _quotes = {};
    });

    try {
      final Map<String, StockQuote> quotes =
          await _quoteService.fetchQuotes(stockCodes);

      if (!mounted) {
        return;
      }

      setState(() {
        _quotes = quotes;
      });
    } catch (error) {
      debugPrint('실시간 시세 오류: $error');
    }
  }

  @override
  void dispose() {
    widget.favoriteStore.removeListener(
      _handleFavoriteChanged
    );

    // 화면 없어질 때 관심 상태 감지 연결 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final Size screenSize = MediaQuery.sizeOf(context);

    // debugPrint(
    //   '화면 크기: ${screenSize.width} × ${screenSize.height}',
    // );

    return Scaffold(
      backgroundColor: context.colors.surfaceBase,

      // 화면 본문
      body: SafeArea(
        bottom: false,
        // 한 개의 Widget만 받을 때 child
        // 여러 개의 Widget 받을 때 children
        child: Column(
          // 세로
          children: [
            _buildHeader(context),
            // 헤더 제외 남은 공간 사용
            Expanded(
              // 변경 감지해서 관심 화면 다시 그림
              child: AnimatedBuilder(
                animation: widget.favoriteStore, 
                builder: (context, child) {
                  if (widget.favoriteStore.favoriteStocks.isEmpty) {
                    return _buildEmpty(context);
                  }

                  return _buildFavoriteList(context);
                }
              )

            ),
          ],
        ),
      ),

      // 화면 하단 관심·검색 탭
      bottomNavigationBar: SafeArea(
        top: false,
        child: _buildBottomNavigation(context),
      ),
    );
  }

  // 헤더
  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: EdgeInsets.symmetric(
          // 여백 만드는.좌우상하 묶어서 지정
          horizontal: context.dimens.space4,
          vertical: context.dimens.space3,
        ),
        child: Row(
          // Row나 Column 안에서 자식들을 어떻게 배치할지 정하는 속성
          // Row에서 crossAxis~ > 세로
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '관심',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 19,
                fontWeight: AppTypography.bold,
                height: 22 / 19, // 글자 크기 / 줄 높이
                letterSpacing: -0.2,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.dimens.space1),
              child: Row(
                // 오른쪽 Row가 화면 전체 너비를 차지하지 않고 내부 요소 크기만큼만 차지하게
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 정렬
                  InkWell(
                    onTap: _showSortBottomSheet,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _sortLabel,
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 13,
                            fontWeight: AppTypography.bold,
                            height: 18 / 13,
                            letterSpacing: 0,
                          ),
                        ),
                        SizedBox(
                          width: context.dimens.iconMd,
                          child: Transform.translate(
                            offset: const Offset(0, 1),
                            child: Icon(
                              Icons.south_rounded,
                              color: context.colors.textSecondary,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: context.dimens.space4),
                  // 새로고침
                  InkWell(
                    onTap: _fetchQuotes,
                    child: Icon(
                      Icons.refresh_rounded,
                      color: context.colors.textSecondary,
                      size: context.dimens.iconMd,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 관심종목 없을 때
  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        // Column이 화면 전체 높이를 차지하지 않고, 내용물 높이만큼만 차지
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_border, color: context.colors.textTertiary, size: 40),
          SizedBox(height: context.dimens.space3),
          Text(
            '관심 종목이 없습니다',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 19,
              fontWeight: AppTypography.bold,
              height: 22 / 19,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: context.dimens.space3),
          SizedBox(
            child: Text(
              '검색 탭에서 종목을 찾아\n별 아이콘을 눌러 추가해 주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textTertiary,
                fontSize: 11,
                fontWeight: AppTypography.regular,
                height: 14 / 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 관심 목록
  Widget _buildFavoriteList(BuildContext context) {
    final List<StockSearchResult> favoriteStocks = [
      ...widget.favoriteStore.favoriteStocks
    ];

    favoriteStocks.sort(_compareFavoriteStocks);

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: favoriteStocks.length,
      itemBuilder: (context, index) {
        final stock = favoriteStocks[index];
        final StockQuote? quote = _quotes[stock.code];

        return InkWell(
          onTap: () {
            // 종목 상세 화면으로 이동
          },
          child: SizedBox(
            height: 60,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: context.colors.borderSubtle,
                    width: 1
                  )
                )
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.dimens.space4,
                  vertical: context.dimens.space3
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stock.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontSize: 15,
                              fontWeight: AppTypography.medium,
                              height: 20 / 15,
                              letterSpacing: -0.1
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${stock.code} · ${stock.market}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 11,
                              fontWeight: AppTypography.regular,
                              height: 14 / 11,
                              letterSpacing: 0
                            ),
                          )
                        ],
                      )
                    ),
                    SizedBox(width: context.dimens.space3),

                    // 시세 받지 못했을 시 스켈레톤 표시
                    quote == null
                        ? _buildQuoteSkeleton(context)
                        : _buildQuote(context, quote)
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  // 정렬
  int _compareFavoriteStocks(
    StockSearchResult a,
    StockSearchResult b
  ) {
    if (_currentSort == WatchlistSort.name) {
      return a.name.compareTo(b.name);
    }

    final StockQuote? quoteA = _quotes[a.code];
    final StockQuote? quoteB = _quotes[b.code];

    // 아직 시세 없는 종목은 아래 배치
    if (quoteA == null && quoteB == null) {
      return a.name.compareTo(b.name);
    }

    if (quoteA == null) {
      return 1;
    }

    if (quoteB == null) {
      return -1;
    }

    if (_currentSort == WatchlistSort.currentPrice) {
      return quoteB.currentPrice.compareTo(
        quoteA.currentPrice
      );
    }

    return quoteB.changeRate.compareTo(
      quoteA.changeRate
    );
  }

  // 헤더 정렬 문구 변경
  String get _sortLabel {
    switch (_currentSort) {
      case WatchlistSort.currentPrice:
        return '현재가순';
      case WatchlistSort.changeRate:
        return '등락률순';
      case WatchlistSort.name:
        return '가나다순';
    }
  }

  // 정렬 바텀시트
  void _showSortBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surfaceOverlay,
      barrierColor: context.colors.surfaceBase.withValues(alpha: 0.72),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16)
        )
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 64,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.dimens.space6
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '정렬',
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 19,
                        fontWeight: AppTypography.bold,
                        height: 22 / 19,
                        letterSpacing: -0.2
                      ),
                    ),
                  ),
                ),
              ),
              _buildSortOption(
                sheetContext,
                WatchlistSort.currentPrice,
                '현재가순'
              ),
              _buildSortOption(
                sheetContext,
                WatchlistSort.changeRate,
                '등락률순'
              ),
              _buildSortOption(
                sheetContext,
                WatchlistSort.name,
                '가나다순'
              ),
            ],
          )
        );
      }
    );
  }

  // 정렬 옵션
  Widget _buildSortOption(
    BuildContext sheetContext,
    WatchlistSort sort,
    String label
  ) {
    final bool isSelected = _currentSort == sort;

    return InkWell(
      onTap: () {
        setState(() {
          _currentSort = sort;
        });

        Navigator.pop(sheetContext);
      },
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.dimens.space6,
            vertical: 10
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? context.colors.textPrimary
                        : context.colors.textSecondary,
                    fontSize: 15,
                    fontWeight: AppTypography.medium,
                    height: 20 / 15
                  ),
                )
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  color: context.colors.textPrimary,
                  size: context.dimens.iconMd,
                )
            ],
          ),
        ),
      ),
    );
  }

  // 실제 시세 위젯
  Widget _buildQuote(
    BuildContext context,
    StockQuote quote
  ) {
    final bool isUp = quote.changeAmount > 0;
    final bool isDown = quote.changeAmount < 0;

    final Color changeColor = isUp
        ? context.colors.priceUpText
        : isDown
            ? context.colors.priceDownText
            :context.colors.priceFlatText;

    final String sign = isUp ? '+' : '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _formatNumber(quote.currentPrice),
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 15,
            fontWeight: AppTypography.medium,
            height: 20 / 15,
            letterSpacing: -0.1
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$sign${_formatNumber(quote.changeAmount)} '
          '($sign${quote.changeRate.toStringAsFixed(2)}%)',
          style: TextStyle(
            color: changeColor,
            fontSize: 11,
            fontWeight: AppTypography.regular,
            height: 14 / 11,
            letterSpacing: 0
          ),
        )
      ],
    );
  }

  // 천 단위 쉼표 표시
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},'
    );
  }

  // 시세 불러오기 전 스켈레톤
  Widget _buildQuoteSkeleton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 64,
          height: 16,
          decoration: BoxDecoration(
            color: context.colors.feedbackSkeleton,
            borderRadius: BorderRadius.circular(
              context.dimens.radiusSm
            )
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 48,
          height: 12,
          decoration: BoxDecoration(
            color: context.colors.feedbackSkeleton,
            borderRadius: BorderRadius.circular(
              context.dimens.radiusSm
            )
          ),
        )
      ],
    );
  }

  // 하단 관심·검색 탭
  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      height: 63,
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised,
        border: Border(
          top: BorderSide(color: context.colors.borderSubtle, width: 1),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: context.dimens.space2),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                // 현재 관심 화면
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: context.colors.navActive, size: 22),
                  const SizedBox(height: 3),
                  Text(
                    '관심',
                    style: TextStyle(
                      color: context.colors.navActive,
                      fontSize: 11,
                      fontWeight: AppTypography.regular,
                      height: 14 / 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen(
                    favoriteStore: widget.favoriteStore // 검색 화면으로 다시 전달
                  )),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    color: context.colors.navInactive,
                    size: 22,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '검색',
                    style: TextStyle(
                      color: context.colors.navInactive,
                      fontSize: 11,
                      fontWeight: AppTypography.regular,
                      height: 14 / 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
