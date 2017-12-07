// facebook_sign_in.dart
//
// File with functions to communincate with native platform and define functions to use in Flutter code.

import 'dart:async';

import 'package:flutter/services.dart';

class FacebookSignIn {
    static const MethodChannel _channel =
        const MethodChannel('facebook_sign_in');

    /// Login with read permissions.
    /// 
    /// Logs the user in with a list of read permissions to provide.
    static Future<String> loginWithReadPermissions(List<String> permissions) {
        return _channel.invokeMethod("loginWithReadPermissions", <String, List<String>> {
            "permissions": permissions
        });
    }

    /// Login with publish permissions.
    /// 
    /// Logs the user in with a list of publish permissions to provide.
    static Future<String> loginWithPublishPermissions(List<String> permissions) {
        return _channel.invokeMethod("loginWithPublishPermissions", <String, List<String>> {
            "permissions": permissions
        });
    }

    /// Logout user.
    static Future<String> logout() {
        return _channel.invokeMethod("logout");
    }

    static Future<bool> isLoggedIn() {
        return _channel.invokeMethod("isLoggedIn");
    }

    static Future<String> getToken() {
        return _channel.invokeMethod("getToken");
    }

    static Future<String> shareDialog() {
        return _channel.invokeMethod("shareDialog");
    }
}
