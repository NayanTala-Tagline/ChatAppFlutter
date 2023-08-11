import 'dart:convert';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialMediaLogin extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance; //Firebase Auth Object
  final GoogleSignIn googleSignIn = GoogleSignIn(); //Google Sign in Object
  final FacebookLogin fl = new FacebookLogin(); //Facebook Login Object

  //--------------------Variable For Google
  String? _name;
  String? _email;
  String? _imageUrl;
  String? _googleToken;

  //--------------------Variable for Facebook
  String? _fName;
  String? _facebookId;
  String? _fEmail;
  String? _facebookProfileImageUrl;
  String? _facebookToken;

  // Getter
  String get facebookId => _facebookId!;
  String get googleName => _name!;
  String get facebookName => _fName!;
  String get googleEmail => _email!;
  String get googleImgUrl => _imageUrl!;
  String get facebookEmail => _fEmail!;
  String get facebookImgUrl => _facebookProfileImageUrl!;

  // Token Getter
  String get getFacebookToken => _facebookToken!;
  String get getGoogleToken => _googleToken!;

//--------Function For Sign in With Google
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      final GoogleSignInAuthentication? googleSignInAuthentication =
          await googleSignInAccount?.authentication;
      final OAuthCredential? credential = googleSignInAuthentication != null
          ? GoogleAuthProvider.credential(
              accessToken: googleSignInAuthentication.accessToken,
              idToken: googleSignInAuthentication.idToken,
            )
          : null;
      final UserCredential? authResult = credential != null
          ? await _auth.signInWithCredential(credential)
          : null;
      final User? user = authResult!.user ?? null;
      if (user != null) {
        _googleToken = googleSignInAuthentication!.accessToken;
        _name = user.displayName;
        _email = user.email;
        _imageUrl = user.photoURL;
        final User? currentUser = _auth.currentUser;
        assert(user.uid == currentUser!.uid);
        return '$user';
      }

      return null!;
    } on Error catch (e) {
      developer.log(e.toString());
    }
    notifyListeners();
  } //Google Login

//--------Function For SignOut With Google
  Future<void> signOutGoogle() async {
    await Future.wait([googleSignIn.signOut()]);
    notifyListeners();
  } //Sign Out From Google

//--------Function For Login With Facebook
  Future facebookLogin() async {
    try {
      final facebookLoginResult = await fl.logIn(permissions: [
        FacebookPermission.publicProfile,
        FacebookPermission.email,
      ]);
      switch (facebookLoginResult.status) {
        case FacebookLoginStatus.error:
          developer.log('Some Error Occurred');
          break;
        case FacebookLoginStatus.cancel:
          developer.log('Login Cancelled');
          break;
        case FacebookLoginStatus.success:
          final token = facebookLoginResult.accessToken!.token;
          final graphResponse = await http.get(Uri.parse(
              'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),first_name,last_name,email&access_token=$token'));
          final profile = json.decode(graphResponse.body);
          _fName = profile['name'];
          _fEmail = profile['email'];
          _facebookId = profile['id'];
          _facebookProfileImageUrl = profile['picture']['data']['url'];
          _facebookToken = facebookLoginResult.accessToken!.userId;
          notifyListeners();

          return profile;
      }
    } catch (e) {
      developer.log(e.toString());
    }
  }

//-------Function For Logout With Facebook
  Future<void> signOutFacebook() async {
    await _auth.signOut();
    await fl.logOut();
    notifyListeners();
  }

  // ------ Apple login-------------
  String? _appleIdName;
  String? _appleIdEmail;
  String? _appleIdImage;
  String? _appleToken;
  // Getter
  String? get appleUserName => _appleIdName;
  String? get appleUserEmail => _appleIdEmail;
  String? get appleUserImage => _appleIdImage;
  String? get appleToken => _appleToken;

  Future signInWithApple() async {
    try {
      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      _appleIdName = appleIdCredential.givenName;
      _appleIdEmail = appleIdCredential.email;
      _appleToken = appleIdCredential.userIdentifier;
      notifyListeners();

      return appleIdCredential;
    } catch (e) {
      developer.log(e.toString());
    }
  }

  Future<void> signOutFromSocialMedia() async {
    await FirebaseAuth.instance.signOut();
  }
}
