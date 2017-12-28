import 'dart:async';
import 'dart:convert';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';


const String cloudFunctionsUri = "https://us-central1-uberregister-5308a.cloudfunctions.net";
final FirebaseAuth _auth = FirebaseAuth.instance;

class MFHttpUtil {
  static Future<List> requestFacebookFriends() async {
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
  }

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
}