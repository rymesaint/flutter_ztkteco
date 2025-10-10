import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_zkteco/flutter_zkteco.dart';
import 'package:flutter_zkteco/src/error/zk_error_connection.dart';
import 'package:flutter_zkteco/src/model/memory_reader.dart';

class Util {
  static const int USHRT_MAX = 65535;

  static const int CMD_GET_FREE_SIZES = 50;

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
  static const int CMD_AUTH = 1102;

  static const int CMD_WRITE_LCD = 66;
  static const int CMD_CLEAR_LCD = 67;

  static const int CMD_ACK_OK = 2000;
  static const int CMD_ACK_ERROR = 2001;
  static const int CMD_ACK_DATA = 2002;
  static const int CMD_ACK_UNAUTH = 2005;

  static const int CMD_PREPARE_DATA = 1500;
  static const int CMD_DATA = 1501;
  static const int CMD_FREE_DATA = 1502;
  static const int CMD_PREPARE_BUFFER = 1503;
  static const int CMD_READ_BUFFER = 1504;

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

  // Reference https://github.com/fananimi/pyzk/blob/master/zk/const.py#L91
  static const int CMD_REG_EVENT = 500;

  static const int CMD_STARTVERIFY = 60;
  static const int CMD_CANCELCAPTURE = 62;

  static const int EF_ATTLOG = 1;
  static const int EF_FINGER = (1 << 1);
  static const int EF_ENROLLUSER = (1 << 2);
  static const int EF_ENROLLFINGER = (1 << 3);
  static const int EF_BUTTON = (1 << 4);
  static const int EF_UNLOCK = (1 << 5);
  static const int EF_VERIFY = (1 << 7);
  static const int EF_FPFTR = (1 << 8);
  static const int EF_ALARM = (1 << 9);

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

  static const int MACHINE_PREPARE_DATA_1 = 20560;
  static const int MACHINE_PREPARE_DATA_2 = 32130;

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

  /// Decodes an integer [t] into a [DateTime] object.
  ///
  /// The integer is assumed to represent the number of seconds since the start
  /// of the 21st century (year 2000). The decoding process involves extracting
  /// the year, month, day, hour, minute, and second components from the integer
  /// by performing a series of modulus and division operations. The resulting
  /// components are used to construct and return a [DateTime] object.
  ///
  /// This method assumes the date and time are encoded with the following scheme:
  /// - Seconds in a minute: 0-59
  /// - Minutes in an hour: 0-59
  /// - Hours in a day: 0-23
  /// - Days in a month: 1-31
  /// - Months in a year: 1-12
  /// - Years since 2000: 0-99
  static DateTime decodeTime(int t) {
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

    return DateTime(year, month, day, hour, minute, second);
  }

  static DateTime decodeTimeHex(List<int> timehex) {
    if (timehex.length < 6) {
      throw ArgumentError("Invalid timehex length: ${timehex.length}");
    }

    final year = timehex[0] + 2000;
    final month = timehex[1];
    final day = timehex[2];
    final hour = timehex[3];
    final minute = timehex[4];
    final second = timehex[5];

    return DateTime(year, month, day, hour, minute, second);
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

  /// Reads the sizes of the device's memory.
  ///
  /// This method sends a command to the device to retrieve the sizes of its
  /// memory. The device must be connected and authenticated before this
  /// method can be used.
  ///
  /// The method returns a [Future] that completes with a [MemoryReader]
  /// object, or [null] if the device could not be queried. The [MemoryReader]
  /// object contains information about the number of users, fingerprints, and
  /// attendance records stored in the device's memory.
  static Future<MemoryReader?> readSizes(ZKTeco self) async {
    if (self.debug) {
      debugPrint(
          'DATA! is ${self.dataRecv.length} bytes, tcp length is ${self.tcpLength}');
    }
    final Map<String, dynamic> response =
        await self.command(CMD_GET_FREE_SIZES);

    if (response['status'] == false) {
      throw ZKNetworkError("Can't read sizes");
    }

    if (self.debug) {
      debugPrint(
          'Raw Data: ${self.data.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}');
    }

    MemoryReader? reader;
    final size = self.data.length;

    if (size >= 80) {
      final byteData =
          ByteData.sublistView(Uint8List.fromList(self.data), 0, 80);
      final fields =
          List.generate(20, (i) => byteData.getInt32(i * 4, Endian.little));
      reader = MemoryReader(
        users: fields[4],
        fingers: fields[6],
        records: fields[8],
        dummy: fields[10], // Unknown field
        cards: fields[12],
        fingersCap: fields[14],
        usersCap: fields[15],
        recCap: fields[16],
        fingersAv: fields[17],
        usersAv: fields[18],
        recAv: fields[19],
      );
      self.data = self.data.sublist(80);
    }

    if (self.data.length >= 12) {
      final byteData =
          ByteData.sublistView(Uint8List.fromList(self.data), 0, 12);
      final fields =
          List.generate(3, (i) => byteData.getInt32(i * 4, Endian.little));
      reader = reader?.copyWith(
        faces: fields[0],
        facesCap: fields[2],
      );
    }
    return reader;
  }

  /// Extracts the size of the data from the first 4 bytes of the buffer.
  ///
  /// If the buffer is too small, returns `null`.
  ///
  /// If the command is not `CMD_PREPARE_DATA`, returns `null`.
  ///
  /// Otherwise, returns the size of the data as a 32-bit little-endian unsigned integer.
  static int? getSize(ZKTeco self) {
    // Extract the command (first 2 bytes, little-endian)
    final int header = self.header[0];

    if (header == CMD_PREPARE_DATA) {
      final byteData = ByteData.sublistView(Uint8List.fromList(self.data));
      int size = byteData.getUint32(0, Endian.little);

      if (self.debug) {
        debugPrint('Extracted size: $size');
      }

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
  static Uint8List createChkSum(List<int> packet) {
    int length = packet.length;
    int chksum = 0;
    int i = 0;

    while (length > 1) {
      int val = packet[i] | (packet[i + 1] << 8);
      chksum += val;
      if (chksum > USHRT_MAX) {
        chksum -= USHRT_MAX;
      }
      i += 2;
      length -= 2;
    }

    if (length > 0) {
      chksum += packet.last;
    }

    // Reduce checksum in case of overflow
    while (chksum > USHRT_MAX) {
      chksum -= USHRT_MAX;
    }

    chksum = ~chksum;

    while (chksum < 0) {
      chksum += USHRT_MAX;
    }

    final ByteData result = ByteData(2);
    result.setUint16(0, chksum, Endian.little);
    return result.buffer.asUint8List();
  }

  /// Creates a packet header for a given command, session ID, and reply ID.
  ///
  /// Calculates the checksum for the header and command string, and updates
  /// the reply ID. The final packet is returned as a list of bytes.
  static List<int> createHeader(
      int command, int sessionId, int replyId, List<int> commandString) {
    // Create ByteData to pack header fields
    ByteData header = ByteData(8);
    header.setUint16(0, command, Endian.little);
    header.setUint16(2, 0, Endian.little);
    header.setUint16(4, sessionId, Endian.little);
    header.setUint16(6, replyId, Endian.little);

    // Step 2: Combine with command string
    final List<int> buf = [...header.buffer.asUint8List(), ...commandString];

    // Calculate checksum
    Uint8List checksumBytes = createChkSum(buf);
    int checksum =
        ByteData.sublistView(checksumBytes).getUint16(0, Endian.little);

    // Update reply ID
    replyId += 1;
    if (replyId >= USHRT_MAX) {
      replyId -= USHRT_MAX;
    }

    final finalBuffer = ByteData(8);
    finalBuffer.setUint16(0, command, Endian.little);
    finalBuffer.setUint16(2, checksum, Endian.little);
    finalBuffer.setUint16(4, sessionId, Endian.little);
    finalBuffer.setUint16(6, replyId, Endian.little);

    return Uint8List.fromList([
      ...finalBuffer.buffer.asUint8List(),
      ...commandString,
    ]);
  }

  /// Creates a communication key based on the given key and session ID.
  ///
  /// The [key] parameter is the key to scramble. The [sessionId] parameter is the
  /// session ID to add to the key. The [ticks] parameter is the number of ticks
  /// to use for the XOR operation. The default is 50.
  ///
  /// The method returns a [Uint8List] containing the communication key.
  static Uint8List makeCommKey(int key, int sessionId, {int ticks = 50}) {
    int k = 0;

    // Bitwise reversal logic
    for (int i = 0; i < 32; i++) {
      if ((key & (1 << i)) != 0) {
        k = (k << 1) | 1;
      } else {
        k <<= 1;
      }
    }

    k += sessionId;

    // Pack k as little-endian 4 bytes
    final kBytes = ByteData(4)..setUint32(0, k, Endian.little);
    final kList = kBytes.buffer.asUint8List();

    // XOR with 'ZKSO'
    final xor1 = Uint8List(4);
    xor1[0] = kList[0] ^ 'Z'.codeUnitAt(0);
    xor1[1] = kList[1] ^ 'K'.codeUnitAt(0);
    xor1[2] = kList[2] ^ 'S'.codeUnitAt(0);
    xor1[3] = kList[3] ^ 'O'.codeUnitAt(0);

    // Repack as two 16-bit integers, swap them, and repack
    final xor1Data = ByteData.sublistView(xor1);
    int h1 = xor1Data.getUint16(0, Endian.little);
    int h2 = xor1Data.getUint16(2, Endian.little);

    final swapped = ByteData(4);
    swapped.setUint16(0, h2, Endian.little);
    swapped.setUint16(2, h1, Endian.little);

    final swappedList = swapped.buffer.asUint8List();

    int B = ticks & 0xFF;

    // Final XOR and pack
    final finalKey = Uint8List(4);
    finalKey[0] = swappedList[0] ^ B;
    finalKey[1] = swappedList[1] ^ B;
    finalKey[2] = B;
    finalKey[3] = swappedList[3] ^ B;

    return finalKey;
  }

  /// Checks if the response from the device is valid.
  ///
  /// The method takes a [Uint8List] as input, which should be the response
  /// from the device. The method returns [true] if the response is valid and
  /// [false] otherwise.
  ///
  /// A valid response is one in which the first byte is either [CMD_ACK_OK]
  /// or [CMD_ACK_UNAUTH].
  bool checkValid(List<int> reply) {
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
  String getUserRole(int role) {
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
  String getAttState(int state) {
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
  String getAttType(int type) {
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
    int attempt = 0;
    int delayMs = 500; // 0.5 seconds delay
    List<int> packetBuffer = [];

    while (attempt < self.retry) {
      attempt++;
      if (self.debug) {
        debugPrint('Attempt $attempt to receive data...');
      }

      if (self.dataRecv.length >= 12) {
        debugPrint('🔍 First 12 bytes: ${self.dataRecv.sublist(0, 12)}');
      }

      int? bytes = getSize(self);

      if (bytes == null || bytes <= 0) {
        if (self.debug) {
          debugPrint(
              '❌ getSize(self) returned an invalid size: $bytes. Retrying...');
        }
        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2; // Double delay each retry (exponential backoff)
        continue;
      }

      if (self.debug) {
        debugPrint('📦 Expected packet size: $bytes bytes');
      }

      try {
        Uint8List data = await parseData(self, bytes, first);
        if (data.isNotEmpty) {
          packetBuffer.addAll(data);

          if (self.debug) {
            debugPrint(
                'Received packet ${packetBuffer.length}, size: ${data.length}');
          }

          if (packetBuffer.length >= bytes) {
            break;
          } else {
            debugPrint(
                '⚠️ Incomplete data: Received ${packetBuffer.length} of $bytes bytes');
          }
        } else {
          if (self.debug) {
            debugPrint('Received an empty packet, retrying...');
          }
        }
      } catch (e) {
        if (self.debug) {
          debugPrint('Error receiving data: $e. Retrying in ${delayMs}ms...');
        }
      }

      await Future.delayed(Duration(milliseconds: delayMs));
      delayMs *= 2; // Increase delay before next retry
    }

    if (packetBuffer.isEmpty) {
      if (self.debug) {
        debugPrint(
            '❌ Failed to receive valid data after ${self.retry} attempts.');
      }
      return null;
    }

    Uint8List fullData = Uint8List.fromList(packetBuffer);

    if (self.debug) {
      debugPrint(
          '✅ Successfully reconstructed ${fullData.length} bytes of data.');
    }
    return fullData;
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
  static Future<Uint8List> parseData(
      ZKTeco self, int expectedBytes, bool first) async {
    BytesBuilder data = BytesBuilder();
    int received = 0;

    // Choose stream depending on connection type
    Stream<Uint8List> stream =
        self.streamController.stream.timeout(self.timeout);

    await for (var bytesData in stream) {
      if (first && self.tcp) {
        // Skip the first 8 bytes
        bytesData = Uint8List.sublistView(bytesData, 8);
      }

      data.add(bytesData);
      received += bytesData.length;
      first = false;

      if (self.debug) {
        Util.logReceived(received, expectedBytes);
      }

      if (received >= expectedBytes) {
        break; // End the loop
      }
    }

    if (received < expectedBytes) {
      throw ZKErrorConnection(
          "Incomplete data received. Expected $expectedBytes, got $received");
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
  static void logReceived(int received, int total) {
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

  /// Extracts a string from a [Uint8List] of bytes.
  ///
  /// The method converts the byte list to a string and splits it at the first
  /// null character (`\x00`). The resulting string before the null character
  /// is returned. If the [trim] parameter is [true], the returned string is
  /// trimmed of any leading and trailing whitespace.
  ///
  /// - [bytes]: The input byte list to extract the string from.
  /// - [trim]: An optional parameter. If set to [true], the extracted string
  ///   is trimmed. Defaults to [false].
  ///
  /// Returns the extracted string, or `null` if the input byte list is empty.
  static String extractString(Uint8List bytes, {bool? trim}) {
    String value = String.fromCharCodes(bytes).split('\x00')[0];

    if (trim == true) {
      return value.trim();
    }

    return value;
  }

  /// Creates a TCP packet with a header and appends the given data.
  ///
  /// The method constructs a TCP packet header consisting of two predefined
  /// machine data identifiers and the length of the packet data. It then
  /// appends the provided [packet] data to this header.
  ///
  /// The header is an 8-byte structure where:
  /// - The first 2 bytes represent [MACHINE_PREPARE_DATA_1].
  /// - The next 2 bytes represent [MACHINE_PREPARE_DATA_2].
  /// - The last 4 bytes represent the length of the [packet] in little-endian
  ///   format.
  ///
  /// Returns a [Uint8List] containing the header followed by the original
  /// packet data.
  static Uint8List createTcpTop(List<int> packet) {
    int length = packet.length;
    ByteData header = ByteData(8);
    header.setUint16(0, MACHINE_PREPARE_DATA_1, Endian.little);
    header.setUint16(2, MACHINE_PREPARE_DATA_2, Endian.little);
    header.setUint32(4, length, Endian.little);

    final result = BytesBuilder();
    result.add(header.buffer.asUint8List());
    result.add(packet);

    return result.toBytes();
  }

  /// Tests the TCP packet header and extracts the data size.
  ///
  /// The method takes a [List<int>] representing a packet and checks if the
  /// packet's length is greater than 8. If not, it returns 0. It then reads
  /// the first 8 bytes of the packet as a [ByteData] view to extract two
  /// headers and a size. If the headers match [MACHINE_PREPARE_DATA_1] and
  /// [MACHINE_PREPARE_DATA_2], it returns the size. Otherwise, it returns 0.

  static int testTcpTop(List<int> packet) {
    if (packet.length <= 8) {
      return 0;
    }

    ByteData data = ByteData.sublistView(Uint8List.fromList(packet), 0, 8);
    int header1 = data.getUint16(0, Endian.little);
    int header2 = data.getUint16(2, Endian.little);
    int size = data.getUint32(4, Endian.little);

    if (header1 == MACHINE_PREPARE_DATA_1 &&
        header2 == MACHINE_PREPARE_DATA_2) {
      return size;
    }

    return 0;
  }

  /// Tests if a device is reachable by pinging it.
  ///
  /// The method takes an IP address as input and returns a [Future] that
  /// completes with [true] if the device was reachable and [false] otherwise.
  ///
  /// The method uses the dart_ping library to send a single ICMP echo request
  /// to the device. The device is considered reachable if a successful response
  /// is received. If the ping fails or times out, the device is considered
  /// unreachable.
  ///
  /// This method is platform-independent and doesn't rely on system ping commands.
  static Future<bool> testPing(String ip) async {
    try {
      final ping = Ping(ip, count: 1, timeout: 5);

      await for (final PingData data in ping.stream) {
        if (data.response != null) {
          // We received a successful response
          ping.stop();
          return true;
        }
      }

      // If we exit the stream without a response, the ping failed
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Tests if a TCP connection can be established to [ip] on port [port].
  ///
  /// The method attempts to create a TCP socket connection to the device at
  /// [ip] on port [port]. If the connection is established within 10
  /// seconds, the method returns [true]. If the connection attempt fails or
  /// takes longer than 10 seconds, the method returns [false].
  static Future<bool> testTcp(String ip, int port) async {
    Socket? client;
    try {
      client =
          await Socket.connect(ip, port, timeout: const Duration(seconds: 10));
      client.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }
}
