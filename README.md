# Flutter ZKTeco

A Flutter plugin to interface with fingerprint machines and retrieve attendance data, user information, and other related records. This plugin provides easy-to-use methods to communicate with fingerprint machines, extract data, and process it within your Flutter application.

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
  flutter_zkteco: ^1.0.0
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

### Usage

#### Import the package:

```dart
import 'package:flutter_zkteco/flutter_zkteco.dart';
```

#### Initialize the plugin:

```dart
// Create an instance of the ZKTeco class
ZKTeco fingerprintMachine = ZKTeco('192.168.1.201', port: 4370);

// Initialize the connection
bool isConnected = await fingerprintMachine.connect();
if (isConnected) {
  print('Connection established!');
} else {
  print('Connection failed!');
}
```

#### Retrieve attendance logs:

```dart
// Fetch attendance logs from the machine
List<AttendanceLog> logs = await fingerprintMachine.getAttendanceLogs();
for (var log in logs) {
  print('User ID: ${log.id}, Timestamp: ${log.timestamp}');
}
```

#### Get user data:

```dart
// Retrieve user information from the fingerprint machine
List<UserInfo> users = await fingerprintMachine.getUsers();
for (var user in users) {
  print('User ID: ${user.userId}, Name: ${user.name}');
}
```

#### Disconnect from the machine:

```dart
await fingerprintMachine.disconnect();
print('Disconnected from the fingerprint machine.');
```

### Example

Here’s a complete example demonstrating how to connect, retrieve data, and disconnect from the fingerprint machine:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_zkteco/flutter_zkteco.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fingerprint Machine Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FingerprintMachine fingerprintMachine;
  List<AttendanceLog> logs = [];

  @override
  void initState() {
    super.initState();
    fingerprintMachine = FingerprintMachine(ipAddress: '192.168.1.201', port: 4370);
  }

  Future<void> connectAndFetchLogs() async {
    bool isConnected = await fingerprintMachine.connect();
    if (isConnected) {
      List<AttendanceLog> fetchedLogs = await fingerprintMachine.getAttendanceLogs();
      setState(() {
        logs = fetchedLogs;
      });
      await fingerprintMachine.disconnect();
    } else {
      print('Failed to connect.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fingerprint Logs'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: connectAndFetchLogs,
              child: Text('Fetch Logs'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('User ID: ${logs[index].userId}'),
                    subtitle: Text('Timestamp: ${logs[index].timestamp}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## API

### `FingerprintMachine`

- `FingerprintMachine({required String ipAddress, required int port})`
  - Creates an instance of the fingerprint machine with the specified IP address and port.

- `Future<bool> connect()`
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

## Troubleshooting

- **Connection Issues**: Ensure that the IP address and port are correct, and that the machine is powered on and connected to the network.
- **Compatibility**: The plugin is designed for ZKTeco and similar fingerprint machines. Ensure your device is supported.