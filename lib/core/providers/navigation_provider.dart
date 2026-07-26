import 'package:flutter/foundation.dart';

class NavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    if (index >= 0 && index < 10 && index != _selectedIndex) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void nextTab() {
    if (_selectedIndex < 9) {
      _selectedIndex++;
      notifyListeners();
    }
  }

  void previousTab() {
    if (_selectedIndex > 0) {
      _selectedIndex--;
      notifyListeners();
    }
  }
}