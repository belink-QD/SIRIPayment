//
//  AppDelegate.m
//  SIRIPayment
//
//  Created by 宋法键 on 2020/9/24.
//  Copyright © 2020 SFJ. All rights reserved.
//

#import "AppDelegate.h"
#import <Intents/Intents.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [INPreferences requestSiriAuthorization:^(INSiriAuthorizationStatus status) {
        NSLog(@"%ld", (long)status);
    }];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
{
    
    if (@available(iOS 10.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([userActivity.interaction.intent isKindOfClass:[INSendPaymentIntent class]]) {
                INSendPaymentIntent *sendPaymentIntent = (INSendPaymentIntent *)(userActivity.interaction.intent);
                NSString *displayName = sendPaymentIntent.payee.displayName;
                NSString *amount = [NSString stringWithFormat:@"%@", sendPaymentIntent.currencyAmount.amount];
                NSLog(@"displayName: %@ -- amount: %@", displayName, amount);
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                    NSString *title = [NSString stringWithFormat:@"收款人:%@", displayName];
                    NSString *message = [NSString stringWithFormat:@"金额:%@", amount];
                    
                    UIAlertView *alt = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"好" otherButtonTitles: nil];
                    [alt show];
                    
                });
            }
        });
    }
    
    return YES;
}


@end
