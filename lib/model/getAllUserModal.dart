// Added After Response Gets Change From Api of Get All User
class ConnectionIdArr {
  String? connectionId;
  String? userId;
  String? isConnection;

  ConnectionIdArr({this.connectionId, this.userId, this.isConnection});

  ConnectionIdArr.fromJson(Map<String, dynamic> json) {
    connectionId = json['connectionId'];
    userId = json['userId'];
    isConnection = json['isConnection'];
  }
}
