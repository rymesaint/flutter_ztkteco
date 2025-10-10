import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_zkteco/flutter_zkteco.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ipAdress = TextEditingController();
  final port = TextEditingController(text: '4370');
  ZKTeco? fingerprintMachine;
  String btnMessage = 'Connect';
  bool isConnected = false;
  int currentIndex = 0;
  List<UserInfo> users = [];
  List<AttendanceLog> attendances = [];
  bool loadingContent = false;
  bool isLive = false;
  bool useTcp = true;
  int totalTab = 9;
  String message = '';
  StreamSubscription<AttendanceLog?>? live;

  void _connectFp() async {
    try {
      setState(() {
        btnMessage = 'Connecting...';
      });
      fingerprintMachine = ZKTeco(ipAdress.text,
        port: int.parse(port.text),
        debug: true,
        tcp: useTcp,
        timeout: Duration(seconds: 20),
        // password: 0, // ZKTeco K60 uses password: 0
      );
      final connect = await fingerprintMachine?.connect();
      if (connect == true) {
        setState(() {
          btnMessage = 'Disconnect';
          isConnected = connect ?? false;
        });
      } else {
        setState(() {
          btnMessage = 'Connect';
          isConnected = connect ?? false;
        });
      }
    } catch (e, trace) {
      debugPrint(e.toString());
      setState(() {
        btnMessage = 'Connect';
        isConnected = false;
      });
    }
  }

  void getUserData() async {
    setState(() {
      loadingContent = true;
    });
    var users = await fingerprintMachine?.getUsers() ?? [];

    setState(() {
      this.users = users;
      loadingContent = false;
    });
  }

  void getAttendancesData() async {
    setState(() {
      loadingContent = true;
    });
    var attendances = await fingerprintMachine?.getAttendanceLogs() ?? [];

    setState(() {
      this.attendances = attendances;
      loadingContent = false;
    });
  }

  void getOS() async {
    setState(() {
      loadingContent = true;
    });

    String? os = await fingerprintMachine?.getOS();

    setState(() {
      message = os ?? '';
      loadingContent = false;
    });
  }

  void getPlatform() async {
    setState(() {
      loadingContent = true;
    });

    String? platform = await fingerprintMachine?.platform();
    String? platformVersion = await fingerprintMachine?.platformVersion();

    setState(() {
      message = '${platform ?? ''} (${platformVersion ?? ''})';
      loadingContent = false;
    });
  }

  void getTime() async {
    setState(() {
      loadingContent = true;
    });

    DateTime? time = await fingerprintMachine?.getTime();

    setState(() {
      message = time?.toIso8601String() ?? '';
      loadingContent = false;
    });
  }

  void getSerialNumber() async {
    setState(() {
      loadingContent = true;
    });

    String? serial = await fingerprintMachine?.serialNumber();

    setState(() {
      message = serial ?? '';
      loadingContent = false;
    });
  }

  void getVersion() async {
    setState(() {
      loadingContent = true;
    });

    String? version = await fingerprintMachine?.version();

    setState(() {
      message = version ?? '';
      loadingContent = false;
    });
  }

  void getWorkcode() async {
    setState(() {
      loadingContent = true;
    });

    String? workcode = await fingerprintMachine?.getWorkcode();

    setState(() {
      message = workcode ?? '';
      loadingContent = false;
    });
  }

  void _disconnectFp() async {
    await fingerprintMachine?.disconnect();
    setState(() {
      btnMessage = 'Connect';
      isConnected = false;
    });
  }

  void startLive() {
    setState(() {
      isLive = true;
    });
    live = fingerprintMachine?.onAttendanceRecordReceived
        .listen((AttendanceLog? log) {
      if (log?.id != null) {
        setState(() {
          attendances.add(log!);
        });
      }
    });
  }

  void endLive() async {
    try {
      await fingerprintMachine?.cancelLiveCapture();
      live?.cancel();
      setState(() {
        isLive = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget _buildResponsiveForm() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return Column(
        spacing: 10,
        children: [
          Row(
            spacing: 20,
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: ipAdress,
                  enabled: isConnected ? false : true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'IP Address',
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: port,
                  enabled: isConnected ? false : true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Port',
                  ),
                ),
              ),
              TextButton(
                onPressed: isConnected ? _disconnectFp : _connectFp,
                child: Text(btnMessage),
              ),
            ],
          ),
          CheckboxListTile(
            value: useTcp,
            title: Text('Uncheck to use UDP'),
            onChanged: isConnected
                ? null
                : (value) => setState(
                      () {
                        useTcp = value ?? false;
                      },
                    ),
          ),
        ],
      );
    } else if (Platform.isAndroid || Platform.isIOS) {
      return Column(
        spacing: 10,
        children: [
          TextFormField(
            controller: ipAdress,
            enabled: isConnected ? false : true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'IP Address',
            ),
          ),
          TextFormField(
            controller: port,
            enabled: isConnected ? false : true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Port',
            ),
          ),
          CheckboxListTile(
            value: useTcp,
            title: Text('Uncheck to use UDP'),
            onChanged: isConnected
                ? null
                : (value) => setState(
                      () {
                        useTcp = value ?? false;
                      },
                    ),
          ),
          TextButton(
            onPressed: isConnected ? _disconnectFp : _connectFp,
            child: Text(btnMessage),
          ),
        ],
      );
    }
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: totalTab,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(
                Platform.isAndroid || Platform.isIOS ? 350 : 220),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 20,
                  children: <Widget>[
                    _buildResponsiveForm(),
                    TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      onTap: (value) {
                        if (isConnected == false) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Connect first'),
                            ),
                          );
                          return;
                        }
                        if (value == 0) {
                          getOS();
                        } else if (value == 1) {
                          getPlatform();
                        } else if (value == 2) {
                          getTime();
                        }
                        if (value == 3) {
                          getSerialNumber();
                        } else if (value == 4) {
                          getVersion();
                        }
                        if (value == 5) {
                          getWorkcode();
                        } else if (value == 6) {
                          getUserData();
                        } else if (value == 7) {
                          getAttendancesData();
                        } else if (value == 8) {}
                        currentIndex = value;
                      },
                      tabs: [
                        Tab(
                          text: 'Get OS',
                        ),
                        Tab(
                          text: 'Get Platform',
                        ),
                        Tab(
                          text: 'Get Time',
                        ),
                        Tab(
                          text: 'Get Serial Number',
                        ),
                        Tab(
                          text: 'Get Version',
                        ),
                        Tab(
                          text: 'Get Workcode',
                        ),
                        Tab(
                          text: 'Get Users Data',
                        ),
                        Tab(
                          text: 'Get Attendances Data',
                        ),
                        Tab(
                          text: 'Live Attendances Data',
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            loadingContent
                ? const Center(child: CircularProgressIndicator())
                : Center(child: Text(message)),
            loadingContent
                ? const Center(child: CircularProgressIndicator())
                : Center(child: Text(message)),
            loadingContent
                ? const Center(child: CircularProgressIndicator())
                : Center(child: Text(message)),
            loadingContent
                ? const Center(child: CircularProgressIndicator())
                : Center(child: Text(message)),
            loadingContent
                ? const Center(child: CircularProgressIndicator())
                : Center(child: Text(message)),
            loadingContent
                ? const Center(child: CircularProgressIndicator())
                : Center(child: Text(message)),
            loadingContent
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemBuilder: (_, index) {
                      final user = users[index];
                      return ListTile(
                        title: Text(user.uid?.toString() ?? '-'),
                        subtitle: Text(user.name ?? '-'),
                      );
                    },
                    itemCount: users.length,
                  ),
            loadingContent
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemBuilder: (_, index) {
                      final attendance = attendances[index];
                      return ListTile(
                        title: Text(attendance.id ?? '-'),
                        subtitle: Text(attendance.timestamp?.toString() ?? '-'),
                      );
                    },
                    itemCount: attendances.length,
                  ),
            Visibility(
              visible: isLive,
              replacement: Center(
                child: TextButton.icon(
                  onPressed: startLive,
                  label: Text('Start Live'),
                  icon: Icon(Icons.play_arrow_rounded),
                ),
              ),
              child: Column(
                children: [
                  TextButton.icon(
                    onPressed: endLive,
                    label: Text('End Live'),
                    icon: Icon(Icons.stop_circle_rounded),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (_, index) {
                        final attendance = attendances[index];
                        return ListTile(
                          title: Text(attendance.id ?? '-'),
                          subtitle:
                              Text(attendance.timestamp?.toString() ?? '-'),
                        );
                      },
                      itemCount: attendances.length,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
