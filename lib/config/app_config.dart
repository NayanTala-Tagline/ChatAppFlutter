class AppConfig {
  static const String baseUrl = "https://chat-app-backend-heroku.herokuapp.com";

  // AUTH
  static const String authUrl = baseUrl + "/auth/";
  static const String signUpUrl = authUrl + "signup";
  static const String signInUrl = authUrl + "login";
  static const String otpVerificationUrl = authUrl + "verification";
  static const String getUserUrl = authUrl + "getUser";
  static const String getAllConnectionsUrl = authUrl + "getConnections";
  static const String getAllPendingConnectionsUrl =
      authUrl + "getPendingConnections";
  static const String getSentConnectionRequestUrl =
      authUrl + "sendConnectionRequest";
  static const String getAllUserUrl = authUrl + "getUsers";

  //pagination
  static const int perPage = 20;
}
