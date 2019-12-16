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
    String subtitle,
    Color background,
    Color foreground,
    EdgeInsets padding,
    Widget leading,
  }) {
    showSimpleNotification(
      Text(content),
      subtitle: Text(subtitle),
      background: background,
      foreground: foreground,
      contentPadding: padding,
      leading: leading,
    );
  }
}

class NotificationConfiguration {
  final String content;
  final String subtitle;

  const NotificationConfiguration({this.content, this.subtitle});
}

enum NotificationType { error, content, success, information }
