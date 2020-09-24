//
//  SIRISendPaymentIntentHandler.m
//  SIRIPaymentExtension
//
//  Created by 宋法键 on 2020/9/24.
//  Copyright © 2020 SFJ. All rights reserved.
//

#import "SIRISendPaymentIntentHandler.h"
#import <Intents/Intents.h>

@interface SIRISendPaymentIntentHandler ()<INSendPaymentIntentHandling>

@end

@implementation SIRISendPaymentIntentHandler

//Resolve - payee 解析收款人 iOS10.0
- (void)resolvePayeeForSendPayment:(INSendPaymentIntent *)intent withCompletion:(void (^)(INPersonResolutionResult * _Nonnull))completion {
    if (intent.payee == nil || !intent.payee.displayName.length) {
        //如果收款人为空，那么请求siri，需要收款人
        INPersonResolutionResult *resolutionResult = [INPersonResolutionResult notRequired];
        completion(resolutionResult);
    }
    else {
        //收款人不为空，确认收款人信息
        INPersonResolutionResult *resolutionResult = [INPersonResolutionResult successWithResolvedPerson:intent.payee];
        completion(resolutionResult);
    }
}

//Resolve - currency 解析货币 iOS10.0
- (void)resolveCurrencyAmountForSendPayment:(INSendPaymentIntent *)intent withCompletion:(void (^)(INCurrencyAmountResolutionResult * _Nonnull))completion {
    INCurrencyAmount *currencyAmount = intent.currencyAmount;
    if (currencyAmount == nil) {
        //金额为空，请求siri，需要转账金额
        INCurrencyAmountResolutionResult *resolutionResult = [INCurrencyAmountResolutionResult needsValue];
        completion(resolutionResult);
    }
    else if ([currencyAmount.currencyCode isEqualToString:@"CNY"]) {
        //如果币种不是人民币，将接收到的币种转化为人民币
        INCurrencyAmount *newCurrencyAmount = [[INCurrencyAmount alloc] initWithAmount:currencyAmount.amount currencyCode:@"CNY"];
        INCurrencyAmountResolutionResult *resolutionResult = [INCurrencyAmountResolutionResult successWithResolvedCurrencyAmount:newCurrencyAmount];
        completion(resolutionResult);
    }
    else {
        INCurrencyAmountResolutionResult *resolutionResult = [INCurrencyAmountResolutionResult successWithResolvedCurrencyAmount:currencyAmount];
        completion(resolutionResult);
    }
}

//Resolve - payee 解析收款人 iOS11.0
- (void)resolvePayeeForSendPayment:(INSendPaymentIntent *)intent completion:(void (^)(INSendPaymentPayeeResolutionResult * _Nonnull))completion  API_AVAILABLE(ios(11.0)){
    if (intent.payee == nil) {
        INSendPaymentPayeeResolutionResult *resolutionResult = [INSendPaymentPayeeResolutionResult needsValue];
        completion(resolutionResult);
    }
    else {
        INSendPaymentPayeeResolutionResult *resolutionResult = [INSendPaymentPayeeResolutionResult successWithResolvedPerson:intent.payee];
        completion(resolutionResult);
    }
}

//Resolve - currency 解析货币单位 iOS11.0
- (void)resolveCurrencyAmountForSendPayment:(INSendPaymentIntent *)intent completion:(void (^)(INSendPaymentCurrencyAmountResolutionResult * _Nonnull))completion  API_AVAILABLE(ios(11.0)){
    INCurrencyAmount *currencyAmount = intent.currencyAmount;
    if (currencyAmount == nil || currencyAmount.amount == nil) {
        INSendPaymentCurrencyAmountResolutionResult *resolutionResult = [INSendPaymentCurrencyAmountResolutionResult needsValue];
        completion(resolutionResult);
    }
    else if (![currencyAmount.currencyCode isEqualToString:@"CNY"]) {
        //货币格式转化为人民币
        INCurrencyAmount *newCurrencyAmount = [[INCurrencyAmount alloc] initWithAmount:currencyAmount.amount currencyCode:@"CNY"];
        INSendPaymentCurrencyAmountResolutionResult *resolutionResult = [INSendPaymentCurrencyAmountResolutionResult successWithResolvedCurrencyAmount:newCurrencyAmount];
        completion(resolutionResult);
    } else {
        INSendPaymentCurrencyAmountResolutionResult *resolutionResult = [INSendPaymentCurrencyAmountResolutionResult successWithResolvedCurrencyAmount:currencyAmount];
        completion(resolutionResult);
    }
}

//Confirm - 确认金额信息
- (void)confirmSendPayment:(INSendPaymentIntent *)intent completion:(void (^)(INSendPaymentIntentResponse * _Nonnull))completion {
    NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:NSStringFromClass([INSendPaymentIntent class])];
    userActivity.title = @"转账";
    userActivity.userInfo = @{@"displayName": intent.payee.displayName?:@"",
                              @"amount": intent.currencyAmount.amount};
    
    //确认支付货币，否则系统会默认展示USD(美元)
    INPaymentMethod *paymentMethod = [INPaymentMethod applePayPaymentMethod];
    //status字段决定了siri转账页面底部的UI
    INPaymentRecord *paymentRecord = [[INPaymentRecord alloc] initWithPayee:intent.payee payer:nil currencyAmount:intent.currencyAmount paymentMethod:paymentMethod note:intent.note status:(INPaymentStatusPending)];
    INSendPaymentIntentResponse *sendPaymentIntentResponse = [[INSendPaymentIntentResponse alloc] initWithCode:(INSendPaymentIntentResponseCodeReady) userActivity:userActivity];
    sendPaymentIntentResponse.paymentRecord = paymentRecord;
    completion(sendPaymentIntentResponse);
}

//Handle - 转账处理
- (void)handleSendPayment:(INSendPaymentIntent *)intent completion:(void (^)(INSendPaymentIntentResponse * _Nonnull))completion {
    NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:NSStringFromClass([INSendPaymentIntent class])];
    userActivity.title = @"转账";
    userActivity.userInfo = @{@"displayName": intent.payee.displayName?:@"",
                              @"amount": intent.currencyAmount.amount};
    INSendPaymentIntentResponse *sendPaymentIntentResponse = [[INSendPaymentIntentResponse alloc] initWithCode:(INSendPaymentIntentResponseCodeInProgress) userActivity:userActivity];
    completion(sendPaymentIntentResponse);
}

@end
