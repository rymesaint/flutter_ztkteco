library flutter_zkteco;

import 'dart:async';
import 'dart:io' hide Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_zkteco/src/attendance.dart';
import 'package:flutter_zkteco/src/connect.dart';
import 'package:flutter_zkteco/src/device.dart';
import 'package:flutter_zkteco/src/fingerprint.dart';
import 'package:flutter_zkteco/src/model/attendance_log.dart';
import 'package:flutter_zkteco/src/model/user_info.dart';
import 'package:flutter_zkteco/src/os.dart';
import 'package:flutter_zkteco/src/platform.dart';
import 'package:flutter_zkteco/src/serial_number.dart';
import 'package:flutter_zkteco/src/ssr.dart';
import 'package:flutter_zkteco/src/time.dart';
import 'package:flutter_zkteco/src/user.dart';
import 'package:flutter_zkteco/src/util.dart';
import 'package:flutter_zkteco/src/version.dart';

class ZKTeco {
  String ip;
  int port;
  late RawDatagramSocket zkClient;
  late StreamController<Datagram> streamController;

  List<int> dataRecv = [];
  int sessionId = 0;

  // Constructor for ZKTeco
  ZKTeco(this.ip, {this.port = 4370});

  /// Initializes the socket connection to the device.
  ///
  /// This method binds to any available IPv4 address on port 0, and then
  /// listens for incoming datagrams on that socket. When a datagram is received,
  /// it is added to the stream controller, which can be listened to in order to
  /// receive the datagrams. The method also sets a 60 second timeout on the
  /// socket, and prints a message to the console when the timeout is hit.
  Future<void> initSocket() async {
    zkClient = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    zkClient.timeout(const Duration(seconds: 10), onTimeout: (event) {
      debugPrint('Socket timeout');
    });
    streamController = StreamController<Datagram>.broadcast();
    zkClient.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        Datagram? datagram = zkClient.receive();
        if (datagram != null) {
          streamController.add(datagram);
        }
      }
    });
  }

  /// Sends a command to the device and waits for a response.
  ///
  /// The [command] parameter is the command to send to the device.
  ///
  /// The [commandString] parameter is the string to include with the command.
  ///
  /// The [type] parameter is the type of command to send. The default is
  /// [Util.COMMAND_TYPE_GENERAL].
  ///
  /// The method returns a [Future] that completes with the response from the
  /// device, or [false] if an error occurred.
  Future<dynamic> command(int command, String commandString,
      {String type = Util.COMMAND_TYPE_GENERAL}) async {
    int chksum = 0;
    int sessionId = this.sessionId;

    // Ensure dataRecv has enough data before processing
    if (dataRecv.length < 8) {
      throw Exception('dataRecv does not contain enough data.');
    }

    // Unpack the first 8 bytes
    int replyId = getReplyId();

    List<int> buf =
        Util.createHeader(command, chksum, sessionId, replyId, commandString);

    try {
      zkClient.send(buf, InternetAddress(ip), port);

      await for (Datagram dataRecv in streamController.stream) {
        Datagram datagram = dataRecv;
        this.dataRecv = datagram.data;

        // Unpack the received data
        ByteData recvData = ByteData.sublistView(
            Uint8List.fromList(this.dataRecv.sublist(0, 8)));
        int session = recvData.getUint16(4, Endian.little);

        dynamic ret = false;

        if (type == Util.COMMAND_TYPE_GENERAL && sessionId == session) {
          ret = this.dataRecv.sublist(8);
        } else if (type == Util.COMMAND_TYPE_DATA && session != 0) {
          ret = session;
        }
        return ret;
      }

      return false;
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }

  /// Unpacks the reply ID from the first 8 bytes of the data received.
  ///
  /// The reply ID is a 16-bit unsigned integer, stored in two bytes.
  /// The first byte is at position 7 (index 6) and the second byte is at
  /// position 8 (index 7). The two bytes are concatenated and converted
  /// to decimal to form the reply ID.
  int getReplyId() {
    ByteData byteData = ByteData.sublistView(Uint8List.fromList(dataRecv));

    int h7 = byteData.getUint8(6); // Byte at position 7 (index 6)
    int h8 = byteData.getUint8(7); // Byte at position 8 (index 7)

    // Convert them to hexadecimal and concatenate
    String hexH7 = h7.toRadixString(16).padLeft(2, '0');
    String hexH8 = h8.toRadixString(16).padLeft(2, '0');

    String replyIdHex = hexH8 + hexH7;

    // Convert concatenated hex to decimal
    return int.parse(replyIdHex, radix: 16);
  }

  Future<bool> connect() => Connect.connect(this);

  Future<bool> disconnect() => Connect.disconnect(this);

  Future<dynamic> version() => Version.get(this);

  Future<dynamic> serialNumber() => SerialNumber.get(this);

  Future<dynamic> platform() => Platform.get(this);

  Future<dynamic> platformVersion() => Platform.version(this);

  Future<dynamic> getDeviceName() => Device.name(this);

  Future<dynamic> enableDevice() => Device.enable(this);

  Future<dynamic> disableDevice() => Device.disable(this);

  Future<dynamic> powerOff() => Device.powerOff(this);

  Future<dynamic> restart() => Device.restart(this);

  Future<dynamic> sleep() => Device.sleep(this);

  Future<dynamic> resume() => Device.resume(this);

  Future<dynamic> testVoice() => Device.testVoice(this);

  Future<dynamic> clearDisplay() => Device.clearLCD(this);

  Future<dynamic> writeDisplay(int rank, String text) =>
      Device.writeLCD(this, rank, text);

  Future<dynamic> getOS() => Os.get(this);

  Future<dynamic> getTime() => Time.get(this);

  Future<dynamic> setTime(DateTime time) => Time.set(this, time);

  Future<dynamic> getSsr() => Ssr.get(this);

  Future<dynamic> getFingerprint(int uid) => Fingerprint.get(this, uid);

  Future<List<UserInfo>> getUsers() => User.get(this);

  /// Sets a user in the device.
  ///
  /// The method sends a command to the device to set a user. The device must
  /// be connected and authenticated before this method can be used.
  ///
  /// The method returns a [Future] that completes with a [bool] indicating if
  /// the user was successfully set, or a [String] containing an error message
  /// if the device could not be queried.
  ///
  /// The [name] parameter is the name of the user to set. The string should not
  /// be longer than 24 characters.
  ///
  /// The [uid] parameter is the user ID of the user to set. The user ID must
  /// be between 1 and [Util.USHRT_MAX], inclusive.
  ///
  /// The [userid] parameter is the user ID of the user to set as a string.
  /// The string should not be longer than 9 characters.
  ///
  /// The [password] parameter is the password of the user to set. The string
  /// should not be longer than 8 characters.
  ///
  /// The [cardNo] parameter is the card number of the user to set. The card
  /// number must be between 0 and 10, inclusive. If the card number is not
  /// specified, it defaults to 0.
  ///
  /// The [role] parameter is the role of the user to set. The role must be one
  /// of the following values:
  ///
  /// * [Util.LEVEL_USER]
  /// * [Util.LEVEL_ADMIN]
  ///
  /// If the role is not specified, it defaults to [Util.LEVEL_USER].
  Future<dynamic> setUser({
    required String name,
    required int uid,
    required String userId,
    required String password,
    int cardNo = 0,
    int role = Util.LEVEL_USER,
  }) =>
      User.setUser(this,
          name: name,
          uid: uid,
          userid: userId,
          password: password,
          cardNo: cardNo,
          role: role);

  Future<dynamic> clearUsers() => User.clear(this);

  Future<dynamic> removeUser(int uid) => User.remove(this, uid);

  Future<dynamic> clearAdmins() => User.clearAdmin(this);

  Future<List<AttendanceLog>> getAttendanceLogs() => Attendance.get(this);

  Future<dynamic> clearAttendance() => Attendance.clear(this);
}
