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
import 'src/screen/entry_form_a24.dart';
import 'src/screen/about_us.dart';
import 'src/screen/add_dance_partner.dart';
import 'src/screen/event_details.dart';
import 'src/screen/ticket_summary_a60.dart';
import 'src/screen/event_registration.dart';
import 'src/screen/event_result.dart';
import 'src/screen/event_heatlist.dart';
import 'src/screen/couple_management.dart';
import 'src/screen/participant_list.dart';
import 'src/screen/entry_summary.dart';
import 'src/screen/checkout_entry.dart';
import 'src/screen/entry_freeform.dart';
import 'src/screen/GroupDance.dart';
import 'src/screen/payment_success.dart';
import 'src/screen/solo_management.dart';
import 'src/screen/attendee_management.dart';
import 'src/screen/change_password.dart';
import 'src/screen/forgotpass_success.dart';
import 'src/screen/feedback.dart';
import 'src/screen/ticket_purchase.dart';
import 'src/screen/studio_details.dart';
import 'src/screen/payment_notice.dart';

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
    case '/contactUs':
      return new MainFrameRoute(
        builder: (_) => new AboutUs(),
        settings: settings,
      );
    case '/forgot-password':
      return new MainFrameRoute(
        builder: (_) => new ForgotPassword(),
        settings: settings,
      );
    case '/forgotpass_success':
      return new MainFrameRoute(
        builder: (_) => new forgotpass_success(),
        settings: settings,
      );
    case '/change-password':
      return new MainFrameRoute(
        builder: (_) => new change_password(),
        settings: settings,
      );
    case '/mainscreen':
      return new MainFrameRoute(
        builder: (_) => new MainScreen(),
        settings: settings,
      );
    case '/feedback':
      return new MainFrameRoute(
        builder: (_) => new feedback(),
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
    case '/entryForm':
      return new MainFrameRoute(
        builder: (_) => new EntryForm(),
        settings: settings,
      );
    case '/entryFreeForm':
      return new MainFrameRoute(
        builder: (_) => new entry_freeform(),
        settings: settings,
      );
    case '/entryGroupForm':
      return new MainFrameRoute(
        builder: (_) => new GroupDance(),
        settings: settings,
      );
    case '/addPartner':
      return new MainFrameRoute(
        builder: (_) => new AddDancePartner(),
        settings: settings,
      );
    case '/event':
      return new MainFrameRoute(
        builder: (_) => new EventDetails(),
        settings: settings,
      );
    case '/ticketSummary':
      return new MainFrameRoute(
        builder: (_) => new ticket_summary_a60(),
        settings: settings,
      );
    case '/ticketPurchase':
      return new MainFrameRoute(
        builder: (_) => new ticket_purchase(),
        settings: settings,
      );
    case '/registration':
      return new MainFrameRoute(
        builder: (_) => new event_registration(),
        settings: settings,
      );
    case '/result':
      return new MainFrameRoute(
        builder: (_) => new event_result(),
        settings: settings,
      );
    case '/heatlist':
      return new MainFrameRoute(
        builder: (_) => new event_heatlist(),
        settings: settings,
      );
    case '/coupleManagement':
      return new MainFrameRoute(
        builder: (_) => new couple_management(),
        settings: settings,
      );
    case '/soloManagement':
      return new MainFrameRoute(
        builder: (_) => new solo_management(),
        settings: settings,
      );
    case '/attendeeManagement':
      return new MainFrameRoute(
        builder: (_) => new attendee_management(),
        settings: settings,
      );
    case '/participants':
      return new MainFrameRoute(
        builder: (_) => new participant_list(),
        settings: settings,
      );
    case '/studioDetails':
      return new MainFrameRoute(
        builder: (_) => new studio_details(),
        settings: settings,
      );
    case '/registrationSummary':
      return new MainFrameRoute(
        builder: (_) => new entry_summary(),
        settings: settings,
      );
    case '/checkoutEntry':
      return new MainFrameRoute(
        builder: (_) => new checkout_entry(),
        settings: settings,
      );
    case '/paymentSuccess':
      return new MainFrameRoute(
        builder: (_) => new payment_success(),
        settings: settings,
      );
    case '/paymentNotice':
      return new MainFrameRoute(
        builder: (_) => new payment_notice(),
        settings: settings,
      );
    default:
      return null;
  }
}

Map<String, WidgetBuilder> getMainFrameRoute() {
  return <String, WidgetBuilder>{
    '/': (BuildContext context) => new MainFrameSplash(),
    '/login': (BuildContext context) => new LoginApp(),
    '/loginscreen': (BuildContext context) => new LoginScreen(),
    '/contactUs': (BuildContext context) => new AboutUs(),
    '/forgot-password': (BuildContext context) => new ForgotPassword(),
    '/forgotpass-success': (BuildContext context) => new forgotpass_success(),
    '/change-password': (BuildContext context) => new change_password(),
    '/mainscreen': (BuildContext context) => new MainScreen(),
    '/feedback': (BuildContext context) => new feedback(),
    '/profilesetup-1': (BuildContext context) => new ProfileSetupName(),
    '/profilesetup-2': (BuildContext context) => new ProfileSetupBday(),
    '/profilesetup-3': (BuildContext context) => new ProfileSetupCategory(),
    '/emailRegistry': (BuildContext context) => new EmailRegistry(),
    '/emailLogin': (BuildContext context) => new EmailLogin(),
    '/entryForm': (BuildContext context) => new EntryForm(),
    '/entryFreeForm': (BuildContext context) => new entry_freeform(),
    '/entryGroupForm': (BuildContext context) => new GroupDance(),
    '/addPartner': (BuildContext context) => new AddDancePartner(),
    '/event': (BuildContext context) => new EventDetails(),
    '/ticketSummary': (BuildContext context) => new ticket_summary_a60(),
    '/ticketPurchase': (BuildContext context) => new ticket_purchase(),
    '/registration': (BuildContext context) => new event_registration(),
    '/result': (BuildContext context) => new event_result(),
    '/heatlist': (BuildContext context) => new event_heatlist(),
    '/coupleManagement': (BuildContext context) => new couple_management(),
    '/soloManagement': (BuildContext context) => new solo_management(),
    '/attendeeManagement': (BuildContext context) => new attendee_management(),
    '/participants': (BuildContext context) => new participant_list(),
    '/studioDetails': (BuildContext context) => new studio_details(),
    '/registrationSummary': (BuildContext context) => new entry_summary(),
    '/checkoutEntry': (BuildContext context) => new checkout_entry(),
    '/paymentSuccess': (BuildContext context) => new payment_success(),
    '/paymentNotice': (BuildContext context) => new payment_notice(),
  };
}