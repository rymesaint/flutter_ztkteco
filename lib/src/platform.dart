import 'package:flutter_zkteco/flutter_zkteco.dart';
import 'package:flutter_zkteco/src/util.dart';

class Platform {
  /// Returns the platform of the device as a [String].
  ///
  /// This method sends a command to the device to retrieve its platform. The
  /// device must be connected and authenticated before this method can be
  /// used.
  ///
  /// The method returns a [Future] that completes with a [String] containing
  /// the platform of the device, or a [bool] indicating if the device could
  /// not be queried.
  static Future<dynamic> get(ZKTeco self) async {
    int command = Util.CMD_DEVICE;
    String commandString = '~Platform';

    dynamic reply = await self.command(command, commandString);

    if (reply is bool) {
      return reply;
    }

    return String.fromCharCodes(reply);
  }

  /// Returns the version of the device as a [String].
  ///
  /// This method sends a command to the device to retrieve its version. The
  /// device must be connected and authenticated before this method can be
  /// used.
  ///
  /// The method returns a [Future] that completes with a [String] containing
  /// the version of the device, or a [bool] indicating if the device could not
  /// be queried.
  static Future<dynamic> version(ZKTeco self) async {
    int command = Util.CMD_DEVICE;
    String commandString = '~ZKFPVersion';

    dynamic reply = await self.command(command, commandString);

    if (reply is bool) {
      return reply;
    }

    return String.fromCharCodes(reply);
  }
}