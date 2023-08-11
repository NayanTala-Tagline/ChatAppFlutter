import 'package:chat_app/core/authentication/sign_in.dart';
import 'package:chat_app/core/chat/connection_chat.dart';
import 'package:chat_app/core/chat/pending_connection.dart';
import 'package:chat_app/middleware/InternetConnectionChecker.dart';
import 'package:chat_app/middleware/SocialMediaLoginProvider.dart';
import 'package:chat_app/middleware/auth/get_user.dart';
import 'package:chat_app/model/auth_model.dart';
import 'package:chat_app/ui/overlay/toast.dart';
import 'package:chat_app/ui/widget/string_value.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'connection_all_chat.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, this.userId}) : super(key: key);
  final String? userId;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? _tabController;
  static const Color backgroundColor = Color(0xfff18d2ec);
  String? userId;

  @override
  void initState() {
    super.initState();
    getToken();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          elevation: 10,
          child: FutureBuilder<Data>(
            future: getUserDetails(),
            builder: (ctx, snapshot) {
              if (snapshot.hasData) {
                return ListView(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: DrawerHeader(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                            margin: EdgeInsets.all(5),
                            child: CircleAvatar(
                                radius: 35,
                                child: Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.all(5),
                                    child: Text(
                                      "${snapshot.data!.email![0].toUpperCase()}",
                                      style: TextStyle(fontSize: 30),
                                    ))),
                          ),
                          Container(
                              margin: EdgeInsets.all(5),
                              child: Text(
                                snapshot.data!.username!.toUpperCase(),
                                style: TextStyle(fontSize: 16),
                              )),
                          Container(
                              margin: EdgeInsets.all(5),
                              child: Text(
                                snapshot.data!.email!,
                                style: TextStyle(fontSize: 14),
                              ))
                        ]),
                      ),
                    ),
                    Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                          top: 20,
                          bottom: 20,
                        ),
                        child: Text(
                          getDate(snapshot.data!.dob!)
                          /*formatter.format(DateTime.parse(snapshot.data!.dob!))*/,
                          style: TextStyle(fontSize: 16),
                        )),
                    Container(
                      alignment: Alignment.center,
                      child: snapshot.data!.gender == 'null'
                          ? Text(
                              "Gender Not Available",
                              style: TextStyle(fontSize: 16),
                            )
                          : Text(
                              snapshot.data!.gender!.toUpperCase(),
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                );
              } else {
                Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Container();
            },
          ),
        ),
        backgroundColor: backgroundColor,
        floatingActionButton: FloatingActionButton(
          backgroundColor: backgroundColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ConnectionAlluser()),
            );
          },
          child: Icon(Icons.add),
        ),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: backgroundColor,
          elevation: 0,
          title: Text(
            StringValue.message,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: Container(
              decoration: BoxDecoration(
                  color: Color(0xfff5d3eb9),
                  border: Border.all(color: Colors.black)),
              child: TabBar(
                controller: _tabController,
                labelStyle: TextStyle(fontSize: 12),
                indicator: BoxDecoration(color: Color(0xfffa283fa)),
                tabs: [
                  Tab(text: StringValue.connected),
                  Tab(text: StringValue.pending_connection),
                ],
              ),
            ),
          ),
          actionsIconTheme:
              IconThemeData(size: 30.0, color: Colors.white, opacity: 10.0),
          actions: <Widget>[
            GestureDetector(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('login', false);
                prefs.clear();
                logOut();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SignIn()),
                  (route) => false,
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Icon(Icons.logout, size: 25),
              ),
            ),
          ],
          leading: GestureDetector(
            child: Icon(
              Icons.person,
              size: 25,
            ),
            onTap: () {
              _scaffoldKey.currentState!.openDrawer();
            },
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [Connection(), PendingConnection()],
        ),
      ),
    );
  }

  void logOut() {
    SocialMediaLogin _mediaLogin =
        Provider.of<SocialMediaLogin>(context, listen: false);
    _mediaLogin.signOutFromSocialMedia();
  }

  void getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString(StringValue.userid);
    setState(() {});
  }

  Future<Data> getUserDetails() async {
    Data? data;
    if (mounted) {
      bool isNetwork = await Network.isInternetAvailable();

      if (isNetwork) {
        await GetUserApi.getUser(userID: userId!).then((value) {
          data = value.data!;
        });
      } else {
        ToastModel.errorToast(msg: StringValue.internetConnectionError);
      }
    }
    return data!;
  }

  String getDate(String date) {
    final DateFormat formatter = DateFormat('dd MMMM,yyyy');
    if (date != "null") {
      String dateData = formatter.format(DateTime.parse(date));
      String finalResult;
      String result = dateData.substring(dateData.indexOf(' '));
      String? suffix = "";
      String y = dateData[0] + dateData[1];
      int x = int.parse(y);
      if (x > 10 && x < 21) {
        suffix = 'th';
      } else {
        if (x % 10 == 1) {
          suffix = 'st';
        } else if (x % 10 == 2) {
          suffix = 'nd';
        } else if (x % 10 == 3) {
          suffix = 'rd';
        } else {
          suffix = 'th';
        }
      }
      finalResult = "${x.toString() + suffix + result}";
      return finalResult;
    }
    return "Birth Date Not Available";
  }
}
