import 'package:flutter_zkteco/flutter_zkteco.dart';
import 'package:flutter_zkteco/src/util.dart';

class Face {
  static Future<dynamic> on(ZKTeco self) async {
    int command = Util.CMD_VERSION;
    String commandString = 'FaceFunOn';

    dynamic reply = await self.command(command, commandString);

    if (reply is bool) {
      return reply;
    }

    return String.fromCharCodes(reply);
  }
}
