import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool _isConnected = true.obs;

  bool get isConnected => _isConnected.value;
  Stream<bool> get connectivityStream => _isConnected.stream;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // Initialize connectivity state
  Future<void> _initConnectivity() async {
    try {
      final status = await _connectivity.checkConnectivity();
      _updateConnectionStatus(status);
    } catch (e) {
      // Fallback to assuming online if we can't determine
      _isConnected.value = true;
    }
  }

  // Update connection status based on connectivity result
  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      _isConnected.value = false;
    } else {
      _isConnected.value = true;
    }
  }
}
