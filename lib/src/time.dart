import 'dart:typed_data';

import 'package:flutter_zkteco/flutter_zkteco.dart';
import 'package:flutter_zkteco/src/util.dart';

class Time {
  /// Sets the device's time to the given [DateTime].
  ///
  /// The method returns a [Future] that completes with a [bool] indicating if
  /// the device's time was successfully set, or a [String] containing an error
  /// message if the device could not be queried.
  static dynamic set(ZKTeco self, DateTime $date) async {
    int command = Util.CMD_SET_TIME;
    int encodedTime = Util.encodeTime($date);

    ByteData byteData = ByteData(4);
    byteData.setUint32(0, encodedTime, Endian.little);

    String commandString = String.fromCharCodes(byteData.buffer.asUint8List());

    dynamic reply = await self.command(command, commandString);

    if (reply is bool) {
      return reply;
    }

    return String.fromCharCodes(reply);
  }

  /// Returns the current time of the device as a [String] in the format
  /// "HH:MM:SS DD/MM/YYYY".
  ///
  /// This method sends a command to the device to retrieve its current time.
  /// The device must be connected and authenticated before this method can be
  /// used.
  ///
  /// The method returns a [Future] that completes with a [String] containing
  /// the current time of the device, or a [bool] indicating if the device
  /// could not be queried.
  static dynamic get(ZKTeco self) async {
    int command = Util.CMD_GET_TIME;
    String commandString = '';

    dynamic reply = await self.command(command, commandString);

    if (reply is bool) {
      return reply;
    }

    String bin2hexString = Util.bin2hex(reply);
    String reverseHex = Util.reverseHex(bin2hexString);
    Uint8List reverseHexBytes = Util.hex2bin(reverseHex);
    int time = reverseHexBytes.buffer.asByteData().getUint32(0, Endian.big);
    return Util.decodeTime(time);
  }
}
