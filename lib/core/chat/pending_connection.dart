import 'package:chat_app/config/app_config.dart';
import 'package:chat_app/middleware/InternetConnectionChecker.dart';
import 'package:chat_app/middleware/auth/get_all_connections.dart';
import 'package:chat_app/middleware/auth/getall_pending_connections.dart';
import 'package:chat_app/model/auth_model.dart';
import 'package:chat_app/ui/overlay/toast.dart';
import 'package:chat_app/ui/widget/alert_dialog.dart';
import 'package:chat_app/ui/widget/string_value.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendingConnection extends StatefulWidget {
  PendingConnection({
    Key? key,
    this.userId,
  }) : super(key: key);
  final String? userId;
  @override
  _PendingConnectionState createState() => _PendingConnectionState();
}

class _PendingConnectionState extends State<PendingConnection> {
  List<Data> listData = [];
  int initialPage = 1;

  bool isLoading = false;
  bool paginationIndicator = false;
  ScrollController _scrollController = ScrollController();

  String? userId;
  @override
  void initState() {
    super.initState();
    if (mounted) {
      getAllUserDetails(initialPage);
      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          setState(() {
            paginationIndicator = true;
          });
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
          getAllUserDetails(++initialPage);
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Color(0xfffd4d4d4)),
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : listData.isEmpty
              ? RefreshIndicator(
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      alignment: Alignment.center,
                      child: Text(StringValue.emptyPendingRequestListError),
                    ),
                  ),
                  onRefresh: onRefresh)
              : RefreshIndicator(
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    child: Column(
                      children: [
                        ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: listData.length,
                            itemBuilder: (_, index) {
                              return ListTile(
                                  title: userId != listData[index].userId!.sId
                                      ? Text(listData[index]
                                          .userId!
                                          .username
                                          .toString())
                                      : Text(listData[index]
                                          .connectionId!
                                          .username
                                          .toString()),
                                  subtitle:
                                      userId != listData[index].userId!.sId
                                          ? Text(listData[index]
                                              .userId!
                                              .email
                                              .toString())
                                          : Text(listData[index]
                                              .connectionId!
                                              .email
                                              .toString()),
                                  trailing: userId !=
                                          listData[index].userId!.sId
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () {
                                                ShowAlertDialog(
                                                    context: context,
                                                    body: ShowAlertDialogBody(
                                                        connectionId:
                                                            listData[index]
                                                                .userId!
                                                                .sId,
                                                        status: StringValue
                                                            .ACCEPTED,
                                                        alertMessag: StringValue
                                                            .messaageAcceptRequest,
                                                        acceptRejectstatus:
                                                            StringValue.accept,
                                                        onRefresh: onRefresh));
                                              },
                                              child: ClipOval(
                                                  child: Icon(Icons.done,
                                                      size: 30)),
                                            ),
                                            SizedBox(width: 5),
                                            GestureDetector(
                                              onTap: () {
                                                ShowAlertDialog(
                                                    context: context,
                                                    body: ShowAlertDialogBody(
                                                        connectionId:
                                                            listData[index]
                                                                .userId!
                                                                .sId,
                                                        status: StringValue
                                                            .REJECTED,
                                                        alertMessag: StringValue
                                                            .messaageRejectRequest,
                                                        acceptRejectstatus:
                                                            StringValue.reject,
                                                        onRefresh: onRefresh));
                                              },
                                              child: ClipOval(
                                                  child: Icon(
                                                      Icons.clear_rounded,
                                                      size: 30)),
                                            ),
                                          ],
                                        )
                                      : Text(StringValue.requestMessage));
                            }),
                        Visibility(
                          visible: paginationIndicator,
                          child: Container(
                            margin: EdgeInsets.all(10),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        )
                      ],
                    ),
                  ),
                  onRefresh: onRefresh),
    );
  }

  void getAllUserDetails(int page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString(StringValue.userid);
    if (mounted) {
      bool isNetwork = await Network.isInternetAvailable();
      if (isNetwork) {
        if (page == 1) {
          isLoading = true;
          setState(() {});
        }
        await GetAllPendingConnections.getAllPendingConnections(ConnectionBody(
                userId: userId.toString(),
                perPage: AppConfig.perPage,
                page: initialPage))
            .then((value) {
          if (value.listData!.isNotEmpty) {
            listData.addAll(value.listData!);
          }
          if (page == 1) isLoading = false;
          paginationIndicator = false;
          setState(() {});
        });
      } else {
        ToastModel.errorToast(msg: StringValue.internetConnectionError);
      }
    }
  }

  Future<void> onRefresh() async {
    setState(() {
      listData.clear();
      initialPage = 1;
    });
    getAllUserDetails(initialPage);
  }
}
