import 'package:url_launcher/url_launcher.dart';

class UrlLauncherHelper {
  static Future<bool> openUrl(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      return false;
    }
  }

  static Future<bool> makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    try {
      return await launchUrl(uri);
    } catch (_) {
      return false;
    }
  }
}
