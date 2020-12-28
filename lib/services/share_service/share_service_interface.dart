import 'share_service_stub.dart'
    if (dart.library.io) 'mobile_share_service_impl.dart'
    if (dart.library.html) 'web_share_service_impl.dart';

abstract class IShareService {
  Future<void> share(String text, {String subject});

  factory IShareService() => getShareService();
}
