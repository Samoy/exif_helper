import 'package:exif_helper/models/search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('test SearchModel', () {
    final SearchModel searchModel = SearchModel();
    test('SearchModel should set some text correctly', () {
      String newText = "new text";
      searchModel.setSearchText(newText);
      expect(searchModel.searchText, newText);
    });

    test('SearchModel should clear text correctly', () {
      searchModel.setSearchText("text");
      searchModel.clearSearchText();
      expect(searchModel.searchText, "");
    });

    test('SearchModel should search exif correctly', () {
      searchModel.setSearchText("text");
      searchModel.searchExif();
      expect(searchModel.showSearch, isTrue);

      searchModel.setSearchText("");
      searchModel.searchExif();
      expect(searchModel.showSearch, isFalse);
    });
  });
}
