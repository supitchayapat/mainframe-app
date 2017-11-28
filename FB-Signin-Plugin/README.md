# STILL IN DEVELOPMENT, DON'T USE FOR PROJECTS YET.

# facebook_sign_in

Flutter plugin implementing native Facebook sdks for authentication. This plugin works on iOS and Android.

## Android Setup (The example app includes an example of the setup)
### Step 1
- In `android/app/src/main/res` create a new map called "values" (you can skip this if you already have this map). 
- Create a new file in the "values" directory called "strings.xml" (you can skip this if you already have this file).
- If you just created the "strings.xml" file, add the following code (leave out the "resources" tags if you got them already):
```
<resources>
    <string name="facebook_app_id">XXX</string>
    <string name="fb_login_protocol_scheme">fbXXX</string>
</resources>
```
- Replace the XXX with your Facebook app id (leave the "fb" prefix in the second string).
### Step 2
- Navigate to `android/app/src/main/AndroidManifest.xml`.
- In the "application" tags, add the following code at the top:
```
<meta-data android:name="com.facebook.sdk.ApplicationId" 
    android:value="@string/facebook_app_id"/>
```
- Add the following code after the "activity" tags:
```
<activity
    android:name="com.facebook.CustomTabActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="@string/fb_login_protocol_scheme" />
    </intent-filter>
</activity>
```
#### Here is a template of what the application tag should look like:
```
<application android:name="io.flutter.app.FlutterApplication" android:label="facebook_sign_in_example" android:icon="@mipmap/ic_launcher">
    <meta-data android:name="com.facebook.sdk.ApplicationId" 
        android:value="@string/facebook_app_id"/>
    <activity android:name=".MainActivity"
                android:launchMode="singleTop"
                android:theme="@android:style/Theme.Black.NoTitleBar"
                android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|layoutDirection"
                android:hardwareAccelerated="true"
                android:windowSoftInputMode="adjustResize">
        <intent-filter>
            <action android:name="android.intent.action.MAIN"/>
            <category android:name="android.intent.category.LAUNCHER"/>
        </intent-filter>
    </activity>
    <activity
        android:name="com.facebook.CustomTabActivity"
        android:exported="true">
        <intent-filter>
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data android:scheme="@string/fb_login_protocol_scheme" />
        </intent-filter>
    </activity>
</application>
```

## Using the plugin

### Importing the plugin
```
import 'package:facebook_sign_in/facebook_sign_in.dart';
```

### Login with Read Permissions:
```
loginWithReadPermissions(List<String> permissions)
```
`loginWithReadPermissions` logs the user in with the given read permissions. This function is asynchronous.
- params: 
    - `List<String> permissions`:  A list of permissions the developer wants.
- returns:
    - `Future<String> token`
    
A full list of permissions can be found here: https://developers.facebook.com/docs/facebook-login/permissions/
#### Usage
```
await FacebookSignIn.loginWithReadPermissions(read);
```

### Login with Publish Permissions:
```
loginWithPublishPermissions(List<String> permissions)
```
`loginWithPublishPermissions` logs the user in with the given publish permissions. This function is asynchronous.
- params: 
    - `List<String> permissions`:  A list of permissions the developer wants.
- returns:
    - `Future<String> token`
    
 A full list of permissions can be found here: https://developers.facebook.com/docs/facebook-login/permissions/
#### Usage
```
await FacebookSignIn.loginWithPublishPermissions(publish);
```

### Logging out
```
logout()
```
`logout` logs out the currently signed in user. This function is asynchronous.
- returns:
    - `Future<String> success`
#### Usage
```
await FacebookSignIn.logout();
```

## Getting Started

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).

## Special thanks to:
- Brian Egan: https://github.com/brianegan/bansa (Helping out with wiring up the android code)
