//
//  FlutterCalling.swift
//  Runner
//
//  Created by Ahmar Yousaf on 07/01/2022.
//

//import Foundation
//#include "GeneratedPluginRegistrant.h"
//
//@implementation AppDelegate
//        - (BOOL)application:(UIApplication *)application
//        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//        FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
//        FlutterMethodChannel* nativeChannel = [FlutterMethodChannel
//        methodChannelWithName:@"flutter.native/helper"
//        binaryMessenger:controller];
//        __weak  typeof(self) weakSelf = self;
//        [nativeChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
//        if ([@"helloFromNativeCode"  isEqualToString:call.method]) {
//        NSString *strNative = [weakSelf helloFromNativeCode];
//        result(strNative);
//        } else {
//        result(FlutterMethodNotImplemented);
//        }
//        }];
//        [GeneratedPluginRegistrant  registerWithRegistry:self];
//        return [super  application:application didFinishLaunchingWithOptions:launchOptions];
//        }
//        - (NSString *)helloFromNativeCode {
//        return  @"Hello From Native IOS Code";
//        }
//@end
