import 'package:chat_app/middleware/InternetConnectionChecker.dart';
import 'package:chat_app/middleware/auth/get_all_users.dart';
import 'package:chat_app/model/auth_model.dart';
import 'package:chat_app/model/getAllUserModal.dart';
import 'package:chat_app/ui/overlay/toast.dart';
import 'package:chat_app/ui/widget/alert_dialog.dart';
import 'package:chat_app/ui/widget/string_value.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionAlluser extends StatefulWidget {
  ConnectionAlluser({
    Key? key,
  }) : super(key: key);

  @override
  _ConnectionAlluserState createState() => _ConnectionAlluserState();
}

class _ConnectionAlluserState extends State<ConnectionAlluser> {
  List<UserId> userDataList = [];

  List<ConnectionIdArr> connectionList = [];

  int initialPage = 1;
  ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  bool paginationIndicator = false;
  SharedPreferences? prefs;
  List<int> madeConnection = [];

  String? userId;
  @override
  void initState() {
    super.initState();
    if (mounted) {
      getToken();
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffd4d4d4),
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(0xfff18d2ec),
          title: Text(
            StringValue.users,
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
      body: Container(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : userDataList.isEmpty
                ? RefreshIndicator(
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        alignment: Alignment.center,
                        child: Text(StringValue.emptyUserListMessgae),
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
                            scrollDirection: Axis.vertical,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: userDataList.length,
                            itemBuilder: (_, index) {
                              return ListTile(
                                onTap: () {
                                  if (!madeConnection.contains(index)) {
                                    ShowAlertDialog(
                                      context: context,
                                      body: ShowAlertDialogBody(
                                          connectionId:
                                              userDataList[index].sId!,
                                          status: StringValue.PENDING,
                                          alertMessag:
                                              StringValue.messaageSendRequest,
                                          acceptRejectstatus: StringValue.send,
                                          onRefresh: onRefresh),
                                    );
                                  }
                                },
                                trailing: madeConnection.contains(index)
                                    ? Text("Already Requested")
                                    : Text(""),
                                title: Text(
                                    userDataList[index].username.toString()),
                                subtitle:
                                    Text(userDataList[index].email.toString()),
                              );
                            },
                          ),
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
      ),
    );
  }

  getAllUserDetails(int page) async {
    if (mounted) {
      bool isNetwork = await Network.isInternetAvailable();

      if (isNetwork) {
        if (page == 1) {
          isLoading = true;
          setState(() {});
        }
        await GetAllUsers.getAllUser(page: page).then((value) {
          if (value.data!.userData!.isNotEmpty) {
            connectionList.addAll(value.data!.connectionIdArr!);
            userDataList.addAll(value.data!.userData!);
            for (int i = 0; i < connectionList.length; i++) {
              String? connectionId = connectionList[i].connectionId;
              String? userId = connectionList[i].userId;
              for (int i = 0; i < userDataList.length; i++) {
                if (userDataList[i].sId == connectionId ||
                    userDataList[i].sId == userId) {
                  madeConnection.add(i);
                }
              }
            }
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

  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString(StringValue.userid);
    setState(() {});
  }

  Future<void> onRefresh() async {
    setState(() {
      userDataList.clear();
      initialPage = 1;
      isLoading = true;
    });
    getAllUserDetails(initialPage);
  }
}
