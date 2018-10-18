import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:myapp/src/util/ScreenUtils.dart';


//const String cloudFunctionsUri = "https://us-central1-uberregister-5308a.cloudfunctions.net/app";
final FirebaseAuth _auth = FirebaseAuth.instance;
const TIMEOUT_DURATION = 20;

class HttpUtil {
  /*static Future<List> requestFacebookFriends() async {
    List users = [];
    String token = await getFBAccessToken();
    //print(token);
    String after = "";
    do {
      String url = 'https://graph.facebook.com/me/taggable_friends?fields=first_name,last_name,id,picture&access_token=$token';
      if(!after.isEmpty) {
        url += "&after=$after";
      }
      //print(url);
      var httpClient = createHttpClient();
      var resp = await httpClient.read(url);
      //print('response = $resp');
      final json_res = JSON.decode(resp);
      json_res["data"].forEach((val) {
        var usr = convertResponseToUser(val);
        usr.displayPhotoUrl = val["picture"]["data"]["url"];
        //print(usr.toJson());
        users.add(usr);
      });

      after = "";
      if(json_res["paging"] != null) {
        var _cursors = json_res["paging"]["cursors"];
        if(_cursors != null) {
          after = _cursors["after"];
        }
      }
      //print(after);
    } while(!after.isEmpty);

    users.sort((a, b) => (a.first_name).compareTo(b.first_name));
    //users.forEach((usr) => print(usr.toJson()));
    saveUserFriends(users);

    return users;
  }*/

  static Future sendMailInvite() async {
    final FirebaseUser currentUser = await _auth.currentUser();
    final String idToken = await currentUser.getIdToken();
    print(idToken);
    Map<String, String> headers = <String, String> {
      "user-agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36",
      "Content-Type": "text/html; charset=utf-8",
      "Authorization": "Bearer ${idToken}",
    };
    print(headers);
    var cloudFunctionsUri = await getProjectUri();
    String _mailerUri = cloudFunctionsUri + "/testAuthEmail";
    var resp = await http.get(Uri.parse(_mailerUri), headers: headers);
    //HttpClient httpClient = new HttpClient();
    //var httpClient = createHttpClient();
    /*var resp = await httpClient.getUrl(Uri.parse(_mailerUri)).then((HttpClientRequest request){
      request.headers.add("Authorization", "Bearer ${currentUser.getIdToken()}");
      return request.close();
    }).then((HttpClientResponse resp){

    });*/
    print(resp.statusCode);
    print(resp.body);
    return resp;
  }

  static Future requestForgotPassword(email) async {
    Map<String, String> headers = <String, String> {
      "user-agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36",
      "Content-Type": "text/html; charset=utf-8",
    };
    print(headers);
    var resp;
    if(email != null && !email.isEmpty) {
      var cloudFunctionsUri = await getProjectUri();
      resp = await http.get(
          Uri.parse(cloudFunctionsUri + "/forgotpass/${email}"),
          headers: headers
      ).timeout(
          new Duration(seconds: TIMEOUT_DURATION)
      ).catchError((error){
        if(error is TimeoutException || error is SocketException) {
          print("Request has timed out");
          throw new StateError("Error: Request has timed out.");
        }
        else {
          print("error: ${error}");
          throw new StateError("Error: Internal error has occurred. Please contact support.");
        }
      });
    }
    return resp;
  }

  static Future requestChangePassword(context, tokenId, password) async {
    Map<String, String> headers = <String, String> {
      "user-agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36",
      "Content-Type": "application/json",
    };
    Map<String, String> body = <String, String> {
      "tokenId": tokenId,
      "password": password
    };
    print(headers);
    var resp;
    if(tokenId != null && !tokenId.isEmpty && password != null && !password.isEmpty) {
      var cloudFunctionsUri = await getProjectUri();
      //showMainFrameDialog(context, "debug", "uri = ${cloudFunctionsUri}");
      resp = await http.post(
          Uri.parse(cloudFunctionsUri + "/changepass"),
          headers: headers,
          body: jsonEncode(body)
      ).timeout(
          new Duration(seconds: TIMEOUT_DURATION)
      ).catchError((error){
        showMainFrameDialog(context, "debug", error.message);
        if(error is TimeoutException || error is SocketException) {
          print("Request has timed out");
          throw new StateError("Error: Request has timed out.");
        }
        else {
          print("error: ${error}");
          throw new StateError("Error: Internal error has occurred. Please contact support.");
        }
      });
    }
    return resp;
  }

  static Future getProjectUri() async {
    var data = await rootBundle.loadString('mainframe_assets/conf/config.json');
    var result = json.decode(data);
    String projId = result['project_id'];
    String cloudUri = "https://us-central1-uberregister-5308a.cloudfunctions.net/app";
    if(projId != null || !projId.isEmpty) {
      cloudUri = "https://us-central1-${projId}.cloudfunctions.net/app";
    }
    return cloudUri;
  }
}