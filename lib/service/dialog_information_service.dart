import 'package:flutter/material.dart';

import 'package:overlay_support/overlay_support.dart';

class DialogInformationService {
  static final DialogInformationService instance = DialogInformationService._();

  factory DialogInformationService() => instance;

  DialogInformationService._();

  void showNotification(
    NotificationType type, {
    NotificationConfiguration config,
  }) {
    Color background, foreground;
    EdgeInsets padding;
    Widget leading;

    switch (type) {
      case NotificationType.error:
        background = Colors.redAccent;
        foreground = Color(0xFFFFFFFF);
        break;
      case NotificationType.success:
        background = Colors.redAccent;
        foreground = Color(0xFFFFFFFF);
        break;
      case NotificationType.content:
      case NotificationType.information:
      default:
        leading = Icon(Icons.info_outline);
        break;
    }

    _showInformationNotification(
      content: config.content,
      subtitle: config.subtitle,
      background: background,
      foreground: foreground,
      padding: padding,
      leading: leading,
    );
  }

  void _showInformationNotification({
    String content,
    String subtitle = '',
    Color background,
    Color foreground,
    EdgeInsets padding,
    Widget leading,
  }) {
    showOverlayNotification(
      (context) => SlideDismissible(
        key: ValueKey(content),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
              color: background ?? Theme.of(context)?.accentColor,
              elevation: 16,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: ListTileTheme(
                textColor: foreground ??
                    Theme.of(context)?.accentTextTheme?.title?.color,
                iconColor: foreground ??
                    Theme.of(context)?.accentTextTheme?.title?.color,
                child: ListTile(
                  dense: true,
                  leading: leading,
                  title: Text(content),
                  subtitle: subtitle != null ? Text(subtitle) : null,
                  // trailing: trailing,
                  contentPadding: padding,
                ),
              ),
            ),
          ),
        ),
        enable: true,
      ),
      duration: Duration(seconds: 4),
    );
    // showSimpleNotification(
    //   Text(content),
    //   subtitle: subtitle != null ? Text(subtitle) : null,
    //   background: background,
    //   foreground: foreground,
    //   contentPadding: padding,
    //   leading: leading,
    // );
  }
}

class NotificationConfiguration {
  final String content;
  final String subtitle;

  const NotificationConfiguration({this.content, this.subtitle});
}

enum NotificationType { error, content, success, information }
