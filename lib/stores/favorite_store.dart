import 'package:flutter/material.dart';

import '../models/stock_search_result.dart';

class FavoriteStore extends ChangeNotifier {
  final Map<String, StockSearchResult> _favoriteStocks = {}; // 관심 등록한 종목 보관

  // 관심 종목 전체 목록
  List<StockSearchResult> get favoriteStocks {
    return _favoriteStocks.values.toList();
  }

  // 해당 종목이 관심 종목인지 확인
  bool isFavorite(String stockCode) {
    return _favoriteStocks.containsKey(stockCode);
  }

  // 관심 등록 또는 해제
  bool toggleFavorite(StockSearchResult stock) {
    final bool willAddFavorite = !isFavorite(stock.code);

    if (willAddFavorite) {
      _favoriteStocks[stock.code] = stock;
    } else {
      _favoriteStocks.remove(stock.code);
    }

    // 관심 상태 변했다는 사실을 검색·관심·상세 화면에 알려줌
    notifyListeners();

    return willAddFavorite;
  }
}