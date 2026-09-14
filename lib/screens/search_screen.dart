import 'package:flutter/material.dart';

import '../theme/theme.dart';

import '../models/stock_search_result.dart'; // 검색 결과 데이터 저장
import '../services/stock_search_service.dart'; // 네이버 API 호출

// 화면 내용 계속 바뀌어야 해서 StatefulWidget
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // 검색창에 어떤 글자가 입력됐는지 관리
  final TextEditingController _searchController = TextEditingController();

  final StockSearchService _searchService = StockSearchService(); // API 요청 담당

  List<StockSearchResult> _searchResults = []; // 검색 결과 목록 저장
  bool _isLoading = false; // API 응답 기다리는 중인지 저장
  String? _errorMessage; // 요청 실패 메시지 저장

  // 검색 화면 닫을 때 사용하던 컨트롤러 정리
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchStocks(String value) async {
    final String keyword = value.trim();

    // 검색어 없으면 검색 상태 초기화
    if (keyword.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    // API 요청 시작
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<StockSearchResult> results =
            await _searchService.search(keyword);

      // 요청 기다리는 중 검색어 바뀌었다면 이전 결과 사용하지 않음
      if (!mounted ||
          _searchController.text.trim() != keyword ) {
        return;
      }

      // 요청 성공
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      // 요청 실패
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _errorMessage = '검색 중 오류가 발생했습니다.';
      });

      debugPrint('검색 오류: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceBase,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildSearchBar(context),
            Expanded(
              child: _buildSearchContent(context)
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _buildBottomNavigation(context),
      ),
    );
  }

  // 검색창
  Widget _buildSearchBar(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Padding(
        padding: EdgeInsets.only(
          top: context.dimens.space2,
          right: context.dimens.space4,
          bottom: context.dimens.space3,
          left: context.dimens.space4,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: context.dimens.space3),
          decoration: BoxDecoration(
            color: context.colors.surfaceSunken,
            borderRadius: BorderRadius.circular(context.dimens.radiusMd),
            border: Border.all(color: context.colors.borderStrong, width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: context.colors.textTertiary, size: 16),
              SizedBox(width: context.dimens.space2),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    _searchStocks(value);
                  },
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 15,
                    fontWeight: AppTypography.medium,
                    height: 20 / 15,
                    letterSpacing: -0.1,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: '종목명 또는 종목코드',
                    hintStyle: TextStyle(
                      color: context.colors.textTertiary,
                      fontSize: 15,
                      fontWeight: AppTypography.medium,
                      height: 20 / 15,
                      letterSpacing: -0.1,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              SizedBox(width: context.dimens.space2),
              InkWell(
                onTap: () {
                  _searchController.clear();
                  setState(() {
                    _searchResults = [];
                    _isLoading = false;
                    _errorMessage = null;
                  });
                },
                child: Icon(
                  Icons.close,
                  color: context.colors.textTertiary,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 검색 전 화면
  Widget _buildSearchEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, color: context.colors.textTertiary, size: 40),
          SizedBox(height: context.dimens.space3),
          Text(
            '종목을 검색해 보세요',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 19,
              fontWeight: AppTypography.bold,
              height: 22 / 19,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: context.dimens.space3),
          Text(
            '종목명 또는 종목코드 6자리로\n검색하실 수 있습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textTertiary,
              fontSize: 11,
              fontWeight: AppTypography.regular,
              height: 14 / 11,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  // 검색 상태에 따라 변경
  Widget _buildSearchContent(BuildContext context) {
    // 검색어 입력 전
    if (_searchController.text.trim().isEmpty) {
      return _buildSearchEmpty(context);
    }

    // 검색 중
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: context.colors.accentDefault,
          strokeWidth: 2,
        ),
      );
    }

    // 검색 오류
    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!, // 앞에서 null이 아닌 것을 확인했으므로 문자열이 확실히 들어 있다는 뜻
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 13
          ),
        ),
      );
    }

    // 검색 결과 없음
    if (_searchResults.isEmpty) {
      return _buildSearchResultEmpty(context);
    }

    // 검색 성공
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final StockSearchResult stock = _searchResults[index];

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
                          _buildHighlightedName(context, stock.name),
                          const SizedBox(height: 2),
                          Text(
                            '${stock.code} · ${stock.market}',
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 11,
                              fontWeight: AppTypography.regular,
                              height: 14 / 11,
                            ),
                          )
                        ],
                      )
                    ),
                    SizedBox(width: context.dimens.space3),
                    Icon(
                      Icons.star_border,
                      color: context.colors.textTertiary,
                      size: 22,
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 강조 표시
  Widget _buildHighlightedName(
    BuildContext context,
    String stockName
  ) {
    final String keyword = _searchController.text.trim();

    final TextStyle basicStyle = TextStyle(
      color: context.colors.textPrimary,
      fontSize: 15,
      fontWeight: AppTypography.medium,
      height: 20 / 15,
      letterSpacing: -0.1
    );

    final int keywordIndex = stockName.indexOf(keyword);

    // 검색어가 종목명에 포함되지 않은 경우
    if (keyword.isEmpty || keywordIndex == -1) {
      return Text(
        stockName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: basicStyle,
      );
    }

    return Text.rich(
      TextSpan(
        style: basicStyle,
        children: [
          // 검색어 앞부분
          TextSpan(
            text: stockName.substring(0, keywordIndex)
          ),

          // 검색어와 일치하는 부분
          TextSpan(
            text: stockName.substring(
              keywordIndex,
              keywordIndex + keyword.length
            ),
            style:  TextStyle(
              color: Theme.of(context).colorScheme.primary
            )
          ),

          // 검색어 뒷부분
          TextSpan(
            text: stockName.substring(
              keywordIndex + keyword.length
            )
          )
        ]
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  // 검색 결과 없을 시
  Widget _buildSearchResultEmpty(BuildContext context) {
    return Center(
      child: Text(
        '검색 결과 영역',
        style: TextStyle(color: context.colors.textSecondary),
      ),
    );
  }

  // 하단 탭
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
                Navigator.pop(context);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border,
                    color: context.colors.navInactive,
                    size: 22,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '관심',
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
          Expanded(
            child: InkWell(
              onTap: () {
                // 현재 검색 화면
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, color: context.colors.navActive, size: 22),
                  const SizedBox(height: 3),
                  Text(
                    '검색',
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
        ],
      ),
    );
  }
}
