import 'package:flutter/material.dart';
import 'package:twitter_alternative/app/theme/color_theme.dart';
import 'package:twitter_alternative/core/widgets/custom_button.dart';

class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool withScaffold;
  final String? retryText;
  final IconData? icon;

  const ErrorDisplay({
    Key? key,
    required this.message,
    this.onRetry,
    this.withScaffold = false,
    this.retryText = 'Retry',
    this.icon = Icons.error_outline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget content = Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 64,
                color: ColorTheme.error,
              ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: retryText!,
                onPressed: onRetry!,
                isFullWidth: false,
                type: ButtonType.primary,
                width: 120,
              ),
            ],
          ],
        ),
      ),
    );

    if (withScaffold) {
      return Scaffold(
        body: content,
      );
    }

    return content;
  }
}

class NoDataWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onAction;
  final String? actionText;
  final IconData? icon;

  const NoDataWidget({
    Key? key,
    required this.message,
    this.onAction,
    this.actionText,
    this.icon = Icons.hourglass_empty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 64,
                color: Theme.of(context).brightness == Brightness.light
                    ? ColorTheme.textLight
                    : Colors.grey,
              ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? ColorTheme.textLight
                        : Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: actionText!,
                onPressed: onAction!,
                isFullWidth: false,
                type: ButtonType.primary,
                width: 160,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
