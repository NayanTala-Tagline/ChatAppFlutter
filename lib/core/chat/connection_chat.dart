import 'package:chat_app/config/app_config.dart';
import 'package:chat_app/core/chat/user_chat.dart';
import 'package:chat_app/middleware/InternetConnectionChecker.dart';
import 'package:chat_app/middleware/auth/get_all_connections.dart';
import 'package:chat_app/model/auth_model.dart';
import 'package:chat_app/ui/overlay/toast.dart';
import 'package:chat_app/ui/widget/string_value.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Connection extends StatefulWidget {
  Connection({
    Key? key,
    this.userId,
  }) : super(key: key);
  final String? userId;
  @override
  _ConnectionState createState() => _ConnectionState();
}

class _ConnectionState extends State<Connection> {
  List<Data> listData = [];
  int initialPage = 1;
  bool isLoading = true;
  ScrollController _scrollController = ScrollController();
  bool paginationIndicator = false;
  late SharedPreferences prefs;

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
      decoration: BoxDecoration(
        color: Color(0xfffd4d4d4),
      ),
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : listData.isEmpty
              ? RefreshIndicator(
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      alignment: Alignment.center,
                      child: Text(StringValue.emptyConnectionListError),
                    ),
                  ),
                  onRefresh: onRefresh)
              : RefreshIndicator(
                  onRefresh: onRefresh,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    child: Column(
                      children: [
                        ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: listData.length,
                          itemBuilder: (_, index) {
                            return listData.isEmpty
                                ? Center(
                                    child: Text(
                                        StringValue.emptyConnectionListError))
                                : GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UserChat(
                                            userName: listData[index].username!,
                                            userId: userId.toString(),
                                            receiverId: listData[index].id!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      child: ListTile(
                                        title: Text(listData[index]
                                            .username
                                            .toString()),
                                        subtitle: Text(
                                            listData[index].email.toString()),
                                      ),
                                    ),
                                  );
                          },
                        ),
                        Visibility(
                            visible: paginationIndicator,
                            child: Container(
                                margin: EdgeInsets.all(10),
                                child:
                                    Center(child: CircularProgressIndicator())))
                      ],
                    ),
                  ),
                ),
    );
  }

  void getAllUserDetails(int page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString(StringValue.userid);
    bool isNetwork = await Network.isInternetAvailable();
    if (isNetwork) {
      if (page == 1) {
        isLoading = true;
        setState(() {});
      }

      await GetAllConnections.getAllConnections(ConnectionBody(
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

  Future<void> onRefresh() async {
    setState(() {
      listData.clear();
      initialPage = 1;
      isLoading = true;
    });
    getAllUserDetails(initialPage);
  }
}
