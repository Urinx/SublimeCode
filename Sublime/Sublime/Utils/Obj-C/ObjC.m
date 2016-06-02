//
//  ObjC.m
//  Sublime
//
//  Created by Eular on 5/6/16.
//  Copyright © 2016 Eular. All rights reserved.
//

#import "ObjC.h"


@implementation ObjC

+(NSString*) iOS9_SSID {
    for(NEHotspotNetwork *hotspotNetwork in [NEHotspotHelper supportedNetworkInterfaces]) {
        NSString *ssid = hotspotNetwork.SSID;
        //NSString *bssid = hotspotNetwork.BSSID;
        //BOOL secure = hotspotNetwork.secure;
        //BOOL autoJoined = hotspotNetwork.autoJoined;
        //double signalStrength = hotspotNetwork.signalStrength;
        return ssid;
    }
    return @"No WIFI Connection";
}

// http://bencoding.com/2015/08/04/captivenetwork-depreciated-in-ios9/

+(NSString*) SSID {
#if TARGET_IPHONE_SIMULATOR
    return @"Simulator";
#else
    NSString * informationUnknown = @"No WIFI Connection";
    CFArrayRef interfaces = CNCopySupportedInterfaces();//supportedNetworkInterfaces
    if(interfaces == nil){
        return informationUnknown;
    }
    CFIndex count = CFArrayGetCount(interfaces);
    if(count == 0){
        return informationUnknown;
    }
    CFDictionaryRef captiveNtwrkDict =
    CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(interfaces, 0));
    NSDictionary *dict = ( __bridge NSDictionary*) captiveNtwrkDict;
    CFRelease(interfaces);
    
    return (([dict objectForKey:@"SSID"]==nil)? informationUnknown : [dict objectForKey:@"SSID"]);
#endif
}

+(NSString*) BSSID {
#if TARGET_IPHONE_SIMULATOR
    return @"Simulator";
#else
    NSString * informationUnknown = @"unknown";
    CFArrayRef interfaces = CNCopySupportedInterfaces();
    if(interfaces == nil){
        return informationUnknown;
    }
    CFIndex count = CFArrayGetCount(interfaces);
    if(count == 0){
        return informationUnknown;
    }
    CFDictionaryRef captiveNtwrkDict =
    CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(interfaces, 0));
    NSDictionary *dict = ( __bridge NSDictionary*) captiveNtwrkDict;
    CFRelease(interfaces);
    
    return (([dict objectForKey:@"BSSID"]==nil)? informationUnknown : [dict objectForKey:@"BSSID"]);
#endif
}


+(NSDictionary*) getDataFlowBytes {
    NSString *const DataCounterKeyWWANSent = @"WWANSent";
    NSString *const DataCounterKeyWWANReceived = @"WWANReceived";
    NSString *const DataCounterKeyWiFiSent = @"WiFiSent";
    NSString *const DataCounterKeyWiFiReceived = @"WiFiReceived";
    
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    
    u_int32_t WiFiSent = 0;
    u_int32_t WiFiReceived = 0;
    u_int32_t WWANSent = 0;
    u_int32_t WWANReceived = 0;
    
    if (getifaddrs(&addrs) == 0) {
        cursor = addrs;
        while (cursor != NULL)
        {
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                /*
                 const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                 if(ifa_data != NULL)
                 {
                 NSLog(@"Interface name %s: sent %tu received %tu",cursor->ifa_name,ifa_data->ifi_obytes,ifa_data->ifi_ibytes);
                 }
                 */
                
                // name of interfaces:
                // en0 is WiFi (provides network bytes exchanges and not just internet)
                // lo0 is WiFi
                // pdp_ip0 is WWAN
                NSString *name = [NSString stringWithFormat:@"%s",cursor->ifa_name];
                if ([name hasPrefix:@"en"])
                {
                    const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                    if(ifa_data != NULL)
                    {
                        WiFiSent += ifa_data->ifi_obytes;
                        WiFiReceived += ifa_data->ifi_ibytes;
                    }
                }
                if ([name hasPrefix:@"pdp_ip"])
                {
                    const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                    if(ifa_data != NULL)
                    {
                        WWANSent += ifa_data->ifi_obytes;
                        WWANReceived += ifa_data->ifi_ibytes;
                    }
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    
    return @{DataCounterKeyWiFiSent:[NSNumber numberWithUnsignedInt:WiFiSent],
             DataCounterKeyWiFiReceived:[NSNumber numberWithUnsignedInt:WiFiReceived],
             DataCounterKeyWWANSent:[NSNumber numberWithUnsignedInt:WWANSent],
             DataCounterKeyWWANReceived:[NSNumber numberWithUnsignedInt:WWANReceived]};
}


+ (NSArray*) getAppList {
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    NSArray* app = [workspace performSelector:@selector(allApplications)];
#pragma clang diagnostic pop
    // NSLog(@"apps: %@", app);
    return app;
}

@end

