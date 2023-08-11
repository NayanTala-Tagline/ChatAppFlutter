import 'package:chat_app/core/authentication/sign_in.dart';
import 'package:chat_app/middleware/SocialMediaLoginProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/chat/chat_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLogin = false;
  isLogin = prefs.getBool('login') ?? isLogin;

  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => SocialMediaLogin())],
    child: MyApp(isLogin: isLogin),
  ));
}

class MyApp extends StatefulWidget {
  MyApp({Key? key, required this.isLogin}) : super(key: key);
  final bool isLogin;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: widget.isLogin ? ChatScreen() : SignIn(),
    );
  }
}
