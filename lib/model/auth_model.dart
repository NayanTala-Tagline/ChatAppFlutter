import 'package:chat_app/model/getAllUserModal.dart';
import 'package:chat_app/ui/overlay/enums.dart';

class ApiRepose {
  int? statusCode;
  String? message;
  Data? data;
  List<Data>? listData;
  String? error;

  ApiRepose(
      {this.message, this.data, this.statusCode, this.error, this.listData});

  factory ApiRepose.fromJson(
    Map<String, dynamic> json, {
    required int statusCode,
    required AppApi api,
  }) {
    Data? data;
    List<Data> listData = [];

    if ((api == AppApi.GETALLUSERS ||
            api == AppApi.GETALLCONNECTIONS ||
            api == AppApi.GETALLPENDINGCONNECTIONS ||
            api == AppApi.CHAT) &&
        statusCode == 200) {
      if (json['data'] != null) {
        if (api == AppApi.GETALLUSERS) {
          data = Data.fromJson(json['data']);
          return ApiRepose(
            message: json['message'] as String,
            data: data,
            statusCode: statusCode,
          );
        } else {
          List value = json['data'] as List;
          if (value.isNotEmpty) {
            listData = value.map((e) => Data.fromJson(e)).toList();
          } else {
            listData = [];
          }
        }
      } else {
        listData = [];
      }

      return ApiRepose(
        message: json['message'] as String,
        listData: listData,
        statusCode: statusCode,
      );
    }

    if (json['data'] != null) {
      data = Data.fromJson(json['data']);
    } else {
      if (json['data'] != null) {
        data = Data.fromJson(json['data']);
      } else {
        data = Data();
      }
    }

    // Invalid Login response
    if (statusCode == 400) {
      if (json['error'] == null) {
        return ApiRepose(
          message: json['message'] ?? "message",
          data: data,
          statusCode: statusCode,
        );
      } else {
        List message = json['message'] as List;
        return ApiRepose(
          statusCode: statusCode,
          error: json['error'] ?? "error",
          message: message[0],
        );
      }
    }

    // Response Handling for all APIs
    return ApiRepose(
      message: json['message'] as String,
      data: data,
      statusCode: statusCode,
    );
  }
}

class Data {
  String? username;
  String? email;
  String? dob;
  String? gender;
  String? id;
  String? token;
  int? statusCode;
  String? error;
  UserId? userId;
  UserId? connectionId;
  String? isConnection;
  //
  bool? isSeen;
  String? text;
  String? senderId;
  String? receiverId;
  String? createdAt;
  String? updatedAt;
  int? v;
  List<ConnectionIdArr>? connectionIdArr = [];
  List<UserId>? userData = [];

  Data(
      {this.username,
      this.dob,
      this.email,
      this.gender,
      this.id,
      this.token,
      this.statusCode,
      this.error,
      this.userId,
      this.connectionId,
      this.isConnection,
      //
      this.isSeen,
      this.text,
      this.senderId,
      this.receiverId,
      this.createdAt,
      this.updatedAt,
      this.v,
      this.connectionIdArr,
      this.userData});

  factory Data.fromJson(Map<String, dynamic> json) {
    List<UserId> _user = [];
    List<ConnectionIdArr> _connection = [];
    int statusCode = 1000;
    if (json['statusCode'] != null) {
      statusCode = int.parse(json['statusCode'].toString());
    }
    if (json['connectionIdArr'] != null) {
      json['connectionIdArr'].forEach((v) {
        _connection.add(new ConnectionIdArr.fromJson(v));
      });
    }
    if (json['userData'] != null) {
      json['userData'].forEach((v) {
        _user.add(new UserId.fromJson(v));
      });
    }

    return Data(
        username: json['username'] ?? "null",
        email: json['email'] ?? "null",
        dob: json['dob'] ?? "null",
        gender: json['gender'] ?? "null",
        id: json['_id'] ?? "null",
        token: json['token'] ?? "null",
        statusCode: statusCode,
        error: json['error'] ?? "null",
        userId:
            json['userId'] != null ? new UserId.fromJson(json['userId']) : null,
        connectionId: json['connectionId'] != null
            ? new UserId.fromJson(json['connectionId'])
            : null,
        isConnection: json['isConnection'] ?? "null",
        isSeen: json['isSeen'] ?? false,
        text: json['text'] ?? "null",
        senderId: json['senderId'] ?? "null",
        receiverId: json['receiverId'] ?? "null",
        createdAt: json['createdAt'] ?? "null",
        updatedAt: json['updatedAt'] ?? "null",
        v: json['--v'] ?? 000,
        userData: _user,
        connectionIdArr: _connection);
  }
}

class UserId {
  String? username;
  String? dob;
  String? gender;
  String? sId;
  String? email;

  UserId({this.username, this.dob, this.gender, this.sId, this.email});

  factory UserId.fromJson(Map<String, dynamic> json) {
    return UserId(
      username: json['username'] ?? "null",
      dob: json['dob'] ?? "null",
      gender: json['gender'] ?? "null",
      sId: json['_id'] ?? "null",
      email: json['email'] ?? "null",
    );
  }
}
