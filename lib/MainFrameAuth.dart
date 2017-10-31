import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:facebook_sign_in/facebook_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:myapp/src/dao/UserDao.dart';

/*
  Author: Art

  This dart contains the Authentication methods that is utilized in this Application
 */

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();
final List<String> read = ["public_profile", "user_friends", "email", "user_birthday"];

/*
  Method to register the current user to the Firebase Authenticated users.
  This method uses email/password to register.
 */
Future<FirebaseUser> registerEmail(String email, String password) {
  return _auth.createUserWithEmailAndPassword(email: email, password: password).then((FirebaseUser data) {
    saveUserFromFirebase(data);
  });
}

/*
  Method to login the current user to the Firebase Authenticated users.
  This method uses email/password to login.
 */
Future<FirebaseUser> loginWithEmail(String email, String password) {
  return _auth.signInWithEmailAndPassword(email: email, password: password);
}

/*
  Method to login the current user to the Firebase Authenticated users.
  This method uses Facebook to login.
 */
Future<String> loginWithFacebook() async {
  String token = "";
  bool isLogged = await FacebookSignIn.isLoggedIn();
  if(!isLogged) {
    token = await FacebookSignIn.loginWithReadPermissions(read);
  }
  else {
    token = await FacebookSignIn.getToken();
  }
  print("token: $token");
  final FirebaseUser user = await _auth.signInWithFacebook(accessToken: token);
  assert(user.email != null);
  assert(user.displayName != null);
  assert(!user.isAnonymous);
  assert(await user.getToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);
  return 'signInWithGoogle succeeded: $user';
}

/*
  Method to register the current user to the Firebase Authenticated users.
  This method uses Facebook to register.
 */
Future<String> signInWithFacebook() async {
  String token = "";
  bool isLogged = await FacebookSignIn.isLoggedIn();
  if(!isLogged) {
    token = await FacebookSignIn.loginWithReadPermissions(read);
  }
  else {
    token = await FacebookSignIn.getToken();
  }
  print("token: $token");
  final FirebaseUser user = await _auth.signInWithFacebook(accessToken: token);
  assert(user.email != null);
  assert(user.displayName != null);
  assert(!user.isAnonymous);
  assert(await user.getToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  print("This user is signed in: $user");
  // make http request to get additional info
  String url = 'https://graph.facebook.com/me?fields=first_name,last_name,gender,birthday,picture&access_token=$token';
  var httpClient = createHttpClient();
  var resp = await httpClient.read(url);
  print('response = $resp');
  //var usr = convertResponseToUser(resp);
  saveUserFromResponse(resp, user);

  return 'signInWithGoogle succeeded: $user';
}

/*
  Method to register the current user to the Firebase Authenticated users.
  This method uses Google to register.
 */
Future<String> signInWithGoogle() async {
  final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  final FirebaseUser user = await _auth.signInWithGoogle(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  assert(user.email != null);
  assert(user.displayName != null);
  assert(!user.isAnonymous);
  assert(await user.getToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  print("This user is signed in: $user");

  return 'signInWithGoogle succeeded: $user';
}

/*
  Logout current Firebase User
 */
void logoutUser() {
  _auth.signOut();
}

/*
  An Authentication State Listener
 */
void initAuthStateListener(Function p) {
  _auth.onAuthStateChanged.listen((FirebaseUser user){
    if(user != null) {
      Function.apply(p, [true]);
    } else {
      Function.apply(p, [false]);
    }
  });
}