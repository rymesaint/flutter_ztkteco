import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_zkteco/flutter_zkteco.dart';
import 'package:flutter_zkteco/src/model/attendance_log.dart';
import 'package:flutter_zkteco/src/util.dart';

class Attendance {
  /// Retrieves all attendance records from the device.
  ///
  /// This method sends a command to the device to retrieve all attendance
  /// records. The device must be connected and authenticated before this
  /// method can be used.
  ///
  /// The method returns a [Future] that completes with a [Map] containing all
  /// attendance records, or a [bool] indicating if the device could not be
  /// queried. The map has the user ID as the key, and the value is another
  /// [Map] containing the user ID, name, state, timestamp, and type. If the
  /// user name is empty, the user ID is used instead.
  static Future<List<AttendanceLog>> get(ZKTeco self) async {
    int command = Util.CMD_ATT_LOG_RRQ;
    String commandString = '';

    var session = await self.command(command, commandString,
        type: Util.COMMAND_TYPE_DATA);
    if (session == false) {
      return [];
    }

    Uint8List? attData = await Util.recData(self);

    List<AttendanceLog> attendance = [];

    if (attData != null && attData.isNotEmpty) {
      attData = attData.sublist(10);

      while (attData!.length > 40) {
        String u = Util.byteToHex(Uint8List.fromList(attData.sublist(0, 39)));
        int? u1 = int.tryParse(u.substring(4, 6), radix: 16);
        int? u2 = int.tryParse(u.substring(6, 8), radix: 16);
        int? uid;
        if (u1 != null && u2 != null) {
          uid = u1 + (u2 * 256);
        }

        List<String>? id = utf8
            .decode(Util.hex2bin(u.substring(8, 18)), allowMalformed: true)
            .split('\x00');
        int state = int.parse(u.substring(56, 58), radix: 16);
        String timestamp = Util.decodeTime(
            int.parse(Util.reverseHex(u.substring(58, 66)), radix: 16));
        int type = int.parse(Util.reverseHex(u.substring(66, 68)), radix: 16);

        final Map<String, dynamic> data = {
          'uid': uid,
          'id': id[0],
          'state': state,
          'timestamp': timestamp,
          'type': type,
        };
        attendance.add(AttendanceLog.fromJson(data));

        attData = attData.sublist(40);
      }
    }

    return attendance;
  }

  /// Clears all attendance records from the device.
  ///
  /// This method sends a command to the device to clear all attendance records.
  /// The device must be connected and authenticated before this method can be
  /// used.
  ///
  /// The method returns a [Future] that completes with a [bool] indicating if
  /// the device could clear all attendance records, or a [String] containing an
  /// error message if the device could not be queried.
  static Future<dynamic> clear(ZKTeco self) async {
    int command = Util.CMD_CLEAR_ATT_LOG;
    String commandString = '';

    return await self.command(command, commandString);
  }
}
