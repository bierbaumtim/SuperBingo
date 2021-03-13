import 'package:share/share.dart';

import 'share_service_interface.dart';

class MobileShareService implements IShareService {
  @override
  Future<void> share(String text, {String? subject}) async => Share.share(
        text,
        subject: subject,
      );
}

IShareService getShareService() => MobileShareService();
