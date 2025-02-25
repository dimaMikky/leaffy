import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// String extensions
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String get capitalized {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  String truncate(int maxLength) {
    return length > maxLength ? '${substring(0, maxLength)}...' : this;
  }

  bool get isValidEmail {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(this);
  }

  bool get isValidUsername {
    final usernameRegExp = RegExp(r'^[a-zA-Z0-9._]+$');
    return usernameRegExp.hasMatch(this);
  }

  bool get isValidUrl {
    final urlRegExp =
        RegExp(r'^(http|https)://([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$');
    return urlRegExp.hasMatch(this);
  }
}

// DateTime extensions
extension DateTimeExtension on DateTime {
  String formatDate([String format = 'MMM d, yyyy']) {
    return DateFormat(format).format(this);
  }

  String formatTime([String format = 'h:mm a']) {
    return DateFormat(format).format(this);
  }

  String formatDateTime([String format = 'MMM d, yyyy - h:mm a']) {
    return DateFormat(format).format(this);
  }

  String timeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isToday() {
    final now = DateTime.now();
    return isSameDay(now);
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(yesterday);
  }
}

// BuildContext extensions
extension ContextExtension on BuildContext {
  // Size helpers
  double get screenHeight => MediaQuery.of(this).size.height;
  double get screenWidth => MediaQuery.of(this).size.width;
  Size get screenSize => MediaQuery.of(this).size;
  double get statusBarHeight => MediaQuery.of(this).padding.top;
  double get bottomBarHeight => MediaQuery.of(this).padding.bottom;
  bool get isKeyboardOpen => MediaQuery.of(this).viewInsets.bottom > 0;

  // Theme helpers
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // Navigation helpers
  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<T?> pushNamed<T>(String route, {Object? arguments}) {
    return Navigator.of(this).pushNamed<T>(route, arguments: arguments);
  }

  Future<T?> pushReplacement<T, TO>(Widget page) {
    return Navigator.of(this).pushReplacement<T, TO>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<T?> pushReplacementNamed<T, TO>(String route, {Object? arguments}) {
    return Navigator.of(this).pushReplacementNamed<T, TO>(
      route,
      arguments: arguments,
    );
  }

  void pop<T>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }

  void popUntil(String route) {
    Navigator.of(this).popUntil(ModalRoute.withName(route));
  }

  void popUntilRoot() {
    Navigator.of(this).popUntil((route) => route.isFirst);
  }
}

// List extensions
extension ListExtension<T> on List<T> {
  List<T> distinct() {
    return toSet().toList();
  }

  List<T> sortBy<S extends Comparable<S>>(S Function(T) key) {
    final sorted = [...this];
    sorted.sort((a, b) => key(a).compareTo(key(b)));
    return sorted;
  }

  List<T> sortByDescending<S extends Comparable<S>>(S Function(T) key) {
    final sorted = [...this];
    sorted.sort((a, b) => key(b).compareTo(key(a)));
    return sorted;
  }
}

// Widget extensions
extension WidgetExtension on Widget {
  Widget withPadding(EdgeInsetsGeometry padding) {
    return Padding(
      padding: padding,
      child: this,
    );
  }

  Widget centered() {
    return Center(child: this);
  }

  Widget expanded({int flex = 1}) {
    return Expanded(
      flex: flex,
      child: this,
    );
  }
}
