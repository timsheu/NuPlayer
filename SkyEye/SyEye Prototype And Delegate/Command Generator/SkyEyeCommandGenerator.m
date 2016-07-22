//
//  SkyEyeCommandGenerator.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/22.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "SkyEyeCommandGenerator.h"
@implementation SkyEyeCommandGenerator

/**
 *  dictionary content:
 *  key: @"Camera", value: @"Setup Camera %d" while %d is between 1~4
 *  key: @"Category", value: name saved in plist and the dictionary key is "Name"
 *  key: @"Value", value: depents on what value is going to be sent to device
 */
+ (NSString *)generateInfoCommandWithName:(NSString *)string{
    CommandPool *commandPool = [CommandPool sharedInstance];
    NSString *returnString;
    NSString *head = @"GET /";
    NSString *tail = @" HTTP/1.1\r\n\r\n";
    NSString *commandAttach = @"?command=";
    if ([string isEqualToString:@"Available Storage"]) {
        NSDictionary *dic = [commandPool.arrayInfoCommandList objectAtIndex:0];
        NSString *baseCommand = [dic objectForKey:@"Base Command"];
        NSString *subCommand = [dic objectForKey:@"Sub Command"];
        NSArray *commandArray = [NSArray arrayWithObjects:head, baseCommand, commandAttach, subCommand, tail, nil];
        returnString = [self appendHeaderString:commandArray];
    } else if ([string isEqualToString:@"Recorder Status"]){
        NSDictionary *dic = [commandPool.arrayRecordCommandList objectAtIndex:1];
        NSString *baseCommand = [dic objectForKey:@"Base Command"];
        NSString *subCommand = [dic objectForKey:@"Sub Command"];
        NSArray *commandArray = [NSArray arrayWithObjects:head, baseCommand, commandAttach, subCommand, tail, nil];
        returnString = [self appendHeaderString:commandArray];
    } else if ([string isEqualToString:@"Reboot System"]){
        NSDictionary *dic = [commandPool.arraySystemCommandList objectAtIndex:0];
        NSString *baseCommand = [dic objectForKey:@"Base Command"];
        NSArray *commandArray = [NSArray arrayWithObjects:head, baseCommand, tail, nil];
        returnString = [self appendHeaderString:commandArray];
    } else if ([string isEqualToString:@"Snapshot"]){
        NSDictionary *dic = [commandPool.arrayRecordCommandList objectAtIndex:0];
        NSString *baseCommand = [dic objectForKey:@"Base Command"];
        NSString *subCommand = [dic objectForKey:@"Sub Command"];
        NSArray *commandArray = [NSArray arrayWithObjects:head, baseCommand, commandAttach, subCommand, tail, nil];
        returnString = [self appendHeaderString:commandArray];
    } else if ([string isEqualToString:@"Get Resolution"]){
        NSDictionary *dic = [commandPool.arrayVideoCommandList objectAtIndex:2];
        NSString *baseCommand = [dic objectForKey:@"Base Command"];
        NSString *subCommand = [dic objectForKey:@"Sub Command"];
        NSArray *commandArray = [NSArray arrayWithObjects:head, baseCommand, commandAttach, subCommand, tail, nil];
        returnString = [self appendHeaderString:commandArray];
    } else if ([string isEqualToString:@"Get MAX FPS"]){
        NSDictionary *dic = [commandPool.arrayVideoCommandList objectAtIndex:8];
        NSString *baseCommand = [dic objectForKey:@"Base Command"];
        NSString *subCommand = [dic objectForKey:@"Sub Command"];
        NSArray *commandArray = [NSArray arrayWithObjects:head, baseCommand, commandAttach, subCommand, tail, nil];
        returnString = [self appendHeaderString:commandArray];
    } else if ([string isEqualToString:@"Get Encode Quality"]){
        NSDictionary *dic = [commandPool.arrayVideoCommandList objectAtIndex:4];
        NSString *baseCommand = [dic objectForKey:@"Base Command"];
        NSString *subCommand = [dic objectForKey:@"Sub Command"];
        NSArray *commandArray = [NSArray arrayWithObjects:head, baseCommand, commandAttach, subCommand, tail, nil];
        returnString = [self appendHeaderString:commandArray];
    } else if ([string isEqualToString:@"Get Encode BitRate"]){
        NSDictionary *dic = [commandPool.arrayVideoCommandList objectAtIndex:6];
        NSString *baseCommand = [dic objectForKey:@"Base Command"];
        NSString *subCommand = [dic objectForKey:@"Sub Command"];
        NSArray *commandArray = [NSArray arrayWithObjects:head, baseCommand, commandAttach, subCommand, tail, nil];
        returnString = [self appendHeaderString:commandArray];
    } else if ([string isEqualToString:@""]){
        
    }
    return returnString;
}
+ (NSString *)generateSettingCommandWithDictionary:(NSDictionary *)dictionary{
    CommandPool *commandPool = [CommandPool sharedInstance];
    NSString *subCommandAttach = @"?command=";
    NSString *subCommandKey = @"Sub Command";
    NSString *category = [NSString stringWithString:[dictionary objectForKey:@"Category"]];
    NSString *value = [NSString stringWithString:[dictionary objectForKey:@"Value"]];
    NSString *andString = @"&", *equalString = @"=", *valueString = @"value", *questionString = @"\?";
    NSString *generatedCommand = @"";
    if ([category isEqualToString:@"Resolution"]) { // set resolution
        for (NSDictionary *dic in commandPool.arrayVideoCommandList) {
            NSString *commandName = [dic objectForKey:@"Name"];
            if ([commandName isEqualToString:@"Set Resolution"]) {
                NSString *string = [NSString stringWithString:[dic objectForKey:@"Base Command"]];
                generatedCommand = [NSString stringWithString:string];
                generatedCommand = [generatedCommand stringByAppendingString:subCommandAttach];
                generatedCommand = [generatedCommand stringByAppendingString:[dic objectForKey:subCommandKey]];
                generatedCommand = [generatedCommand stringByAppendingString:andString];
                generatedCommand = [generatedCommand stringByAppendingString:valueString];
                generatedCommand = [generatedCommand stringByAppendingString:equalString];
                generatedCommand = [generatedCommand stringByAppendingString:value];
                break;
            }
        }
    } else if ([category isEqualToString:@"Encode Quality"]) { // set encode quality
        for (NSDictionary *dic in commandPool.arrayVideoCommandList) {
            NSString *commandName = [dic objectForKey:@"Name"];
            if ([commandName isEqualToString:@"Set Encode Quality"]) {
                NSString *string = [NSString stringWithString:[dic objectForKey:@"Base Command"]];
                generatedCommand = [NSString stringWithString:string];
                generatedCommand = [generatedCommand stringByAppendingString:subCommandAttach];
                generatedCommand = [generatedCommand stringByAppendingString:[dic objectForKey:subCommandKey]];
                generatedCommand = [generatedCommand stringByAppendingString:andString];
                generatedCommand = [generatedCommand stringByAppendingString:valueString];
                generatedCommand = [generatedCommand stringByAppendingString:equalString];
                generatedCommand = [generatedCommand stringByAppendingString:value];
                break;
            }
        }
    } else if ([category isEqualToString:@"Bit Rate"]) { // set encode bitrate
        for (NSDictionary *dic in commandPool.arrayVideoCommandList) {
            NSString *commandName = [dic objectForKey:@"Name"];
            if ([commandName isEqualToString:@"Set Encode Bitrate"]) {
                NSString *string = [NSString stringWithString:[dic objectForKey:@"Base Command"]];
                generatedCommand = [NSString stringWithString:string];
                generatedCommand = [generatedCommand stringByAppendingString:subCommandAttach];
                generatedCommand = [generatedCommand stringByAppendingString:[dic objectForKey:subCommandKey]];
                generatedCommand = [generatedCommand stringByAppendingString:andString];
                generatedCommand = [generatedCommand stringByAppendingString:valueString];
                generatedCommand = [generatedCommand stringByAppendingString:equalString];
                generatedCommand = [generatedCommand stringByAppendingString:value];
                break;
            }
        }
    } else if ([category isEqualToString:@"FPS"]) { // set FPS
        for (NSDictionary *dic in commandPool.arrayVideoCommandList) {
            NSString *commandName = [dic objectForKey:@"Name"];
            if ([commandName isEqualToString:@"Set MAX FPS"]) {
                NSString *string = [NSString stringWithString:[dic objectForKey:@"Base Command"]];
                generatedCommand = [NSString stringWithString:string];
                generatedCommand = [generatedCommand stringByAppendingString:subCommandAttach];
                generatedCommand = [generatedCommand stringByAppendingString:[dic objectForKey:subCommandKey]];
                generatedCommand = [generatedCommand stringByAppendingString:andString];
                generatedCommand = [generatedCommand stringByAppendingString:valueString];
                generatedCommand = [generatedCommand stringByAppendingString:equalString];
                generatedCommand = [generatedCommand stringByAppendingString:value];
                break;
            }
        }
    } else if ([category isEqualToString:@"Device Mic"]) { // Device Mic Mute
        for (NSDictionary *dic in commandPool.arrayAudioCommandList) {
            NSString *commandName = [dic objectForKey:@"Name"];
            if ([commandName isEqualToString:@"Audio Mute"]) {
                NSString *string = [NSString stringWithString:[dic objectForKey:@"Base Command"]];
                generatedCommand = [NSString stringWithString:string];
                generatedCommand = [generatedCommand stringByAppendingString:subCommandAttach];
                generatedCommand = [generatedCommand stringByAppendingString:[dic objectForKey:subCommandKey]];
                generatedCommand = [generatedCommand stringByAppendingString:andString];
                generatedCommand = [generatedCommand stringByAppendingString:valueString];
                generatedCommand = [generatedCommand stringByAppendingString:equalString];
                generatedCommand = [generatedCommand stringByAppendingString:value];
                break;
            }
        }
    } else if ([category isEqualToString:@"Download File List"]) { // Download File List
        for (NSDictionary *dic in commandPool.arrayFileCommandList) {
            NSString *commandName = [dic objectForKey:@"Name"];
            if ([commandName isEqualToString:@"Download File List"]) {
                NSString *string = [NSString stringWithString:[dic objectForKey:@"Base Command"]];
                NSArray *commandArray = [NSArray arrayWithObjects:string, questionString, @"action", equalString, [dic objectForKey:@"action"], andString, @"group", equalString, [dic objectForKey:@"group"], nil];
                for (NSString *s in commandArray) {
                    generatedCommand = [generatedCommand stringByAppendingString:s];
                }
                break;
            }
        }
    }
    NSString *finalCommand = @"GET /";
    NSArray *array = [NSArray arrayWithObjects:finalCommand, generatedCommand, @" HTTP/1.1\r\n\r\n", nil];
    
    return [self appendHeaderString:array];
}

+ (NSString *)generateUpdatePluginCommand:(NSString *)string withParameter:(NSString *)param withValue:(NSString *)value{
    NSString *baseCommand = @"param.cgi?action=update&group=plugin";
    NSString *head = @"GET /";
    NSString *tail = @" HTTP/1.1\r\n\r\n";
    NSArray *array = [NSArray arrayWithObjects:head, baseCommand, @"&name=", string, @"&param=", param, @"&value=", value, tail, nil];
    return [self appendHeaderString:array];
}

+ (NSData *)generateUploadAudioCommand:(NSData *)audioData sampleRate:(int)sampleRate channel:(int)channel volume:(int)volume{
//    DDLogDebug(@"generate, %@", audioData);
    NSString *baseCommand = @"audio.input";
    NSString *srString = [NSString stringWithFormat:@"&samplerate=%d", sampleRate];
    NSString *chString = [NSString stringWithFormat:@"&channel=%d", channel];
    NSString *vlString = [NSString stringWithFormat:@"&volume=%d", volume];
    NSString *head = @"GET /";
    NSString *tail = @" HTTP/1.1\r\n";
    NSString *host = [NSString stringWithFormat:@"Host: 0.0.0.0\r\n"]; // the skyeye does not parse this host address, put it dummy
    NSString *contentType = @"Content-Type: audio/wav\r\n";
    NSString *contentLength = [NSString stringWithFormat:@"Content-Length: %d\r\n\r\n", (int)audioData.length];
    NSArray *array = [NSArray arrayWithObjects:
                      [head dataUsingEncoding:NSUTF8StringEncoding],
                      [baseCommand dataUsingEncoding:NSUTF8StringEncoding],
                      [srString dataUsingEncoding:NSUTF8StringEncoding],
                      [chString dataUsingEncoding:NSUTF8StringEncoding],
                      [vlString dataUsingEncoding:NSUTF8StringEncoding],
                      [tail dataUsingEncoding:NSUTF8StringEncoding],
                      [host dataUsingEncoding:NSUTF8StringEncoding],
                      [contentType dataUsingEncoding:NSUTF8StringEncoding],
                      [contentLength dataUsingEncoding:NSUTF8StringEncoding],
                      audioData, nil];
    return [self appendHeaderData:array];
}

+ (NSData *)generateContinousAudioCommand:(int)sampleRate channel:(int)channel volume:(int)volume{
    //    DDLogDebug(@"generate, %@", audioData);
    NSString *baseCommand = @"audio.input";
    NSString *ptString = @"?protocol=tcp";
    NSString *srString = [NSString stringWithFormat:@"&samplerate=%d", sampleRate];
    NSString *chString = [NSString stringWithFormat:@"&channel=%d", channel];
    NSString *vlString = [NSString stringWithFormat:@"&volume=%d", volume];
    NSString *prString = @"&port=8080";
    NSString *head = @"GET /";
    NSString *tail = @" HTTP/1.1\r\n\r\n";
    NSArray *array = [NSArray arrayWithObjects:
                      [head dataUsingEncoding:NSUTF8StringEncoding],
                      [baseCommand dataUsingEncoding:NSUTF8StringEncoding],
                      [ptString dataUsingEncoding:NSUTF8StringEncoding],
                      [srString dataUsingEncoding:NSUTF8StringEncoding],
                      [chString dataUsingEncoding:NSUTF8StringEncoding],
                      [vlString dataUsingEncoding:NSUTF8StringEncoding],
                      [prString dataUsingEncoding:NSUTF8StringEncoding],
                      [tail dataUsingEncoding:NSUTF8StringEncoding],
                      nil];
    return [self appendHeaderData:array];
}


+ (NSData *)appendHeaderData:(NSArray *)array{
    NSMutableData *returnData = [[NSMutableData alloc]init];
    for (NSData *d in array) {
        [returnData appendData:d];
    }
    return returnData;
}

+ (NSString *)appendHeaderString:(NSArray *)array{
    NSString *returnString = @"";
    for (NSString *s in array) {
        returnString = [returnString stringByAppendingString:s];
        DDLogDebug(@"apped string, %@", s);
    }
    return returnString;
}

+ (NSMutableData *)appendHeaderString:(NSArray *)array withAudioData:(NSData *)audioData{
    NSString *returnString = @"";
    for (NSString *s in array) {
        returnString = [returnString stringByAppendingString:s];
    }
    NSMutableData *returnData = [NSMutableData dataWithData:[returnString dataUsingEncoding:NSUTF8StringEncoding]];
    [returnData appendData:audioData];
    return returnData;
}
@end
