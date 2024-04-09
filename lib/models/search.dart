import 'package:flutter/material.dart';

class SearchModel extends ChangeNotifier {
  String _searchText = "";
  bool _showSearch = false;
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  String get searchText => _searchText;

  bool get showSearch => _showSearch;

  FocusNode get searchFocusNode => _searchFocusNode;

  TextEditingController get searchController => _searchController;

  void setSearchText(String text) {
    _searchText = text;
    notifyListeners();
  }

  void clearSearchText() {
    _searchText = "";
    notifyListeners();
  }

  void searchExif() {
    if (!_showSearch) {
      _showSearch = true;
    } else if (_searchText.isEmpty) {
      _showSearch = false;
    }
    _showSearch ? _searchFocusNode.requestFocus() : _searchFocusNode.unfocus();
    notifyListeners();
  }
}
