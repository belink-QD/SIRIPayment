//
//  IntentViewController.m
//  SIRIPaymentExtensionUI
//
//  Created by 宋法键 on 2020/9/24.
//  Copyright © 2020 SFJ. All rights reserved.
//

#import "IntentViewController.h"
#import <Intents/Intents.h>

// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

@interface IntentViewController ()<INUIHostedViewSiriProviding>
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@end

@implementation IntentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - INUIHostedViewSiriProviding

- (BOOL)displaysPaymentTransaction {
    return YES;;
}

#pragma mark - INUIHostedViewControlling
- (void)configureWithInteraction:(INInteraction *)interaction context:(INUIHostedViewContext)context completion:(void (^)(CGSize))completion {
    
    if ([interaction.intent isKindOfClass:[INSendPaymentIntent class]] && (interaction.intentHandlingStatus == INIntentHandlingStatusReady)) {
        INSendPaymentIntent *sendPaymentIntent = (INSendPaymentIntent *)interaction.intent;
        self.amountLabel.text = [NSString stringWithFormat:@"￥%.2f", sendPaymentIntent.currencyAmount.amount.doubleValue];
        if (completion) {
            completion(CGSizeMake([self desiredSize].width, 200));
        }
    } else {
        if (completion) {
            completion(CGSizeZero);
        }
    }
}

// Prepare your view controller for the interaction to handle.
- (void)configureViewForParameters:(NSSet <INParameter *> *)parameters ofInteraction:(INInteraction *)interaction interactiveBehavior:(INUIInteractiveBehavior)interactiveBehavior context:(INUIHostedViewContext)context completion:(void (^)(BOOL success, NSSet <INParameter *> *configuredParameters, CGSize desiredSize))completion  API_AVAILABLE(ios(11.0)){
    // Do configuration here, including preparing views and calculating a desired size for presentation.

    if ([interaction.intent isKindOfClass:[INSendPaymentIntent class]] &&
        (interaction.intentHandlingStatus == INIntentHandlingStatusReady) &&
        [[parameters anyObject].parameterKeyPath isEqualToString:@"currencyAmount"]) {
        INSendPaymentIntent *sendPaymentIntent = (INSendPaymentIntent *)interaction.intent;
        self.amountLabel.text = [NSString stringWithFormat:@"￥%.2f", sendPaymentIntent.currencyAmount.amount.doubleValue];
        completion(YES, parameters, CGSizeMake([self desiredSize].width, 200));
    } else {
        completion(YES, parameters, CGSizeZero);
    }
}

- (CGSize)desiredSize {
    return [self extensionContext].hostedViewMaximumAllowedSize;
}

@end
