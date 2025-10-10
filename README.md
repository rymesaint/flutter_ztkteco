# Flutter ZKTeco

[<img src="https://button.ibnux.net/trakteer/rymesaint.png" width="128">](https://trakteer.id/rymesaint/tip)

A Flutter plugin to interface with fingerprint machines and retrieve attendance data, user information, and other related records. This plugin provides easy-to-use methods to communicate with fingerprint machines, extract data, and process it within your Flutter application.

## Screenshots

![Get OS](https://github.com/user-attachments/assets/0830c5b5-a110-453c-a0c8-e6ade05f9e02)
![Get Platform](https://github.com/user-attachments/assets/72ec2ce5-62e3-4d44-a3c7-4cdd2de2e6cc)
![Get Version](https://github.com/user-attachments/assets/5b16e6e9-20d1-4ce4-a2f5-f614d6a38920)
![Get UserData](https://github.com/user-attachments/assets/573ee606-8e82-42de-9990-6da578ea9570)
![Get FingerData](https://github.com/user-attachments/assets/41076497-d6a6-46a1-b72f-78c1e40411bf)

## Features

- Connect to fingerprint machines via TCP/IP
- Retrieve user information (ID, name, etc.)
- Fetch attendance logs (timestamps, user ID, etc.)
- Supports both real-time and batch data retrieval
- Compatible with ZKTeco and similar devices

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_zkteco: ^1.1.0
```

Then run:

```bash
flutter pub get
```

### Platform Support

- Android
- iOS
- Web (TBD)
- Windows
- MacOS

#### MacOS
Add 
```
	<key>com.apple.security.network.client</key>
    <true/>
```
in your
macos/Runner/DebugProfile.entitlements
macos/Runner/Release.entitlements
files

### Usage

#### Import the package:

```dart
import 'package:flutter_zkteco/flutter_zkteco.dart';
```

#### Initialize the plugin:

```dart
// Create an instance of the ZKTeco class
ZKTeco? fingerprintMachine = ZKTeco('192.168.1.201', port: 4370, timeout: Duration(seconds: 10), tcp: true, debug: false, retry: 3);

// Initialize the connection
bool isConnected = await fingerprintMachine?.connect();
if (isConnected) {
  print('Connection established!');
} else {
  print('Connection failed!');
}
```

#### Retrieve attendance logs:

```dart
// Fetch attendance logs from the machine
List<AttendanceLog> logs = await fingerprintMachine?.getAttendanceLogs();
for (var log in logs) {
  print('User ID: ${log.id}, Timestamp: ${log.timestamp}');
}
```

#### Get user data:

```dart
// Retrieve user information from the fingerprint machine
List<UserInfo> users = await fingerprintMachine?.getUsers();
for (var user in users) {
  print('User ID: ${user.userId}, Name: ${user.name}');
}
```

#### Disconnect from the machine:

```dart
await fingerprintMachine?.disconnect();
print('Disconnected from the fingerprint machine.');
```

## API

### `ZKTeco`

- `ZKTeco(String ipAddress,{int port = 4370, Duration? timeout, int retry = 3, bool tcp = true, bool debug = false, int? password})`
  - Creates an instance of the fingerprint machine with the specified IP address and port.

- `Future<bool> connect({bool? ommitPing})`
  - Establishes a connection to the fingerprint machine.

- `Future<List<AttendanceLog>> getAttendanceLogs()`
  - Retrieves attendance logs from the machine.

- `Future<List<UserInfo>> getUsers()`
  - Retrieves user information from the machine.

- `Future<void> disconnect()`
  - Disconnects from the fingerprint machine.

### Data Models

#### `AttendanceLog`

- `int uid`
- `String id`
- `int state`
- `String timestamp`
- `int type`

#### `UserType`
- `admin`
- `user`

#### `UserInfo`
- `String userId`
- `String name`
- `UserType role`
- `String password`
- `int cardNo`

## Device Configuration

- **ZKTeco K60**: Requires Password to be set to: `0`

## Troubleshooting

- **Connection Issues**: Ensure that the IP address and port are correct, and that the machine is powered on and connected to the network.
- **Compatibility**: The plugin is designed for ZKTeco and similar fingerprint machines. Ensure your device is supported.

## Unsupported Devices

- [MB360Plus](https://github.com/rymesaint/flutter_ztkteco/issues/12)