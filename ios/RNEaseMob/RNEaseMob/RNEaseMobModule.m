//
//  RNEaseMobModule.m
//  RNEaseMob
//
//  Created by Xiaosong Gao on 2018/6/12.
//  Copyright © 2018年 Hecom. All rights reserved.
//

#import "RNEaseMobModule.h"
#import "ChatManagerModule.h"
#import "ClientModule.h"
#import "MultiDevicesModule.h"
#import "GroupManagerModule.h"
#import "ContactManagerModule.h"
#import "ChatroomManagerModule.h"

NSString * const EASEMOB_EVENT_NAME = @"RNEaseMob";

@interface RNEaseMobModule ()

@end

@implementation RNEaseMobModule

DEFINE_SINGLETON_FOR_CLASS(RNEaseMobModule);

RCT_EXPORT_MODULE();

#pragma mark - RCTEventEmitter

- (NSArray<NSString *> *)supportedEvents {
    return @[EASEMOB_EVENT_NAME];
}

- (void)sendEventByType:(NSString *)type
                subType:(NSString *)subType
                   data:(NSDictionary *)data {
    NSMutableDictionary *body = [[NSMutableDictionary alloc] initWithDictionary:data];
    [body setObject:type forKey:@"type"];
    [body setObject:subType forKey:@"subType"];
    if ([body objectForKey:@"error_message"]) {
        [body removeObjectForKey:@"error_message"];
    }
    [self sendEvent:body];
}

- (void)sendError:(NSString *)message data:(NSDictionary *)data {
    NSMutableDictionary *body = [[NSMutableDictionary alloc] initWithDictionary:data];
    [body setObject:message forKey:@"error_message"];
    [self sendEvent:body];
}

- (void)sendEvent:(NSDictionary *)params {
    [self sendEventWithName:EASEMOB_EVENT_NAME body:params];
}

#pragma mark - App

RCT_EXPORT_METHOD(init:(NSString *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    [[RNEaseMobModule sharedRNEaseMobModule] init_local:params resolver:resolve rejecter:reject];
}

- (void)init_local:(NSString *)params
          resolver:(RCTPromiseResolveBlock)resolve
          rejecter:(RCTPromiseRejectBlock)reject {
    NSMutableDictionary *allParams = [[NSMutableDictionary alloc] initWithDictionary:[params jsonStringToDictionary]];
    EMOptions *options = [EMOptions optionsWithAppkey:[allParams objectForKey:@"appKey"]];
    if ([[allParams allKeys] count] > 1) {
        [allParams removeObjectForKey:@"appKey"];
        [options updateWithDictionary:allParams];
    }
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    [[EMClient sharedClient] addDelegate:[ClientModule sharedClientModule] delegateQueue:nil];
    [[EMClient sharedClient] addMultiDevicesDelegate:[MultiDevicesModule sharedMultiDevicesModule] delegateQueue:nil];
    [[EMClient sharedClient].groupManager addDelegate:[GroupManagerModule sharedGroupManagerModule] delegateQueue:nil];
    [[EMClient sharedClient].contactManager addDelegate:[ContactManagerModule sharedContactManagerModule] delegateQueue:nil];
    [[EMClient sharedClient].roomManager addDelegate:[ChatroomManagerModule sharedChatroomManagerModule] delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:[ChatManagerModule sharedChatManagerModule] delegateQueue:nil];
}

@end
