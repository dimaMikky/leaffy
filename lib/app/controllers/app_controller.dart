import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twitter_alternative/core/services/connectivity_service.dart';

class AppController extends GetxController {
  final ConnectivityService _connectivityService;

  AppController({
    required ConnectivityService connectivityService,
  }) : _connectivityService = connectivityService;

  // App state
  final RxBool isOnline = true.obs;
  final RxInt currentBottomNavIndex = 0.obs;
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeConnectivity();
    _listenToSystemTheme();
  }

  // Initialize connectivity monitoring
  void _initializeConnectivity() {
    isOnline.value = _connectivityService.isConnected;

    _connectivityService.connectivityStream.listen((isConnected) {
      isOnline.value = isConnected;

      if (!isConnected) {
        Get.snackbar(
          'Offline',
          'You are currently offline. Some features may be limited.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Online',
          'You are back online.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    });
  }

  // Listen to system theme changes
  void _listenToSystemTheme() {
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    isDarkMode.value = platformBrightness == Brightness.dark;

    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        () {
      final updatedBrightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      isDarkMode.value = updatedBrightness == Brightness.dark;
    };
  }

  // Change bottom navigation index
  void changeBottomNavIndex(int index) {
    currentBottomNavIndex.value = index;
  }

  // Toggle dark mode manually
  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
