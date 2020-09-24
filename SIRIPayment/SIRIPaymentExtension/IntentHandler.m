//
//  IntentHandler.m
//  SIRIPaymentExtension
//
//  Created by 宋法键 on 2020/9/24.
//  Copyright © 2020 SFJ. All rights reserved.
//

#import "IntentHandler.h"
#import "SIRISendPaymentIntentHandler.h"

@interface IntentHandler ()

@end

@implementation IntentHandler

- (id)handlerForIntent:(INIntent *)intent {
    
    // 如果是转账请求，那么返回我们自己创建的转账处理类 SIRISendPaymentIntentHandler
    if ([intent isKindOfClass:[INSendPaymentIntent class]]) {
        return [[SIRISendPaymentIntentHandler alloc] init];
    }
    
    return self;
}

@end
