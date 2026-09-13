import 'package:flutter/material.dart';

import '../theme/theme.dart';

import 'search_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

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
            Expanded(child: _buildEmpty(context)),
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
                  Text(
                    '가나다순',
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
                  SizedBox(width: context.dimens.space4),
                  // 새로고침
                  InkWell(
                    onTap: () {
                      // 새로고침 기능 추가
                    },
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
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
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
