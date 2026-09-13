import 'package:flutter/material.dart';

import '../theme/theme.dart';

// 화면 내용 계속 바뀌어야 해서 StatefulWidget
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // 검색창에 어떤 글자가 입력됐는지 관리
  final TextEditingController _searchController = TextEditingController();

  // 검색 화면 닫을 때 사용하던 컨트롤러 정리
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              child:
                  _searchController.text
                      .trim()
                      .isEmpty // trim 띄어쓰기 빈 검색어로 판단
                  ? _buildSearchEmpty(context)
                  : _buildSearchResultEmpty(context),
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
                    setState(() {});
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
                  setState(() {});
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
