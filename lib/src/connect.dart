import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_zkteco/flutter_zkteco.dart';
import 'package:flutter_zkteco/src/util.dart';

class Connect {
  /// Connect to the ZKTeco device.
  ///
  /// This function sends a connect command to the device, which responds with
  /// a session ID and a checksum. The session ID is stored in the [ZKTeco]
  /// object, and the checksum is used to verify that the device responded with
  /// valid data. If the device does not respond or the checksum is invalid, this
  /// function returns [false]. Otherwise, it returns [true].
  ///
  /// This function must be called before any other functions in this class can
  /// be used.
  static Future<bool> connect(ZKTeco self) async {
    int command = Util.CMD_CONNECT;
    String commandString = '';
    int chksum = 0;
    int sessionId = 0;
    int replyId = -1 + Util.USHRT_MAX;

    List<int> buf =
        Util.createHeader(command, chksum, sessionId, replyId, commandString);
    try {
      // Send data to the socket
      self.zkClient.send(
        buf,
        InternetAddress(self.ip, type: InternetAddressType.IPv4),
        self.port,
      );

      await for (Datagram? dataRecv in self.streamController.stream) {
        // Access the byte payload from the Datagram object
        self.dataRecv = dataRecv!.data; // Assuming 'data' holds the byte list

        // Unpack data
        List<int> unpacked = self.dataRecv.sublist(0, 8);

        // Extract sessionId from the unpacked data (bytes 5 and 6)
        String h5 = unpacked[4].toRadixString(16).padLeft(2, '0');
        String h6 = unpacked[5].toRadixString(16).padLeft(2, '0');
        int session = int.parse(h6 + h5, radix: 16);

        if (session == 0) {
          return false;
        } else {
          self.sessionId = session;
          return Util.checkValid(self.dataRecv);
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }

  /// Disconnect from ZKTeco device
  ///
  /// This function disconnects from the ZKTeco device using the CMD_EXIT command.
  ///
  /// The function takes a [ZKTeco] object as an argument, which should have all
  /// the necessary properties set for connecting to the device (e.g. IP address,
  /// port number, and session ID). The session ID is used to create the header
  /// for the disconnect command.
  ///
  /// If the data received from the device has insufficient data, this function
  /// returns false. Otherwise, it sends the disconnect command to the device and
  /// returns true if the device responds with a valid acknowledgement, and false
  /// if the device does not respond or the acknowledgement is invalid.
  static Future<bool> disconnect(ZKTeco self) async {
    int command = Util.CMD_EXIT;
    String commandString = '';
    int chksum = 0;
    int sessionId = self.sessionId;

    // Ensure dataRecv has enough data before slicing
    if (self.dataRecv.length < 8) {
      debugPrint('Error: dataRecv has insufficient data.');
      return false;
    }

    // Unpack the first 8 bytes
    List<int> unpacked = self.dataRecv.sublist(0, 8);

    // Parse the replyId from the last byte (7th index in zero-based)
    int replyId = unpacked[7];

    List<int> buf =
        Util.createHeader(command, chksum, sessionId, replyId, commandString);

    try {
      // Send data to the socket
      self.zkClient.send(
        buf,
        InternetAddress(self.ip),
        self.port,
      );

      await for (Datagram? dataRecv in self.streamController.stream) {
        if (dataRecv == null) {
          return false;
        } else {
          self.dataRecv = dataRecv.data;
          self.sessionId = 0;
          return Util.checkValid(self.dataRecv);
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }
}
