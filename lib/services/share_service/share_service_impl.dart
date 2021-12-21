import 'package:share_plus/share_plus.dart';

import 'share_service_interface.dart';

class ShareService implements IShareService {
  @override
  Future<void> share(String text, {String? subject}) async {
    await Share.share(
      text,
      subject: subject,
    );
  }
}
