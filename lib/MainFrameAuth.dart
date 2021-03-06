import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
//import 'package:facebook_sign_in/facebook_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:myapp/MFGlobals.dart' as global;
import 'package:myapp/src/dao/UserDao.dart';

/*
  Author: Art

  This dart contains the Authentication methods that is utilized in this Application
 */

final FirebaseAuth _auth = FirebaseAuth.instance;
final List<String> read = ["public_profile", "user_friends", "email", "user_birthday"];
final facebookLogin = new FacebookLogin();

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
  bool isLogged = await facebookLogin.isLoggedIn;
  if(!isLogged) {
    FacebookLoginResult res = await facebookLogin.logInWithReadPermissions(read);
    token = res.accessToken.token;
  }
  else {
    token = (await facebookLogin.currentAccessToken).token;
  }
  print("token: $token");
  final FirebaseUser user = await _auth.signInWithFacebook(accessToken: token);
  assert(user.email != null);
  assert(user.displayName != null);
  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

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
  bool isLogged = await facebookLogin.isLoggedIn;
  if(!isLogged) {
    FacebookLoginResult res = await facebookLogin.logInWithReadPermissions(read);
    token = res.accessToken.token;
  }
  else {
    token = (await facebookLogin.currentAccessToken).token;
  }
  print("token: $token");
  FirebaseUser user = await _auth.signInWithFacebook(accessToken: token);
  assert(user.email != null);
  assert(user.displayName != null);
  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  print("This user is signed in: $user");
  //_checkUserExisting(user, token);

  //return 'signInWithGoogle succeeded: $user';
  return await _checkUserExisting(user, token);
}

Future _checkUserExisting(FirebaseUser user, String token) async {
  String returnVal = "failed";
  var exists = await userExists(user);
  if(exists == null) {
    print("NEW USER");
    // register user on RDB
    // make http request to get additional info
    /*String url = 'https://graph.facebook.com/me?fields=first_name,last_name,gender,birthday,picture&access_token=$token';
    var httpClient = createHttpClient();
    var resp = await httpClient.read(url);
    print('response = $resp');
    saveUserFromResponse(resp, user);*/
    // create the access token and execute cloud function
    saveUserAccessToken(token);
    returnVal = "new-user";
  }
  else {
    print("EXISTING USER");
    if(exists.hasProfileSetup) {
      returnVal = "success";
    }
  }
  return returnVal;
}

/*
  Logout current Firebase User
 */
void logoutUser() {
  _auth.signOut();
  global.resetGlobal();
}

/*
  An Authentication State Listener
 */
StreamSubscription initAuthStateListener(Function p) {
  return _auth.onAuthStateChanged.listen((user) async {
    print("AUTHENTICATION HAS CHANGED!!!!!");

    return _auth.currentUser().then((fireUser){
      fireUser.getIdToken().then((ftoken){
        print("ID TOKEN: $ftoken");

        return getCurrentUserProfile().then((fuser){
          if(user != null) {
            if(fuser == null) {
              //FirebaseAuth.instance.signOut();
              Function.apply(p, [false]);
            } else {
              Function.apply(p, [true]);
            }
          } else {
            //print("USER NULL");
            Function.apply(p, [false]);
          }
        });

      }).catchError((err){
        print("GET TOKEN ERROR: $err");
        Function.apply(p, [false]);
      });
    }).catchError((err){
      print("GET CURRENT USER ERROR: $err");
      Function.apply(p, [false]);
    });

  });
}

Future<StreamSubscription> newUserListener(Function p) async {
  return await savedUserListener(p);
}

Future<StreamSubscription> removeUserListener(Function p) async {
  return await deleteUserListener(p);
}