import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:chat_app/config/app_config.dart';
import 'package:chat_app/model/auth_model.dart';
import 'package:chat_app/ui/overlay/enums.dart';
import 'package:chat_app/ui/overlay/toast.dart';
import 'package:chat_app/ui/widget/string_value.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

enum ConnectionStatus {
  Connected,
  Connecting,
  Disconnected,
  NotYetConnected,
  ConnectionError,
  ConnectionTimeOut
}

enum IsAllMessageReceived { Waiting, NO, YES, None }

class UserChat extends StatefulWidget {
  UserChat(
      {Key? key,
      required this.userName,
      required this.userId,
      required this.receiverId})
      : super(key: key);
  final String userName;
  final String userId;
  final String receiverId;

  @override
  _UserChatState createState() => _UserChatState();
}

class _UserChatState extends State<UserChat> {
  final TextEditingController _controller = TextEditingController();
  IO.Socket? socket;

  static const String SENDMSG = "messages";
  static const String GETALLMESSGES = "getMessages";

  List<Data>? _allMessages = [];
  ConnectionStatus _connectionStatus = ConnectionStatus.NotYetConnected;
  IsAllMessageReceived _isAllMessageReceived = IsAllMessageReceived.None;

  ScrollController _scrollController = ScrollController();
  FocusNode focusNode = FocusNode();

  // Controllers
  StreamController<ConnectionStatus> _connectionStatusController =
      StreamController<ConnectionStatus>.broadcast();

  StreamController<IsAllMessageReceived> _isAllMessageReceivedController =
      StreamController<IsAllMessageReceived>.broadcast();

  StreamController<List<Data>> _messagesController =
      StreamController<List<Data>>.broadcast();

  @override
  void initState() {
    super.initState();
    if (mounted) connectToSocket();
  }

  void connectToSocket() {
    try {
      developer.log(widget.userId, name: "userID");
      developer.log(widget.receiverId,
          name: "connectionID : ${widget.userName}");

      // Connection status
      _connectionStatusController.stream.listen((connection) {
        if (connection == ConnectionStatus.Connected) _getAllMessages();
      });

      // All Message controller
      _messagesController.stream.listen((messages) {
        if (messages.isEmpty) {
          _isAllMessageReceivedController.add(IsAllMessageReceived.NO);
        } else {
          developer.log(messages[0].text.toString(), name: "Last Message");
          _isAllMessageReceivedController.add(IsAllMessageReceived.YES);
          _allMessages!.insertAll(0, messages);
          setState(() {});
        }
      });

      socket = IO.io(
        '${AppConfig.baseUrl}',
        OptionBuilder()
            .setPath('/socket.io')
            .setTransports(['websocket'])
            .setQuery({
              "userId": "${widget.userId}",
              "connectionId": "${widget.receiverId}"
            })
            .disableAutoConnect()
            .enableForceNewConnection()
            .build(),
      );

      developer.log(socket!.opts.toString(), name: "OPTIONS");
      socket!.connect();
      socket!.onConnect(onConnect);

      // Waiting & Error handling
      socket!.onConnecting(onConnecting);
      socket!.onConnectError(onConnectError);
      socket!.onConnectTimeout(onConnectTimeout);

      // Disconnect socket
      socket!.onDisconnect(disconnectEvent);

      // Socket Events
      socket!.on("$SENDMSG", messagesEvent);
      socket!.on("$GETALLMESSGES", getMessagesEvent);
    } catch (e) {
      ToastModel.errorToast(msg: e.toString());
    }
  }

  @override
  void dispose() {
    _connectionStatusController.close();
    _isAllMessageReceivedController.close();
    _messagesController.close();
    socket!.clearListeners();
    socket!.disconnect();
    super.dispose();
  }

  dynamic onConnect(dynamic data) {
    _connectionStatusController.add(ConnectionStatus.Connected);
  }

  dynamic disconnectEvent(dynamic data) {
    socket!.clearListeners();
  }

  dynamic onConnecting(dynamic data) {
    _connectionStatusController.add(ConnectionStatus.Connecting);
    _isAllMessageReceivedController.add(IsAllMessageReceived.Waiting);
  }

  dynamic onConnectError(dynamic data) {
    _connectionStatusController.add(ConnectionStatus.ConnectionError);
    _isAllMessageReceivedController.add(IsAllMessageReceived.NO);
  }

  dynamic onConnectTimeout(dynamic data) {
    _connectionStatusController.add(ConnectionStatus.ConnectionTimeOut);
    _isAllMessageReceivedController.add(IsAllMessageReceived.NO);
  }

  // Socket Event Listener
  dynamic messagesEvent(dynamic data) {
    developer.log(data.toString(), name: "received Messages");

    Map<String, dynamic> json = jsonDecode(jsonEncode(data));
    int statusCode = 1000;
    if (json['statusCode'] != null) {
      statusCode = int.parse(json['statusCode'].toString());
    }

    ApiRepose apiRepose =
        ApiRepose.fromJson(json, statusCode: statusCode, api: AppApi.NONE);

    _messagesController.add([apiRepose.data!]);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    }
  }

  dynamic getMessagesEvent(dynamic data) async {
    Map<String, dynamic> json = jsonDecode(jsonEncode(data));
    int statusCode = 1000;
    if (json['statusCode'] != null) {
      statusCode = int.parse(json['statusCode'].toString());
    }

    ApiRepose apiRepose =
        ApiRepose.fromJson(json, statusCode: statusCode, api: AppApi.CHAT);

    _messagesController.add(apiRepose.listData!);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    }
  }

  void _sendMessage({required String message}) {
    socket!.emit(
      "$SENDMSG",
      {
        "senderId": "${widget.userId}",
        "receiverId": "${widget.receiverId}",
        "text": "$message",
      },
    );
  }

  void _getAllMessages() {
    _isAllMessageReceivedController.add(IsAllMessageReceived.Waiting);
    socket!.emit(
      '$GETALLMESSGES',
      {
        "senderId": "${widget.userId}",
        "receiverId": "${widget.receiverId}",
      },
    );
  }

  String _hoursAndMinute(String string) {
    var dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
    var _date = dateFormat.parse(string);
    String formattedTime = DateFormat.Hm().format(_date);
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff18d2ec),
        elevation: 0,
        title: Text(
          widget.userName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 70.0),
              child: StreamBuilder(
                initialData: _connectionStatus,
                stream: _connectionStatusController.stream,
                builder: (context,
                    AsyncSnapshot<ConnectionStatus?> connectionStatus) {
                  if (connectionStatus.hasData) {
                    if (connectionStatus.data == ConnectionStatus.Connected) {
                      return StreamBuilder(
                        initialData: _isAllMessageReceived,
                        stream: _isAllMessageReceivedController.stream,
                        builder: (context,
                            AsyncSnapshot<IsAllMessageReceived?>
                                isMessagesAvailable) {
                          if (isMessagesAvailable.hasData) {
                            if (isMessagesAvailable.data ==
                                IsAllMessageReceived.None) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (isMessagesAvailable.data ==
                                IsAllMessageReceived.Waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (isMessagesAvailable.data ==
                                IsAllMessageReceived.NO) {
                              return Center(
                                  child: Text("No Message Available yet"));
                            }
                            if (isMessagesAvailable.data ==
                                IsAllMessageReceived.YES) {
                              return ListView.builder(
                                shrinkWrap: true,
                                reverse: true,
                                controller: _scrollController,
                                itemCount: _allMessages!.length,
                                itemBuilder: (context, index) {
                                  if (_allMessages![index].senderId ==
                                      widget.userId) {
                                    return MessageDisplay(
                                      msg: _allMessages![index].text.toString(),
                                      time: _hoursAndMinute(
                                          _allMessages![index].createdAt!),
                                      isClient: true,
                                    );
                                  }

                                  if (_allMessages![index].senderId !=
                                      widget.userId) {
                                    return MessageDisplay(
                                      msg: _allMessages![index].text.toString(),
                                      time: _hoursAndMinute(
                                          _allMessages![index].createdAt!),
                                      isClient: false,
                                    );
                                  }

                                  return Text("Message is removed");
                                },
                              );
                            }
                          }
                          if (isMessagesAvailable.hasError) {
                            return Center(child: Text("Something went wrong"));
                          }
                          return Center(child: CircularProgressIndicator());
                        },
                      );
                    }

                    if (connectionStatus.data ==
                            ConnectionStatus.NotYetConnected ||
                        connectionStatus.data == ConnectionStatus.Connecting) {
                      return Center(child: Text("Connecting..."));
                    }

                    if (connectionStatus.data ==
                        ConnectionStatus.ConnectionError) {
                      return Center(child: Text("Connection error"));
                    }

                    if (connectionStatus.data ==
                        ConnectionStatus.ConnectionTimeOut) {
                      return Center(child: Text("Connection timeout"));
                    }

                    return Center(child: CircularProgressIndicator());
                  }
                  if (connectionStatus.hasError) {
                    return Center(child: Text("Something went wrong.."));
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
            Positioned(
              bottom: 10.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                margin: EdgeInsets.only(bottom: 0.0, left: 5, right: 5),
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color(0xfffDDDDDD)),
                child: TextField(
                  controller: _controller,
                  focusNode: focusNode,
                  maxLines: 5,
                  minLines: 1,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: StringValue.enter_message,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    suffixIcon: IconButton(
                      onPressed: () {
                        try {
                          if (_controller.text.isNotEmpty) {
                            developer.log(socket!.connected.toString(),
                                name: "Socket connected");
                            _sendMessage(message: _controller.text);
                            _controller.clear();
                            setState(() {});
                          }
                        } catch (e) {
                          ToastModel.errorToast(msg: e.toString());
                        }
                      },
                      icon: Icon(Icons.send),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MessageDisplay extends StatelessWidget {
  const MessageDisplay({
    Key? key,
    required this.msg,
    required this.isClient,
    required this.time,
  }) : super(key: key);

  final String msg;
  final bool isClient;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          top: 10.0,
          bottom: 5.0,
          right: isClient ? 20.0 : 0.0,
          left: isClient ? 0.0 : 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            alignment: isClient ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: isClient
                    ? Colors.grey.withOpacity(0.5)
                    : Colors.green.withOpacity(0.5),
              ),
              padding: EdgeInsets.all(15.0),
              child: Text(
                "$msg",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.0),
              ),
            ),
          ),
          // SizedBox(height: 5.0),
          // Container(
          //
          //   width: double.infinity,
          //   alignment: isClient ? Alignment.centerRight : Alignment.centerLeft,
          //   child: Text(
          //     "$time",
          //     style: TextStyle(fontSize: 14.0),
          //   ),
          // ),
        ],
      ),
    );
  }
}
