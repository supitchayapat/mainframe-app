#import "FacebookSignInPlugin.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareLinkContent.h>
#import <FBSDKShareKit/FBSDKMessageDialog.h>
#import <FBSDKShareKit/FBSDKShareDialog.h>

@implementation FacebookSignInPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"facebook_sign_in"
            binaryMessenger:[registrar messenger]];
  FacebookSignInPlugin* instance = [[FacebookSignInPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if([@"loginWithReadPermissions" isEqualToString:call.method]) {
    NSArray *readArray = call.arguments[@"permissions"];
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    login.loginBehavior = FBSDKLoginBehaviorWeb;
    [login
        logInWithReadPermissions: readArray
              fromViewController:self
                         handler:^(FBSDKLoginManagerLoginResult *res, NSError *error) {
        if (error) {
          NSLog(@"Process error");
          result([FlutterError errorWithCode:@"FBERRORR"
                                           message:@"Facebook Login Error"
                                           details:nil]);
        } else if (res.isCancelled) {
          NSLog(@"Cancelled");
          result(nil);
        } else {
          NSString *fbAccessToken = [FBSDKAccessToken currentAccessToken].tokenString;
          NSLog(@"IOS: Logged in = %@", fbAccessToken);
          result(fbAccessToken);
        }
      }];
  } else if([@"isLoggedIn" isEqualToString:call.method]) {
    // isLoggedIn
    if ([FBSDKAccessToken currentAccessToken]) {
       NSLog(@"IOS: Logged in TRUE");
       result([NSNumber numberWithBool:YES]);
    }
    else {
       NSLog(@"IOS: Logged in FALSE");
       result([NSNumber numberWithBool:NO]);
    }
  } else if([@"getToken" isEqualToString:call.method]) {
    // getToken
    NSString *fbAccessToken = [FBSDKAccessToken currentAccessToken].tokenString;
    result(fbAccessToken);
  } else if([@"logout" isEqualToString:call.method]) {
    // logout
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    login.loginBehavior = FBSDKLoginBehaviorWeb;
    [login logOut];
    result(nil);
  } else if([@"shareDialog" isEqualToString:call.method]) {
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:@"https://developers.facebook.com"];

    [FBSDKMessageDialog showWithContent:content delegate:nil];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end