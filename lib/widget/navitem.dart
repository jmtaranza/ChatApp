import 'package:RecipeApp/views/homepage.dart';
import 'package:flutter/material.dart';

class NavItem {
  final int id;
  final String icon;
  final Widget destination;

  NavItem({this.id, this.icon, this.destination});

// If there is no destination then it help us
  bool destinationChecker() {
    if (destination != null) {
      return true;
    }
    return false;
  }
}

// If we made any changes here Provider package rebuid those widget those use this NavItems
class NavItems extends ChangeNotifier {
  // By default first one is selected
  int selectedIndex = 0;

  void chnageNavIndex({int index}) {
    selectedIndex = index;
    // if any changes made it notify widgets that use the value
    notifyListeners();
  }

  List<NavItem> items = [
    NavItem(
      id: 1,
      icon: "assets/images/homepage.png",
      destination: Homepage(),
    ),
    NavItem(
      id: 2,
      icon: "assets/images/searchicon.png",
    ),
    NavItem(
      id: 3,
      icon: "assets/images/addlogo.png",
    ),
    NavItem(
      id: 4,
      icon: "assets/images/bulletlist.png",
    ),
    NavItem(
      id: 5,
      icon: "assets/images/smiley.png",
      /* destination: ProfileScreen(), */
    ),
  ];
}
