import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_zkteco/flutter_zkteco.dart';
import 'package:flutter_zkteco/src/model/attendance_log.dart';
import 'package:flutter_zkteco/src/model/user_info.dart';

void main() async {
  test('connect & disconnect from machine', () async {
    final fingerMachine = ZKTeco("10.7.0.53");
    await fingerMachine.initSocket();
    bool? isConnected = await fingerMachine.connect();

    expect(isConnected, true);

    bool? isDisconnected = await fingerMachine.disconnect();

    expect(isDisconnected, true);
  });

  test('get version success', () async {
    final fingerMachine = ZKTeco("10.7.0.53");
    await fingerMachine.initSocket();
    await fingerMachine.connect();
    dynamic version = await fingerMachine.version();
    expect(version is String, true);
    await fingerMachine.disconnect();
  });

  test('get version failed', () async {
    final fingerMachine = ZKTeco("10.7.0.53");
    await fingerMachine.initSocket();
    await fingerMachine.connect();
    dynamic version = await fingerMachine.version();
    expect(version is String, false);
    await fingerMachine.disconnect();
  });

  test('get serial number', () async {
    final fingerMachine = ZKTeco("10.7.0.53");
    await fingerMachine.initSocket();
    await fingerMachine.connect();
    dynamic serialNumber = await fingerMachine.serialNumber();
    expect(serialNumber is String, true);
    await fingerMachine.disconnect();
  });

  test('get device name', () async {
    final fingerMachine = ZKTeco("10.7.0.53");
    await fingerMachine.initSocket();
    await fingerMachine.connect();
    dynamic deviceName = await fingerMachine.getDeviceName();
    expect(deviceName is String, true);
    await fingerMachine.disconnect();
  });

  test('get platform', () async {
    final fingerMachine = ZKTeco("10.7.0.53");
    await fingerMachine.initSocket();
    await fingerMachine.connect();
    dynamic platform = await fingerMachine.platform();
    expect(platform is String, true);
    await fingerMachine.disconnect();
  });

  test('get platform version', () async {
    final fingerMachine = ZKTeco("10.7.0.53");
    await fingerMachine.initSocket();
    await fingerMachine.connect();
    dynamic platformVersion = await fingerMachine.platformVersion();
    expect(platformVersion is String, true);
    await fingerMachine.disconnect();
  });

  test('get os', () async {
    final fingerMachine = ZKTeco("10.7.0.53");
    await fingerMachine.initSocket();
    await fingerMachine.connect();
    dynamic os = await fingerMachine.getOS();
    expect(os is String, true);
    await fingerMachine.disconnect();
  });

  test('get datetime', () async {
    final fingerMachine = ZKTeco("10.7.0.53");
    await fingerMachine.initSocket();
    await fingerMachine.connect();
    dynamic time = await fingerMachine.getTime();
    expect(time is String, true);
    await fingerMachine.disconnect();
  });

  test('set datetime', () async {
    final fingerMachine = ZKTeco("10.7.0.53");
    await fingerMachine.initSocket();
    await fingerMachine.connect();
    dynamic time = await fingerMachine.setTime(DateTime.now());
    expect(time is String, true);
    await fingerMachine.disconnect();
  });

  test('get SSR', () async {
    final fingerMachine = ZKTeco("10.7.0.53");
    await fingerMachine.initSocket();
    await fingerMachine.connect();
    dynamic ssr = await fingerMachine.getSsr();
    expect(ssr is String, true);
    await fingerMachine.disconnect();
  });

  test('get Users', () async {
    final fingerMachine = ZKTeco("10.7.0.53");
    await fingerMachine.initSocket();
    await fingerMachine.connect();
    List<UserInfo> users = await fingerMachine.getUsers();
    // ignore: unnecessary_type_check
    expect(users is List<UserInfo>, true);
    await fingerMachine.disconnect();
  });

  test('get Attendances', () async {
    final fingerMachine = ZKTeco("10.7.0.53");
    await fingerMachine.initSocket();
    await fingerMachine.connect();
    List<AttendanceLog> logs = await fingerMachine.getAttendanceLogs();
    // ignore: unnecessary_type_check
    expect(logs is List<AttendanceLog>, true);
    await fingerMachine.disconnect();
  });

  test('test voice', () async {
    final fingerMachine = ZKTeco("10.7.0.53");
    await fingerMachine.initSocket();
    await fingerMachine.connect();
    dynamic platform = await fingerMachine.testVoice();
    expect(platform is String, true);
    await fingerMachine.disconnect();
  });
}
