#import "MframePluginsPlugin.h"
#import "APAddressBook.h"
#import "APContact.h"

@implementation MframePluginsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"mframe_plugins"
            binaryMessenger:[registrar messenger]];
  MframePluginsPlugin* instance = [[MframePluginsPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (NSString *)contactName:(APContact *)contact
{
    if (contact.name.compositeName)
    {
        return contact.name.compositeName;
    }
    else if (contact.name.firstName && contact.name.lastName)
    {
        return [NSString stringWithFormat:@"%@ %@", contact.name.firstName, contact.name.lastName];
    }
    else if (contact.name.firstName || contact.name.lastName)
    {
        return contact.name.firstName ?: contact.name.lastName;
    }
    else
    {
        return @"Untitled contact";
    }
}

- (NSString *)contactPhones:(APContact *)contact
{
    if (contact.phones.count > 0)
    {
        NSMutableString *result = [[NSMutableString alloc] init];
        for (APPhone *phone in contact.phones)
        {
            NSString *string = phone.localizedLabel.length == 0 ? phone.number :
                               [NSString stringWithFormat:@"%@ (%@)", phone.number,
                                                          phone.localizedLabel];
            [result appendFormat:@"%@", string];
            break; // get only 1 phone number
        }
        return result;
    }
    else
    {
        return @"(No phones)";
    }
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getContacts" isEqualToString:call.method]) {
    APAddressBook *addressBook = [[APAddressBook alloc] init];
    // don't forget to show some activity
    [addressBook loadContacts:^(NSArray <APContact *> *contacts, NSError *error)
    {
        NSMutableArray<NSDictionary<NSString *, NSString *> *> *providerData =
                              [NSMutableArray arrayWithCapacity:[contacts count]];
        // hide activity
        if (!error)
        {
            // do something with contacts array
            for(APContact *contact in contacts) {
                NSString *contactName = [self contactName:contact];
                NSString *contactPhone = [self contactPhones:contact];
                NSDictionary<NSString *, NSString *> *contactBuilder = @{
                    @"name" : contactName ?: [NSNull null],
                    @"phoneNumber" : contactPhone ?: [NSNull null],
                };
                //NSLog(@"%@ %@", contactName, contactPhone);
                [providerData addObject:contactBuilder];
            }
            //NSLog(@"provider_count: %d", [providerData count]);
            NSMutableDictionary *contactData = [[NSMutableDictionary alloc] init];
            contactData[@"contacts"] = providerData;
            result(contactData);
        }
        else
        {
            result(nil);
        }
    }];
  } else if ([@"setLandscape" isEqualToString:call.method]) {
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeLeft) forKey:@"orientation"];
  } else if ([@"setPortrait" isEqualToString:call.method]) {
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
  } else if ([@"getPlatform" isEqualToString:call.method]) {
    result(@"ios");
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
