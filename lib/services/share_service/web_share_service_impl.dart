import 'dart:html';

import 'share_service_interface.dart';

class MobileShareService implements IShareService {
  @override
  Future<void> share(String text, {String? subject}) async =>
      window.navigator.share(
        {
          'title': subject ?? 'Superbingo',
          'text': text,
        },
      );
}

IShareService getShareService() => MobileShareService();
