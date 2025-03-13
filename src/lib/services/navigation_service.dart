//// filepath: c:/Users/Harsh/4080finalproject/src/lib/services/navigation_service.dart
import 'package:flutter/material.dart';

// A simple class to handle tab navigation
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();
  
  // Callback to be set by NavigationScaffold
  Function(int)? changeTabCallback;
  
  void changeTab(int index) {
    if (changeTabCallback != null) {
      changeTabCallback!(index);
    }
  }
}