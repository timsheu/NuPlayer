//
//  DVRRecieveDataParser.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/3/9.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "DVRRecieveDataParser.h"

@implementation DVRRecieveDataParser
+(NSDictionary *)parseSocketReadData:(NSData *)data withTag:(int)tag{
    NSDictionary *parsedDic;
    NSString *type, *value, *category;
    NSString *dataInString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *dataSplitWithCRLF = [dataInString componentsSeparatedByString:@"\r\n"];
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    if ([[dataSplitWithCRLF objectAtIndex:0] isEqualToString:@"HTTP/1.1 200 OK"]) {
        for (int i=8; i<dataSplitWithCRLF.count; i++) {
            NSString *s = [dataSplitWithCRLF objectAtIndex:i];
            [dataContent addObject:s];
        }
    } else {
        for (int i=0; i<dataSplitWithCRLF.count; i++) {
            NSString *s = [dataSplitWithCRLF objectAtIndex:i];
            [dataContent addObject:s];
        }
    }
    
    NSDictionary *dic;
    for (NSString *s in dataContent) {
        if ([s isEqualToString:@""]) {
            continue;
        }
        NSData *d = [s dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:d options:kNilOptions error:nil];
    }
    if (dic == nil) {
        parsedDic = [NSDictionary dictionaryWithObjectsAndKeys:@"no data", @"type", nil];
        return parsedDic;
    }
    
    switch (tag) {
        case SOCKET_READ_TAG_STATUS_MAX_FPS:
            category = @"GET FPS";
            type = @"JSON DATA";
            break;
        case SOCKET_READ_TAG_STATUS_RESOLUTION:
            category = @"GET Resolution";
            type = @"JSON DATA";
            break;
        case SOCKET_READ_TAG_STATUS_ENCODE_BITRATE:
            category = @"GET Bit Rate";
            type = @"JSON DATA";
            break;
        case SOCKET_READ_TAG_STATUS_ENCODE_QUALITY:
            category = @"GET Encode Quality";
            type = @"JSON DATA";
            break;
        default:
            break;
    }
    value = [dic objectForKey:@"value"];
    parsedDic = [NSDictionary dictionaryWithObjectsAndKeys:type, @"type", dic, @"json", category, @"category", nil];
    return parsedDic;
}

@end
