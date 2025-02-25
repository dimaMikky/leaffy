class AppConstants {
  // App Info
  static const String appName = 'Twitter Alternative';
  static const String appVersion = '1.0.0';

  // Routes
  static const String initialRoute = '/';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user';
  static const String themeKey = 'theme_mode';

  // API Endpoints
  static const String baseUrl = 'https://your-domain.com/api';
  static const String authUrl = '$baseUrl/auth';
  static const String usersUrl = '$baseUrl/users';
  static const String postsUrl = '$baseUrl/posts';

  // Pagination
  static const int defaultPageSize = 10;

  // Asset Paths
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderImagePath = 'assets/images/placeholder.png';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Cache
  static const int cacheDuration = 7; // days

  // Content limits
  static const int maxContentLength = 280;
  static const int maxBioLength = 160;
  static const int maxDisplayNameLength = 50;
  static const int maxUsernameLength = 15;

  // Image upload
  static const int imageQuality = 80;
  static const double maxImageWidth = 1200;
  static const double maxImageHeight = 1200;
  static const int maxImageSizeInBytes = 5 * 1024 * 1024; // 5MB

  // Animations
  static const int shortAnimationDuration = 200; // milliseconds
  static const int mediumAnimationDuration = 350; // milliseconds
  static const int longAnimationDuration = 500; // milliseconds
}
