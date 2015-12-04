//
//  NSAttributedString+helper.m
//  LeGengApp
//
//  Created by DengJinlong on 10/29/15.
//  Copyright (c) 2015 LeGeng. All rights reserved.
//

#import "NSAttributedString+helper.h"

@implementation NSAttributedString (helper)

#pragma mark - create attr string

+ (instancetype)createWithString:(NSString *)text fontSize:(CGFloat)fontSize color:(UIColor *)color {
    return [[self class] createWithString:text font:[UIFont systemFontOfSize:fontSize] color:color underLine:NO];
}

+ (instancetype)createWithString:(NSString *)text font:(UIFont *)font color:(UIColor *)color {
    return [[self class] createWithString:text font:font color:color underLine:NO];
}

+ (instancetype)createWithString:(NSString *)text font:(UIFont *)font color:(UIColor *)color underLine:(BOOL)underLine {
    NSString *receiveText = text?:@"";
    
    NSDictionary *attrDic = @{NSFontAttributeName: font,
                              NSForegroundColorAttributeName: color,
                              NSUnderlineStyleAttributeName: @(underLine)
                              };
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:receiveText attributes:attrDic];
    if ([[self class] isSubclassOfClass:[NSMutableAttributedString class]]) {
        return [attrString mutableCopy];
    } else {
        return attrString;
    }
}

#pragma mark - append attr string

- (instancetype)appendString:(NSString *)string fontSize:(CGFloat)fontSize color:(UIColor *)color {
    return [self appendString:string font:[UIFont systemFontOfSize:fontSize] color:color underlined:NO];
}

- (instancetype)appendString:(NSString *)string font:(UIFont *)font color:(UIColor *)color {
    return [self appendString:string font:font color:color underlined:NO];
}

- (instancetype)appendString:(NSString *)string font:(UIFont *)font color:(UIColor *)color underlined:(BOOL)underlined {
    
    id attrString = [[self class] createWithString:string font:font color:color underLine:underlined];
    BOOL isMutable = [[self class] isSubclassOfClass:[NSMutableAttributedString class]];
    
    NSMutableAttributedString *mutableAttrStr = isMutable ? self : [self mutableCopy];
    [mutableAttrStr appendAttributedString:attrString];
    return [isMutable ?mutableAttrStr:mutableAttrStr copy];
}

@end
