//
//  NSAttributedString+helper.h
//  LeGengApp
//
//  Created by DengJinlong on 10/29/15.
//  Copyright (c) 2015 LeGeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSAttributedString (helper)

// 返回对象类型和消息接收的类型相同，可以如下使用
// -[NSMutableAttributedString createWithString...]
// -[NSAttributedString createWithString...]
+ (instancetype)createWithString:(NSString *)text fontSize:(CGFloat)fontSize color:(UIColor *)color;
+ (instancetype)createWithString:(NSString *)text font:(UIFont *)font color:(UIColor *)color;
+ (instancetype)createWithString:(NSString *)text font:(UIFont *)font color:(UIColor *)color underLine:(BOOL)underLine;

// 追加属性字条串
// 如果是mutable，追加在self，并返回self
// 如果是non-mutable，创建新mutable对象，返回新对象
// 返回对象类型和消息接收的类型相同
- (instancetype)appendString:(NSString *)string fontSize:(CGFloat)fontSize color:(UIColor *)color;
- (instancetype)appendString:(NSString *)string font:(UIFont *)font color:(UIColor *)color;
- (instancetype)appendString:(NSString *)string font:(UIFont *)font color:(UIColor *)color underlined:(BOOL)underlined;

@end
