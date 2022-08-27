import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:mm_app/colors.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  static final clientID = 0;
  BluetoothConnection connection;

  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  double fatPercentage = 3.5;
  bool organolepticTest = false;

  bool isFilling = false;

  int halfBottleDuration = 10;
  int fullBottleDuration = 20;

  bool isPlacing = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: isConnected
            ? SingleChildScrollView(
                child: SafeArea(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(5),
                          width: double.infinity,
                          child: Padding(
                              padding: const EdgeInsets.only(
                                right: 15,
                                left: 15,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 10, bottom: 10),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          icon: Icon(Icons.arrow_back),
                                          iconSize: 35,
                                        ),
                                        Text(
                                          'VIER DASHBOARD',
                                          style: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Card(
                                            color: milkBlueColor,
                                            elevation: 10,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                  left: 25,
                                                  right: 25,
                                                  top: 15,
                                                  bottom: 22),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Organoleptic Test",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                  Container(
                                                      padding: EdgeInsets.only(
                                                          top: 5),
                                                      child: Text(
                                                        organolepticTest
                                                            ? "PASSED"
                                                            : "FAILED",
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                organolepticTest
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .red),
                                                      ))
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Card(
                                            color: milkPinkColor,
                                            elevation: 10,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                  left: 25,
                                                  right: 25,
                                                  top: 15,
                                                  bottom: 18),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Fat percentage",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                  Container(
                                                      padding: EdgeInsets.only(
                                                          top: 5),
                                                      child: Text(
                                                        "${fatPercentage}%",
                                                        style: TextStyle(
                                                            fontSize: 25,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300),
                                                      ))
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Card(
                                            color: milkBlueColor,
                                            elevation: 10,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                  left: 25,
                                                  right: 25,
                                                  top: 15,
                                                  bottom: 18),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "SNF percentage",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                  Container(
                                                      padding: EdgeInsets.only(
                                                          top: 5),
                                                      child: Text(
                                                        "${fatPercentage}%",
                                                        style: TextStyle(
                                                            fontSize: 25,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300),
                                                      ))
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top: 50),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.only(
                                                    top: 20,
                                                    bottom: 20,
                                                    right: 30,
                                                    left: 20),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.water_drop),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text("500 ml"),
                                                  ],
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: milkPinkColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            log("clicked on 500");
                                            isFilling ? null : startTimer(true);
                                          },
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        InkWell(
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.only(
                                                    top: 20,
                                                    bottom: 20,
                                                    right: 30,
                                                    left: 20),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.water_drop),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text("1000 ml"),
                                                  ],
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: milkBlueColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            log("clicked on 1000");
                                            isFilling
                                                ? null
                                                : startTimer(false);
                                          },
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        isFilling
                                            ? InkWell(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          top: 20,
                                                          bottom: 20,
                                                          right: 30,
                                                          left: 20),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                              Icons.water_drop),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text("STOP"),
                                                        ],
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                onTap: () {
                                                  log("clicked on STOP");
                                                  isFilling
                                                      ? _sendMessage('S')
                                                      : null;
                                                  isFilling
                                                      ? isFilling = !isFilling
                                                      : null;
                                                },
                                              )
                                            : Container()
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top: 5, right: 20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Transform.scale(
                                            scale: 1.5,
                                            child: Switch(
                                                activeTrackColor:
                                                    Colors.greenAccent,
                                                activeColor: Colors.lightGreen,
                                                value: isPlacing,
                                                onChanged: (value) {
                                                  setState(() {
                                                    isPlacing = value;
                                                    isPlacing
                                                        ? _sendMessage('D')
                                                        : _sendMessage('d');
                                                  });
                                                })),
                                        Text(
                                          "Cork Placing",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ],
                                    ),
                                  ),
                                  isFilling
                                      ? Container(
                                          padding: EdgeInsets.only(top: 15),
                                          child: AnimatedTextKit(
                                              repeatForever: true,
                                              animatedTexts: [
                                                TypewriterAnimatedText(
                                                    "FILLING BOTTLE",
                                                    textStyle: TextStyle(
                                                        fontSize: 30,
                                                        color: Colors.red))
                                              ]),
                                        )
                                      : Container()
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Container(
                padding: EdgeInsets.only(top: 15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back),
                          iconSize: 35,
                        ),
                        Container(
                          child: Text(
                            "PLEASE CONNECT TO THE BT",
                            softWrap: true,
                            maxLines: 2,
                            style: TextStyle(fontSize: 25, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ));
  }

  void _onDataReceived(Uint8List data) {
    print("DATA RECEIVED");
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    print("!!!! ${buffer}");
    print("#####${dataString[0]}");
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    log(text);

    if (text.length > 0) {
      try {
        //connection.output.add(utf8.encode(text + "\r\n"));
        connection.output.add(utf8.encode(text));
        await connection.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }

  void startTimer(bool is500ml) {
    is500ml ? _sendMessage('H') : _sendMessage('F');
    setState(() {
      isFilling = true;
    });
    Timer(Duration(seconds: is500ml ? halfBottleDuration : fullBottleDuration),
        () {
      setState(() {
        print("Filled");
        isFilling = false;
        is500ml ? _sendMessage('h') : _sendMessage('f');
      });
    });
  }
}
