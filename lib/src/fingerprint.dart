import 'dart:typed_data';

import 'package:flutter_zkteco/flutter_zkteco.dart';
import 'package:flutter_zkteco/src/util.dart';

class Fingerprint {
  static dynamic get(ZKTeco self, uid) async {
    List data = [];
    //fingers of the hands
    for (int i = 0; i <= 9; i++) {
      Fingerprint fingerprint = Fingerprint();
      Map<String, dynamic> tmp = await fingerprint.getFinger(self, uid, i);
      if (tmp['size'] > 0) {
        data[i] = tmp['tpl'];
      }
    }

    return data;
  }

  Future<Map<String, dynamic>> getFinger(
      ZKTeco self, int uid, int finger) async {
    int command = Util.CMD_USER_TEMP_RRQ;
    String byte1 = String.fromCharCode(uid % 256);
    String byte2 = String.fromCharCode(uid >> 8);
    String commandString = byte1 + byte2 + String.fromCharCode(finger);

    Map<String, dynamic> result = {
      'size': 0,
      'tpl': '',
    };

    var session = await self.command(command, commandString,
        type: Util.COMMAND_TYPE_DATA);

    if (session == false) {
      return result;
    }

    Uint8List? data = await Util.recData(self, first: false);

    if (data?.isNotEmpty == true) {
      int templateSize = data!.length;
      String prefix = String.fromCharCode(templateSize % 256) +
          String.fromCharCode((templateSize / 256).roundToDouble().toInt()) +
          commandString +
          String.fromCharCode(0x01);
      // data = prefix + data;
      if (data.isNotEmpty) {
        result['size'] = templateSize;
        result['tpl'] = data;
      }
    }
    return result;
  }
}
