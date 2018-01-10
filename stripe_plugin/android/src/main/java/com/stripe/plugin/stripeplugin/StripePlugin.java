package com.stripe.plugin.stripeplugin;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import android.util.Log;
import android.app.Activity;
import android.content.Context;
import com.stripe.android.model.Card;
import com.stripe.android.Stripe;
import com.stripe.android.model.Token;
import com.stripe.android.TokenCallback;

/**
 * StripePlugin
 */
public class StripePlugin implements MethodCallHandler {
  private static final String CHANNEL_NAME = "stripe_plugin";
  private Context context;

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "stripe_plugin");
    channel.setMethodCallHandler(new StripePlugin(registrar.activity()));
  }

  private StripePlugin(Activity activity) {
    this.context = activity.getApplicationContext();;
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    Log.i("stripe", "can create token");
    if (call.method.equals("createToken")) {
      String cardNumber = call.argument("cardNumber");
      String cardExpMonth = call.argument("cardExpMonth");
      String cardExpYear = call.argument("cardExpYear");
      String cardCVC = call.argument("cardCVC");
      String stripeKey = call.argument("stripeKey");
      Card card = new Card(
              cardNumber,
              Integer.parseInt(cardExpMonth),
              Integer.parseInt(cardExpYear),
              cardCVC
      );
      if (!card.validateCard()) {
        // Show errors
        result.error("INVALID", "Invalid Card. Please check card number, expiry date and CVC", null);
      }
      Stripe stripe = new Stripe(context, stripeKey);
      stripe.createToken(
              card,
              new TokenCallback() {
                public void onSuccess(Token token) {
                  // Send token to your server
                  result.success(token.getId());
                }
                public void onError(Exception error) {
                  // Show localized error message
                  result.error("Create Token Error", error.getMessage(), error);
                }
              }
      );
    } else {
      result.notImplemented();
    }
  }
}
