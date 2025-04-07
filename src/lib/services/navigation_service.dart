class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  Function(int)? changeTabCallback;

  void changeTab(int index) {
    if (changeTabCallback != null) {
      changeTabCallback!(index);
    }
  }
}
