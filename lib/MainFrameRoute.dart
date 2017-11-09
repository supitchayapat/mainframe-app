import 'package:flutter/material.dart';
import 'src/screen/w2_profsetup_name_a18.dart';
import 'src/screen/w1_email_registry_a16.dart';
import 'src/screen/w1-1_email_login_a2.dart';
import 'src/screen/w3_profsetup_bday_a6.dart';
import 'src/screen/w4_profsetup_category_a7.dart';
import 'src/screen/main_screen.dart';
import 'src/screen/SplashScreen.dart';
import 'src/screen/w0_login_a2.dart';
import 'src/screen/login_screen.dart';
import 'src/screen/forgot_password_a3.dart';

/*
  Author: Art

  [_MainFrameRoute] this class contains all routing/navigation path
  for the application. It also utilizes a fade transition when going
  to another screen
 */
class MainFrameRoute<T> extends MaterialPageRoute<T> {
  MainFrameRoute({ WidgetBuilder builder, RouteSettings settings })
      : super(builder: builder, settings: settings);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (settings.isInitialRoute)
      return child;

    return new FadeTransition(opacity: animation, child: child);
  }
}

/*
  Method for getting all the route for this application
 */
Route<Null> getMainFrameOnRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return new MainFrameRoute(
        builder: (_) => new MainFrameSplash(),
        settings: settings,
      );
    case '/login':
      return new MainFrameRoute(
        builder: (_) => new LoginApp(),
        settings: settings,
      );
    case '/loginscreen':
      return new MainFrameRoute(
        builder: (_) => new LoginScreen(),
        settings: settings,
      );
    case '/forgot-password':
      return new MainFrameRoute(
        builder: (_) => new ForgotPassword(),
        settings: settings,
      );
    case '/mainscreen':
      return new MainFrameRoute(
        builder: (_) => new MainScreen(),
        settings: settings,
      );
    case '/profilesetup-1':
      return new MainFrameRoute(
        builder: (_) => new ProfileSetupName(),
        settings: settings,
      );
    case '/profilesetup-2':
      return new MainFrameRoute(
        builder: (_) => new ProfileSetupBday(),
        settings: settings,
      );
    case '/profilesetup-3':
      return new MainFrameRoute(
        builder: (_) => new ProfileSetupCategory(),
        settings: settings,
      );
    case '/emailRegistry':
      return new MainFrameRoute(
        builder: (_) => new EmailRegistry(),
        settings: settings,
      );
    case '/emailLogin':
      return new MainFrameRoute(
        builder: (_) => new EmailLogin(),
        settings: settings,
      );
    default:
      return null;
  }
}

Map<String, WidgetBuilder> getMainFrameRoute() {
  return <String, WidgetBuilder>{
    '/':         (BuildContext context) => new MainFrameSplash(),
    '/login':         (BuildContext context) => new LoginApp(),
    '/loginscreen':         (BuildContext context) => new LoginScreen(),
    '/forgot-password':         (BuildContext context) => new ForgotPassword(),
    '/mainscreen': (BuildContext context) => new MainScreen(),
    '/profilesetup-1': (BuildContext context) => new ProfileSetupName(),
    '/profilesetup-2': (BuildContext context) => new ProfileSetupBday(),
    '/profilesetup-3': (BuildContext context) => new ProfileSetupCategory(),
    '/emailRegistry': (BuildContext context) => new EmailRegistry(),
    '/emailLogin': (BuildContext context) => new EmailLogin(),
  };
}