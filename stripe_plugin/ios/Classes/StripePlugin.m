#import "StripePlugin.h"
#import <Stripe/Stripe.h>

@implementation StripePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"stripe_plugin"
            binaryMessenger:[registrar messenger]];
  StripePlugin* instance = [[StripePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"createToken" isEqualToString:call.method]) {
    NSLog(@"IOS: can create token");
    NSString *cardNumber = call.arguments[@"cardNumber"];
    NSString *cardExpMonth = call.arguments[@"cardExpMonth"];
    NSString *cardExpYear = call.arguments[@"cardExpYear"];
    NSString *cardCVC = call.arguments[@"cardCVC"];
    NSString *stripeKey = call.arguments[@"stripeKey"];

    STPCardParams *cardParams = [STPCardParams new];
    cardParams.number = cardNumber;
    cardParams.expMonth = [cardExpMonth integerValue];
    cardParams.expYear = [cardExpYear integerValue];
    cardParams.cvc = cardCVC;

    STPSourceParams *sourceParams = [STPSourceParams cardParamsWithCard:cardParams];

    [[STPAPIClient sharedClient] createSourceWithParams:sourceParams completion:^(STPSource *source, NSError *error) {
        NSLog(@"IOS: source = %@", @(source.flow));
        if (error) {
            NSLog(@"IOS Error: failed to create token");
            NSLog(@"IOS Error: %@", error.localizedDescription);
            result([FlutterError errorWithCode:@"STRIPE_ERROR"
                                                       message:error.localizedDescription
                                                       details:error.localizedDescription]);
        }
        else if (source.flow == STPSourceFlowNone
            && source.status == STPSourceStatusChargeable) {
            //[self createBackendChargeWithSourceID:source.stripeID];
            NSLog(@"IOS: token - %@", source.stripeID);
            NSString *last4 = [NSString stringWithFormat:@"%@", source.cardDetails.last4];
            NSLog(@"IOS: last 4 - %ld", last4);
            NSString *brand = [STPCard stringFromBrand:source.cardDetails.brand];
            NSLog(@"IOS: brand - %@", brand);
            NSDictionary<NSString *, NSString *> *cardBuilder = @{
                @"token" : source.stripeID ?: [NSNull null],
                @"brand" : brand ?: [NSNull null],
                @"lastdigits" : last4 ?: [NSNull null],
            };
            //result(source.stripeID);
            result(cardBuilder);
        }
        else {
            NSLog(@"IOS: source might have additional auth");
            result([FlutterError errorWithCode:@"STRIPE_ERROR"
                                                       message:@"Payment Transaction Error. Please contact developer."
                                                       details:nil]);
        }
    }];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
