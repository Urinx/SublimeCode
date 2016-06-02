//
//  ObjC.h
//  Sublime
//
//  Created by Eular on 5/6/16.
//  Copyright © 2016 Eular. All rights reserved.
//
#import <Foundation/Foundation.h>
#include <sys/socket.h>
#include <net/if.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#include <objc/runtime.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <NetworkExtension/NEHotspotHelper.h>

@interface ObjC : NSObject
+(NSString*) SSID;
+(NSString*) BSSID;
+(NSArray*) getAppList;
+(NSDictionary*) getDataFlowBytes;
@end