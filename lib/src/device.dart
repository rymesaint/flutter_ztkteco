import 'package:flutter_zkteco/flutter_zkteco.dart';
import 'package:flutter_zkteco/src/util.dart';

class Device {
  /// Returns the name of the device as a [String].
  ///
  /// This method sends a command to the device to retrieve its name. The device
  /// must be connected and authenticated before this method can be used.
  ///
  /// The method returns a [Future] that completes with a [String] containing the
  /// name of the device, or a [bool] indicating if the device could not be
  /// queried.
  static Future<dynamic> name(ZKTeco self) async {
    int command = Util.CMD_DEVICE;
    String commandString = '~DeviceName';

    dynamic reply = await self.command(command, commandString);

    if (reply is bool) {
      return reply;
    }

    return String.fromCharCodes(reply);
  }

  /// Enables the device.
  ///
  /// This method sends a command to the device to enable it. The device must
  /// be connected and authenticated before this method can be used.
  ///
  /// The method returns a [Future] that completes with a [bool] indicating if
  /// the device was successfully enabled, or a [String] containing an error
  /// message if the device could not be enabled.
  ///
  /// If the device is already enabled, this method does nothing and returns
  /// [true].
  static Future<dynamic> enable(ZKTeco self) async {
    int command = Util.CMD_ENABLE_DEVICE;
    String commandString = '';

    dynamic reply = await self.command(command, commandString);

    if (reply is bool) {
      return reply;
    }

    return String.fromCharCodes(reply);
  }

  /// Disables the device.
  ///
  /// This method sends a command to the device to disable it. The device must
  /// be connected and authenticated before this method can be used.
  ///
  /// The method returns a [Future] that completes with a [bool] indicating if
  /// the device was successfully disabled, or a [String] containing an error
  /// message if the device could not be disabled.
  ///
  /// If the device is already disabled, this method does nothing and returns
  /// [true].
  static Future<dynamic> disable(ZKTeco self) async {
    int command = Util.CMD_DISABLE_DEVICE;
    String commandString = String.fromCharCodes([0x00, 0x00]);

    dynamic reply = await self.command(command, commandString);

    if (reply is bool) {
      return reply;
    }

    return String.fromCharCodes(reply);
  }

  /// Powers off the device.
  ///
  /// This method sends a command to the device to power it off. The device must
  /// be connected and authenticated before this method can be used.
  ///
  /// The method returns a [Future] that completes with a [bool] indicating if
  /// the device was successfully powered off, or a [String] containing an error
  /// message if the device could not be powered off.
  static Future<dynamic> powerOff(ZKTeco self) async {
    int command = Util.CMD_POWEROFF;
    String commandString = String.fromCharCodes([0x00, 0x00]);

    dynamic reply = await self.command(command, commandString);

    if (reply is bool) {
      return reply;
    }

    return String.fromCharCodes(reply);
  }

  /// Restarts the device.
  ///
  /// This method sends a command to the device to restart it. The device must
  /// be connected and authenticated before this method can be used.
  ///
  /// The method returns a [Future] that completes with a [bool] indicating if
  /// the device was successfully restarted, or a [String] containing an error
  /// message if the device could not be restarted.
  static Future<dynamic> restart(ZKTeco self) async {
    int command = Util.CMD_RESTART;
    String commandString = String.fromCharCodes([0x00, 0x00]);

    dynamic reply = await self.command(command, commandString);

    if (reply is bool) {
      return reply;
    }

    return String.fromCharCodes(reply);
  }

  /// Puts the device into sleep mode.
  ///
  /// This method sends a command to the device to put it into sleep mode. The
  /// device must be connected and authenticated before this method can be used.
  ///
  /// The method returns a [Future] that completes with a [bool] indicating if
  /// the device was successfully put into sleep mode, or a [String] containing
  /// an error message if the device could not be put into sleep mode.
  static Future<dynamic> sleep(ZKTeco self) async {
    int command = Util.CMD_SLEEP;
    String commandString = String.fromCharCodes([0x00, 0x00]);

    dynamic reply = await self.command(command, commandString);

    if (reply is bool) {
      return reply;
    }

    return String.fromCharCodes(reply);
  }

  /// Resumes the device from sleep mode.
  ///
  /// This method sends a command to the device to resume from sleep mode.
  /// The device must be connected and authenticated before this method can
  /// be used.
  ///
  /// The method returns a [Future] that completes with a [bool] indicating if
  /// the device was successfully resumed from sleep mode, or a [String]
  /// containing an error message if the device could not be queried.
  static Future<dynamic> resume(ZKTeco self) async {
    int command = Util.CMD_RESUME;
    String commandString = String.fromCharCodes([0x00, 0x00]);

    dynamic reply = await self.command(command, commandString);

    if (reply is bool) {
      return reply;
    }

    return String.fromCharCodes(reply);
  }

  /// Tests the voice of the device.
  ///
  /// This method sends a command to the device to test its voice. The device
  /// must be connected and authenticated before this method can be used.
  ///
  /// The method returns a [Future] that completes with a [bool] indicating if
  /// the voice was successfully tested, or a [String] containing an error
  /// message if the device could not be queried.
  static Future<dynamic> testVoice(ZKTeco self) async {
    int command = Util.CMD_TESTVOICE;
    String commandString = String.fromCharCodes([0x00, 0x00]);

    dynamic reply = await self.command(command, commandString);

    if (reply is bool) {
      return reply;
    }

    return String.fromCharCodes(reply);
  }

  /// Clears the LCD display on the device.
  ///
  /// This method sends a command to the device to clear its LCD display. The
  /// device must be connected and authenticated before this method can be
  /// used.
  ///
  /// The method returns a [Future] that completes with a [bool] indicating if
  /// the device's LCD was successfully cleared, or a [String] containing an
  /// error message if the device could not be queried.
  static Future<dynamic> clearLCD(ZKTeco self) async {
    int command = Util.CMD_CLEAR_LCD;
    String commandString = '';

    dynamic reply = await self.command(command, commandString);

    if (reply is bool) {
      return reply;
    }

    return String.fromCharCodes(reply);
  }

  /// Writes a line of text to the device's LCD display.
  ///
  /// This method sends a command to the device to write a line of text to the
  /// LCD display. The device must be connected and authenticated before this
  /// method can be used.
  ///
  /// The [rank] parameter is the line number on the display to write to. The
  /// value of [rank] must be between 0 and 15, inclusive.
  ///
  /// The [text] parameter is the string to write to the display. The string
  /// should not be longer than 16 characters.
  ///
  /// The method returns a [Future] that completes with a [bool] indicating if
  /// the device was successfully queried, or a [String] containing an error
  /// message if the device could not be queried.
  static Future<dynamic> writeLCD(ZKTeco self, int rank, String text) async {
    int command = Util.CMD_WRITE_LCD;

    // Convert rank to bytes
    final byte1 = rank % 256;
    final byte2 = rank >> 8;
    const byte3 = 0x00;

    String commandString = String.fromCharCodes([byte1, byte2, byte3]) + text;

    dynamic reply = await self.command(command, commandString);

    if (reply is bool) {
      return reply;
    }

    return String.fromCharCodes(reply);
  }
}
