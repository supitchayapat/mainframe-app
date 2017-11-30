import 'dart:async';
import 'dart:convert';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:flutter/services.dart';

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
}