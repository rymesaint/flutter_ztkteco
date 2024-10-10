import 'package:flutter_zkteco/flutter_zkteco.dart';
import 'package:flutter_zkteco/src/util.dart';

class Face {
  /// Turns on the face detection function of the device.
  ///
  /// This method sends a command to the device to turn on its face detection
  /// function. The device must be connected and authenticated before this
  /// method can be used.
  ///
  /// The method returns a [Future] that completes with a [bool] indicating if
  /// the face detection was successfully turned on, or a [String] containing
  /// an error message if the device could not be queried.
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
