import 'package:permission_handler/permission_handler.dart';

class PermissionService {

  static Future<void> requestCallPermissions()
  async {

    await [
      Permission.microphone,
      Permission.camera,
    ].request();
  }
}