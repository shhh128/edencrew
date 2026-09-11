import 'package:flutter/material.dart';

import '../theme/theme.dart';

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
        child: Column( // 세로
          children: [
            _buildHeader(context),
            // 헤더 제외 남은 공간 사용
            Expanded(
              child: _buildEmpty(context)
            ),
          ],
        ),
      ),

      // 화면 하단 관심·검색 탭
      bottomNavigationBar: SafeArea(
        top: false,
        child: _buildBottomNavigation(context)
      )
    );
  }
}

//  헤더
Widget _buildHeader(BuildContext context) {
  return SizedBox(
    height: 52,
    child: Padding(
      padding: EdgeInsets.symmetric( // 여백 만드는.좌우상하 묶어서 지정
        horizontal: context.dimens.space4,
        vertical: context.dimens.space3
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
              letterSpacing: -0.2
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: context.dimens.space1
            ),
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
                    letterSpacing: 0
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
                    )
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
                    size: context.dimens.iconMd
                  )
                )
              ],
            )
          ),
        ],
      ),
    ),
  );
}

// 관심종목 없을 때
Widget _buildEmpty(BuildContext context) {
  return const SizedBox.shrink();
}

// 하단 관심·검색 탭
Widget _buildBottomNavigation(BuildContext context) {
  return const SizedBox.shrink();
}