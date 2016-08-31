
//
//  ESPUIUtil.m
//  suite
//
//  Created by 白 桦 on 5/18/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPUIUtil.h"


@implementation ESPUIUtil

+(CGSize) boundingRectWithSize:(NSString*) txt Font:(UIFont*) font Size:(CGSize) size{
    
    CGSize _size;
    
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    
    NSDictionary *attribute = @{NSFontAttributeName: font};
    
    NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine |
    
    NSStringDrawingUsesLineFragmentOrigin |
    
    NSStringDrawingUsesFontLeading;
    
    _size = [txt boundingRectWithSize:size options: options attributes:attribute context:nil].size;
    
#else
    
    _size = [txt sizeWithFont:font constrainedToSize:size];
    
#endif
    
    return _size;
    
}

@end
