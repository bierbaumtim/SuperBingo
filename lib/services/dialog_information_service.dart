import 'package:flutter/material.dart';

import 'package:overlay_support/overlay_support.dart';

class DialogInformationService {
  static final DialogInformationService instance = DialogInformationService._();

  factory DialogInformationService() => instance;

  DialogInformationService._() {
    _disabled = false;
  }

  late bool _disabled;

  // ignore: use_setters_to_change_properties,avoid_positional_boolean_parameters
  @visibleForTesting
  // ignore: avoid_positional_boolean_parameters
  void setDisabled(bool disabled) {
    _disabled = disabled;
  }

  void showNotification(
    NotificationType type, {
    required NotificationConfiguration config,
  }) {
    if (_disabled) return;

    Color? background, foreground;
    EdgeInsets? padding;
    Widget? leading;

    switch (type) {
      case NotificationType.error:
        background = Colors.redAccent;
        foreground = const Color(0xFFFFFFFF);
        break;
      case NotificationType.success:
        background = Colors.redAccent;
        foreground = const Color(0xFFFFFFFF);
        break;
      case NotificationType.content:
      case NotificationType.information:
      default:
        leading = const Icon(Icons.info_outline);
        break;
    }

    _showInformationNotification(
      content: config.content,
      subtitle: config.subtitle,
      duration: config.duration,
      background: background,
      foreground: foreground,
      padding: padding,
      leading: leading,
    );
  }

  void _showInformationNotification({
    String content = '',
    String subtitle = '',
    Duration duration = const Duration(seconds: 4),
    Color? background,
    Color? foreground,
    EdgeInsets? padding,
    Widget? leading,
  }) {
    showOverlayNotification(
      (context) => SlideDismissible(
        key: ValueKey(content),
        direction: DismissDirection.startToEnd,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
              color: background ?? Theme.of(context).accentColor,
              elevation: 16,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: ListTileTheme(
                textColor: foreground ??
                    Theme.of(context).accentTextTheme.headline6?.color,
                iconColor: foreground ??
                    Theme.of(context).accentTextTheme.headline6?.color,
                child: ListTile(
                  dense: true,
                  leading: leading,
                  title: Text(content),
                  subtitle: Text(subtitle),
                  // trailing: trailing,
                  contentPadding: padding,
                ),
              ),
            ),
          ),
        ),
      ),
      duration: duration,
    );
  }
}

class NotificationConfiguration {
  final String content;
  final String subtitle;
  final Duration duration;

  const NotificationConfiguration({
    required this.content,
    this.subtitle = '',
    this.duration = const Duration(seconds: 4),
  });
}

enum NotificationType { error, content, success, information }
