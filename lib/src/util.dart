import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_zkteco/flutter_zkteco.dart';

class Util {
  static const int USHRT_MAX = 65535;

  static const int CMD_CONNECT = 1000;
  static const int CMD_EXIT = 1001;
  static const int CMD_ENABLE_DEVICE = 1002;
  static const int CMD_DISABLE_DEVICE = 1003;
  static const int CMD_RESTART = 1004;
  static const int CMD_POWEROFF = 1005;
  static const int CMD_SLEEP = 1006;
  static const int CMD_RESUME = 1007;
  static const int CMD_TEST_TEMP = 1011;
  static const int CMD_TESTVOICE = 1017;
  static const int CMD_CHANGE_SPEED = 1101;

  static const int CMD_WRITE_LCD = 66;
  static const int CMD_CLEAR_LCD = 67;

  static const int CMD_ACK_OK = 2000;
  static const int CMD_ACK_ERROR = 2001;
  static const int CMD_ACK_DATA = 2002;
  static const int CMD_ACK_UNAUTH = 2005;

  static const int CMD_PREPARE_DATA = 1500;
  static const int CMD_DATA = 1501;
  static const int CMD_FREE_DATA = 1502;

  static const int CMD_USER_TEMP_RRQ = 9;
  static const int CMD_ATT_LOG_RRQ = 13;
  static const int CMD_CLEAR_DATA = 14;
  static const int CMD_CLEAR_ATT_LOG = 15;

  static const int CMD_GET_TIME = 201;
  static const int CMD_SET_TIME = 202;

  static const int CMD_VERSION = 1100;
  static const int CMD_DEVICE = 11;

  static const int CMD_SET_USER = 8;
  static const int CMD_USER_TEMP_WRQ = 10;
  static const int CMD_DELETE_USER = 18;
  static const int CMD_DELETE_USER_TEMP = 19;
  static const int CMD_CLEAR_ADMIN = 20;

  static const int LEVEL_USER = 0;
  static const int LEVEL_ADMIN = 14;

  static const int FCT_ATTLOG = 1;
  static const int FCT_WORKCODE = 8;
  static const int FCT_FINGERTMP = 2;
  static const int FCT_OPLOG = 4;
  static const int FCT_USER = 5;
  static const int FCT_SMS = 6;
  static const int FCT_UDATA = 7;

  static const String COMMAND_TYPE_GENERAL = 'general';
  static const String COMMAND_TYPE_DATA = 'data';

  static const int ATT_STATE_FINGERPRINT = 1;
  static const int ATT_STATE_PASSWORD = 0;
  static const int ATT_STATE_CARD = 2;

  static const int ATT_TYPE_CHECK_IN = 0;
  static const int ATT_TYPE_CHECK_OUT = 1;
  static const int ATT_TYPE_OVERTIME_IN = 4;
  static const int ATT_TYPE_OVERTIME_OUT = 5;

  /// Encodes a [DateTime] into a [int] that can be sent to the device.
  ///
  /// The [DateTime] is parsed into its constituent parts, then multiplied
  /// and added together to produce a single [int] that can be sent to the
  /// device.
  ///
  /// The formula used is:
  ///
  ///   (((year % 100) * 12 * 31 + ((month - 1) * 31) + day - 1) *
  ///    (24 * 60 * 60)) +
  ///   ((hour * 60 + minute) * 60) +
  ///   second
  ///
  /// This method returns the [int] that can be sent to the device.
  static int encodeTime(DateTime dateTime) {
    // Extract year, month, day, hour, minute, second from DateTime
    int year = dateTime.year;
    int month = dateTime.month;
    int day = dateTime.day;
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    int second = dateTime.second;

    // Calculate the number of days since the start of the century
    int daysSinceEpoch =
        ((year % 100) * 12 * 31 + ((month - 1) * 31) + (day - 1)) *
            (24 * 60 * 60);

    // Calculate the number of seconds in the current day
    int secondsInDay = (hour * 60 + minute) * 60 + second;

    // Total seconds since the start of the century
    return daysSinceEpoch + secondsInDay;
  }

  /// Decodes a [int] received from the device into a [DateTime].
  ///
  /// The [int] is parsed into its constituent parts, then converted into a
  /// [DateTime] object. The formula used is:
  ///
  ///   year = t ~/ 12 + 2000
  ///   month = t % 12 + 1
  ///   day = t % 31 + 1
  ///   hour = t % 24
  ///   minute = t % 60
  ///   second = t % 60
  ///
  /// This method returns a [String] containing the [DateTime] in ISO8601 format.
  static String decodeTime(int t) {
    int second = t % 60;
    t = t ~/ 60;

    int minute = t % 60;
    t = t ~/ 60;

    int hour = t % 24;
    t = t ~/ 24;

    int day = t % 31 + 1;
    t = t ~/ 31;

    int month = t % 12 + 1;
    t = t ~/ 12;

    int year = t + 2000;

    return DateTime(year, month, day, hour, minute, second).toIso8601String();
  }

  /// Converts a [Uint8List] of bytes into a hexadecimal string.
  ///
  /// Each byte is converted to a hexadecimal string using [int.toRadixString]
  /// with radix 16, and then padded with leading zeros to a length of 2
  /// characters. The resulting strings are then joined together into a single
  /// string with no separator. For example, if [bytes] is `Uint8List.fromList([1, 2, 3, 4])`,
  /// this method returns `"01020304"`.
  static String bin2hex(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Reverses a hexadecimal string by swapping each pair of characters.
  ///
  /// This method takes a string of hexadecimal digits and returns a new string
  /// with the same digits, but in reverse order. For example, if [hex] is
  /// "001122334455", this method returns "554433221100".
  ///
  /// The method is used to reverse the byte order of data received from the
  /// device, as the device sends data in little-endian order, but Dart's
  /// [ByteData] class stores data in big-endian order.
  static String reverseHex(String hex) {
    StringBuffer sb = StringBuffer();
    for (int i = hex.length; i > 0; i -= 2) {
      String value = hex.substring(i - 2, i);
      sb.write(value);
    }
    return sb.toString();
  }

  /// Returns the size of the data to be sent to the device as an [int], or
  /// [null] if the device has not sent enough data to be unpacked.
  ///
  /// This method unpacks the first 8 bytes of [dataRecv] to get the command
  /// and checks if it is equal to [CMD_PREPARE_DATA]. If it is, it then
  /// unpacks the next 4 bytes to get the size of the data to be sent to the
  /// device. If the command is not equal to [CMD_PREPARE_DATA], this method
  /// returns [null].
  static int? getSize(ZKTeco self) {
    // Ensure dataRecv has at least 8 bytes
    if (self.dataRecv.length < 8) {
      return null;
    }

    // Extract the first 8 bytes and convert to hex
    String h1 = self.dataRecv[0].toRadixString(16).padLeft(2, '0');
    String h2 = self.dataRecv[1].toRadixString(16).padLeft(2, '0');
    // String h3 = self.dataRecv[2].toRadixString(16).padLeft(2, '0');
    // String h4 = self.dataRecv[3].toRadixString(16).padLeft(2, '0');
    // String h5 = self.dataRecv[4].toRadixString(16).padLeft(2, '0');
    // String h6 = self.dataRecv[5].toRadixString(16).padLeft(2, '0');
    // String h7 = self.dataRecv[6].toRadixString(16).padLeft(2, '0');
    // String h8 = self.dataRecv[7].toRadixString(16).padLeft(2, '0');
    int command = int.parse(h2 + h1, radix: 16);

    // Unpack the first 8 bytes
    // ByteData byteData =
    //     ByteData.sublistView(Uint8List.fromList(self.dataRecv.sublist(0, 8)));
    // int command = byteData.getUint16(0, Endian.little);

    if (command == CMD_PREPARE_DATA) {
      // Ensure dataRecv has at least 12 bytes
      if (self.dataRecv.length < 12) return null;

      // Extract the next 4 bytes
      String h9 = self.dataRecv[8].toRadixString(16).padLeft(2, '0');
      String h10 = self.dataRecv[9].toRadixString(16).padLeft(2, '0');
      String h11 = self.dataRecv[10].toRadixString(16).padLeft(2, '0');
      String h12 = self.dataRecv[11].toRadixString(16).padLeft(2, '0');

      // ByteData sizeData = ByteData.sublistView(
      //     Uint8List.fromList(self.dataRecv.sublist(8, 12)));
      // int size = sizeData.getUint32(0, Endian.little);

      int size = int.parse(h12 + h11 + h10 + h9, radix: 16);
      return size;
    } else {
      return null;
    }
  }

  /// Calculates a checksum of the provided data.
  ///
  /// The method is based on the algorithm used by the ZKTeco devices to
  /// calculate checksums. It processes the data in chunks of 2 bytes, and
  /// handles overflow and signed-ness of the checksum. The method returns a
  /// [Uint8List] containing the checksum as a 2-byte, little-endian, unsigned
  /// integer.
  static Uint8List createChkSum(List<int> p) {
    int l = p.length;
    int chksum = 0;
    int i = l;
    int j = 0;

    while (i > 1) {
      // Equivalent to unpacking 2 bytes ('S' in PHP)
      int u = (p[j] & 0xFF) | ((p[j + 1] & 0xFF) << 8);
      chksum += u;

      // Handle overflow (equivalent to `USHRT_MAX` in PHP)
      if (chksum > 0xFFFF) {
        chksum -= 0xFFFF;
      }

      i -= 2;
      j += 2;
    }

    // If there's an odd byte, add it to the checksum
    if (i > 0) {
      chksum += (p[l - 1] & 0xFF);
    }

    // Reduce checksum in case of overflow
    while (chksum > 0xFFFF) {
      chksum -= 0xFFFF;
    }

    // Handle signed-ness of checksum (negate if positive)
    if (chksum > 0) {
      chksum = -chksum;
    } else {
      chksum = chksum.abs();
    }

    chksum -= 1;

    // Make sure the checksum is positive and fits within the range
    while (chksum < 0) {
      chksum += 0xFFFF;
    }

    // Return packed checksum (2 bytes)
    ByteData byteData = ByteData(2);
    byteData.setUint16(0, chksum, Endian.little);
    return byteData.buffer.asUint8List();
  }

  /// Creates a header for a command to send to the device.
  ///
  /// The [command] parameter is the command to send to the device.
  ///
  /// The [chksum] parameter is the initial checksum value.
  ///
  /// The [sessionId] parameter is the session ID to send with the command.
  ///
  /// The [replyId] parameter is the reply ID to send with the command.
  ///
  /// The [commandString] parameter is the string to include with the command.
  ///
  /// The method returns a [Uint8List] containing the header, with the
  /// checksum updated and the reply ID incremented.
  static List<int> createHeader(int command, int chksum, int sessionId,
      int replyId, String commandString) {
    // Create ByteData to pack header fields
    ByteData byteData = ByteData(8);
    byteData.setUint16(0, command, Endian.little);
    byteData.setUint16(2, chksum, Endian.little);
    byteData.setUint16(4, sessionId, Endian.little);
    byteData.setUint16(6, replyId, Endian.little);

    // Convert ByteData to Uint8List
    Uint8List buf = byteData.buffer.asUint8List();

    Uint8List commandStringBytes = Uint8List.fromList(commandString.codeUnits);

    // Append the command string
    buf = Uint8List.fromList(buf + commandStringBytes);

    // Calculate checksum
    Uint8List checksum = createChkSum(buf);

    // Update the checksum in the buffer
    ByteData updatedByteData = ByteData.view(buf.buffer);
    updatedByteData.setUint16(
        2, (checksum[0] | (checksum[1] << 8)), Endian.little);

    // Increment replyId
    replyId += 1;
    if (replyId >= USHRT_MAX) {
      replyId -= USHRT_MAX;
    }

    // Update replyId in the buffer
    updatedByteData.setUint16(6, replyId, Endian.little);

    // Final buffer with the command string appended
    return updatedByteData.buffer.asUint8List();
  }

  /// Checks if the response from the device is valid.
  ///
  /// The method takes a [Uint8List] as input, which should be the response
  /// from the device. The method returns [true] if the response is valid and
  /// [false] otherwise.
  ///
  /// A valid response is one in which the first byte is either [CMD_ACK_OK]
  /// or [CMD_ACK_UNAUTH].
  static bool checkValid(List<int> reply) {
    String h1 = reply
        .sublist(0, 1)
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    String h2 = reply
        .sublist(1, 2)
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    // Combine the hex values into a command
    int command = int.parse(h2 + h1, radix: 16);

    // Compare the command with CMD_ACK_OK and CMD_ACK_UNAUTH
    if (command == CMD_ACK_OK || command == CMD_ACK_UNAUTH) {
      return true;
    } else {
      return false;
    }
  }

  /// Converts a user role to a string.
  ///
  /// The method takes a [int] as input, which should be one of the
  /// following values:
  ///
  /// * [LEVEL_USER]
  /// * [LEVEL_ADMIN]
  ///
  /// The method returns a [String] containing one of the following values:
  ///
  /// * 'User'
  /// * 'Admin'
  /// * 'Unknown'
  static String getUserRole(int role) {
    switch (role) {
      case LEVEL_USER:
        return 'User';
      case LEVEL_ADMIN:
        return 'Admin';
      default:
        return 'Unknown';
    }
  }

  /// Converts an attendance state to a string.
  ///
  /// The method takes a [int] as input, which should be one of the
  /// following values:
  ///
  /// * [ATT_STATE_FINGERPRINT]
  /// * [ATT_STATE_PASSWORD]
  /// * [ATT_STATE_CARD]
  ///
  /// The method returns a [String] containing one of the following values:
  ///
  /// * 'Fingerprint'
  /// * 'Password'
  /// * 'Card'
  /// * 'Unknown'
  static String getAttState(int state) {
    switch (state) {
      case ATT_STATE_FINGERPRINT:
        return 'Fingerprint';
      case ATT_STATE_PASSWORD:
        return 'Password';
      case ATT_STATE_CARD:
        return 'Card';
      default:
        return 'Unknown';
    }
  }

  /// Converts an attendance type to a string.
  ///
  /// The method takes a [int] as input, which should be one of the
  /// following values:
  ///
  /// * [ATT_TYPE_CHECK_IN]
  /// * [ATT_TYPE_CHECK_OUT]
  /// * [ATT_TYPE_OVERTIME_IN]
  /// * [ATT_TYPE_OVERTIME_OUT]
  ///
  /// The method returns a [String] containing one of the following values:
  ///
  /// * 'Check-in'
  /// * 'Check-out'
  /// * 'Overtime-in'
  /// * 'Overtime-out'
  /// * 'Undefined'
  static String getAttType(int type) {
    switch (type) {
      case ATT_TYPE_CHECK_IN:
        return 'Check-in';
      case ATT_TYPE_CHECK_OUT:
        return 'Check-out';
      case ATT_TYPE_OVERTIME_IN:
        return 'Overtime-in';
      case ATT_TYPE_OVERTIME_OUT:
        return 'Overtime-out';
      default:
        return 'Undefined';
    }
  }

  /// Receives data from the device.
  ///
  /// The method sends a command to the device to receive data. The device
  /// must be connected and authenticated before this method can be used.
  ///
  /// The method returns a [Future] that completes with a [Uint8List] containing
  /// the received data, or [null] if no data was received or if the device
  /// could not be queried.
  ///
  /// The [first] parameter is a [bool] indicating if this is the first time
  /// this method is called for the current command. If [first] is [true],
  /// the method sends a command to the device to receive data. If [first] is
  /// [false], the method does not send a command to the device and instead
  /// waits for the device to send data. The default value of [first] is
  /// [true].
  static Future<Uint8List?> recData(ZKTeco self, {bool first = true}) async {
    int? bytes = getSize(self);

    if (bytes == null || bytes <= 0) {
      return null;
    }

    return await _parseData(self, bytes, first);
  }

  /// Parses the received data from the device.
  ///
  /// The method takes a [ZKTeco] object, the number of bytes to receive, and
  /// a [bool] indicating if this is the first time this method is called for
  /// the current command as parameters. If [first] is [true], the method
  /// expects the first 8 bytes of the received data to be a header, and
  /// skips the header. If [first] is [false], the method does not skip the
  /// header.
  ///
  /// The method returns a [Future] that completes with a [Uint8List]
  /// containing the received data. The [Future] completes when all expected
  /// data has been received, or when the device stops sending data. If the
  /// device stops sending data before all expected data has been received,
  /// the [Future] completes with the data that has been received so far.
  static Future<Uint8List> _parseData(
      ZKTeco self, int bytes, bool first) async {
    BytesBuilder data = BytesBuilder();
    int received = 0;

    await for (Datagram datagram in self.streamController.stream) {
      Uint8List dataRec = datagram.data;

      if (!first) {
        // Skip the first 8 bytes
        dataRec = Uint8List.sublistView(dataRec, 8);
      }

      data.add(dataRec);
      received += dataRec.length;
      first = false;

      debugPrint('Received: $received / $bytes');
      if (received >= bytes) break;
    }
    return data.takeBytes();
  }

  /// Prints a debug message indicating how many bytes have been received so
  /// far, out of the total number of bytes expected.
  ///
  /// The method takes a [ZKTeco] object, the number of bytes received so far,
  /// and the total number of bytes expected as parameters. The method
  /// prints a message to the console in the format "Received $received bytes
  /// out of $total bytes".
  static void logReceived(ZKTeco self, int received, int total) {
    debugPrint('Received $received bytes out of $total bytes');
  }

  /// Converts a hexadecimal string to a [Uint8List] of bytes.
  ///
  /// The method takes a [String] as input, which must have an even length.
  /// The method throws an [ArgumentError] if the input string has an odd
  /// length. The method returns a [Uint8List] containing the bytes equivalent
  /// to the input hexadecimal string.
  static Uint8List hex2bin(String hex) {
    if (hex.length % 2 != 0) {
      throw ArgumentError("Hex string must have an even length.");
    }

    // Convert hex string to bytes
    Uint8List bytes = Uint8List(hex.length ~/ 2);
    for (int i = 0; i < hex.length; i += 2) {
      bytes[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
    }

    return bytes;
  }

  /// Converts a [Uint8List] of bytes to a hexadecimal string.
  ///
  /// The method takes a [Uint8List] as input and returns a string in which
  /// each byte is converted to a 2-character hexadecimal string using
  /// [int.toRadixString] with radix 16, and then padded with leading zeros
  /// to a length of 2 characters. The resulting strings are then joined
  /// together into a single string with no separator. For example, if
  /// [bytes] is `Uint8List.fromList([1, 2, 3, 4])`, this method returns
  /// `"01020304"`.
  static String byteToHex(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}
