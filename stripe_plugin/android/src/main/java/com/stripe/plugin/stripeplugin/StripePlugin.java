package com.stripe.plugin.stripeplugin;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.google.common.collect.ImmutableMap;

import android.util.Log;
import android.app.Activity;
import android.content.Context;
import android.os.Build;
import com.stripe.android.model.Card;
import com.stripe.android.model.Customer;
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
    this.context = activity.getApplicationContext();
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
      String stripeSecretKey = call.argument("stripeSecretKey");
      final Card card = new Card(
              cardNumber,
              Integer.parseInt(cardExpMonth),
              Integer.parseInt(cardExpYear),
              cardCVC
      );
      if (!card.validateCard()) {
        // Show errors
        result.error("INVALID", "Invalid Card. Please check card number, expiry date and CVC", null);
      }
      else {
        Stripe stripe = new Stripe(context, stripeKey);
        stripe.createToken(
                card,
                new TokenCallback() {
                  public void onSuccess(Token token) {
                    // Send token to your server
                    Log.i("stripe", "SUCCESS TOKEN");
                    ImmutableMap.Builder<String, Object> cardMap = ImmutableMap.<String, Object>builder();
                    cardMap.put("token", token.getId());
                    //cardMap.put("fingerprint", card.getFingerprint());
                    cardMap.put("brand", card.getBrand());
                    cardMap.put("lastdigits", card.getLast4());
                    result.success(cardMap.build());
                /*Map<String, Object> customerParams = new HashMap<String, Object>();
                customerParams.put("email", "paying.user@example.com");
                customerParams.put("source", token.getId());
                Customer customer = Customer.create(customerParams);

                HashMap<String, Object> sourcesParams = new HashMap<String, Object>();
                sourcesParams.put("object", "card");
                customer.getSources().all(sourcesParams);*/
                    Log.i("stripe CARD", token.getCard().toJson().toString());

                    //result.success(token.getId());
                  }

                  public void onError(Exception error) {
                    // Show localized error message
                    Log.i("Create Token Error", error.getMessage());
                    result.error("Create Token Error", error.getMessage(), null);
                  }
                }
        );
      }
    } else {
      result.notImplemented();
    }
  }
}
