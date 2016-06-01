//
//  FileNamePool.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/24.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileNamePool : NSObject{
    NSMutableArray *arrayCameraFileListCollection;
}

- (id)init;
+ (FileNamePool *) sharedInstance;
@end
