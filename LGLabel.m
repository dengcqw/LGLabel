//
//  LGLabel.m
//  LeGengApp
//
//  Created by DengJinlong on 5/3/15.
//  Copyright (c) 2015 LeGeng. All rights reserved.
//

#import "LGLabel.h"

// 这两个属性不公开，应该他们会插入空格，改变原字符的长度。请NSAttributedString (LGLabel)分类中的方法。
NSString * const NSSpaceWidthAttributeName  = @"com.LGLabel.spaceWidth";
NSString * const NSLineHeightAttributeName  = @"com.LGLabel.lineHeight";

NSString * const NSVerticalAlignAttributeName= @"com.LGLabel.verticalAlignment";

NSString * const NSViewAttributeName        = @"com.LGLabel.view";
NSString * const NSViewOffsetAttributeName  = @"com.LGLabel.viewOffset";

#define BB_IOS7_OR_LATER	( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )

NSAttributedString *LGAttributedSpace(NSNumber *kern, NSNumber *space) {
    return [[NSAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:1],NSKernAttributeName:kern, NSSpaceWidthAttributeName:space}];
}

NSAttributedString *LGAttributedLine(NSNumber *paraLineSpace, NSNumber *lineSpace) {
    NSMutableParagraphStyle *para = [NSMutableParagraphStyle new];
    para.lineSpacing = paraLineSpace.floatValue;
    return [[NSAttributedString alloc] initWithString:@"\n \n" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:1],NSParagraphStyleAttributeName:para, NSLineHeightAttributeName:lineSpace}];
}

NSAttributedString *LGAttributedView(UIView *view, NSNumber *offset) {
    return [[NSMutableAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:1],NSKernAttributeName:@(view.bounds.size.width), NSViewAttributeName:view, NSViewOffsetAttributeName:offset}];
}

@interface LGLabel ()
@property (assign, nonatomic) CGRect cacheFrame;
@end

@implementation LGLabel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentMode = UIViewContentModeRedraw;
        NSAssert(BB_IOS7_OR_LATER,@"class LGVerticalAlignmentLabel only support iOS7 and later");
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (NSAttributedString *)adjustSpaceWidthIfNeed:(NSAttributedString *)attributedText {
    NSRange range = NSMakeRange(0, attributedText.length);
    __block NSMutableAttributedString *tempMutableAttrStr = nil;
    
    [attributedText enumerateAttribute:NSSpaceWidthAttributeName
                               inRange:range
                               options:(NSAttributedStringEnumerationLongestEffectiveRangeNotRequired)
                            usingBlock:^(NSNumber *value, NSRange range, BOOL *stop) {
                                
        if (value && [value isKindOfClass:[NSNumber class]]) {
            if (tempMutableAttrStr == nil) {
                tempMutableAttrStr = [attributedText mutableCopy];
            }
            // check if need adjust space
            if (value.floatValue < 0) {
                NSNumber *insertSpace;
                NSUInteger spaceLenght = 1;
                // cut head and tail string
                NSAttributedString *headStr = [tempMutableAttrStr attributedSubstringFromRange:NSMakeRange(0, range.location)];
                NSAttributedString *tailStr = [tempMutableAttrStr attributedSubstringFromRange:NSMakeRange(range.location+1, tempMutableAttrStr.length-headStr.length-spaceLenght)];
                CGFloat spaceWidth = 0.3;//LGAttributedSpace(@0, @0).size.width;
                
                // search '\n'
                NSRange lineBreakCharRange;
                lineBreakCharRange = [headStr.string rangeOfString:@"\n" options:(NSBackwardsSearch)];
                if (lineBreakCharRange.length > 0) {
                    headStr = [headStr attributedSubstringFromRange:NSMakeRange(lineBreakCharRange.location+1, headStr.length-lineBreakCharRange.location-1/* "\n" */)];
                }
                lineBreakCharRange = [tailStr.string rangeOfString:@"\n"];
                if (lineBreakCharRange.length > 0) {
                    tailStr = [tailStr attributedSubstringFromRange:NSMakeRange(0, lineBreakCharRange.location)];
                }
                
                insertSpace = @(self.frame.size.width - headStr.size.width - tailStr.size.width-spaceWidth-0.5/*safe threshold*/);
                [tempMutableAttrStr replaceCharactersInRange:range withAttributedString:LGAttributedSpace(insertSpace, value)];
                NSLog(@"attributedString insert space (%@ point) at range:%@",insertSpace, NSStringFromRange(range));
            }
        }
    }];
    return (tempMutableAttrStr ? tempMutableAttrStr.copy : attributedText);
}

- (NSAttributedString *)adjustLineLightIfNeed:(NSAttributedString *)attributedText {
    NSRange range = NSMakeRange(0, attributedText.length);
    __block NSMutableAttributedString *tempMutableAttrStr = nil;
    
    [attributedText enumerateAttribute:NSLineHeightAttributeName
                               inRange:range
                               options:(NSAttributedStringEnumerationLongestEffectiveRangeNotRequired)
                            usingBlock:^(NSNumber *value, NSRange range, BOOL *stop) {
                                
        if (value && [value isKindOfClass:[NSNumber class]]) {
            if (tempMutableAttrStr == nil) {
                tempMutableAttrStr = [attributedText mutableCopy];
            }
            if (value.floatValue < 0) {
                NSNumber *paraLineSpace;
                NSUInteger lineLength = range.length;
                // cut head and tail string
                NSAttributedString *headStr = [tempMutableAttrStr attributedSubstringFromRange:NSMakeRange(0, range.location)];
                NSAttributedString *tailStr = [tempMutableAttrStr attributedSubstringFromRange:NSMakeRange(range.location+lineLength, tempMutableAttrStr.length-headStr.length-lineLength)];
                
                CGFloat headStrHeight = headStr.size.height;
                CGFloat tailStrHeight = tailStr.size.height;
                CGFloat lineHeight = 3.0f;//LGAttributedLine(@0, @0).size.height;
                
                paraLineSpace = @(self.frame.size.height - headStrHeight - tailStrHeight - lineHeight-0.5/*safe threshold*/);
                [tempMutableAttrStr replaceCharactersInRange:range withAttributedString:LGAttributedLine(paraLineSpace, value)];
                NSLog(@"attributedString insert paragraph space (%@ point) at range:%@",paraLineSpace, NSStringFromRange(range));
                *stop = YES;
            }
        }
    }];
    return (tempMutableAttrStr ? tempMutableAttrStr.copy : attributedText);
}

- (void)adjustViewFrameIfNeed:(CGRect)drawInRect {
    NSAttributedString *tempMutableAttrStr = self.attributedText;
    NSRange allRange = NSMakeRange(0, tempMutableAttrStr.length);
    [self.attributedText enumerateAttribute:NSViewAttributeName inRange:allRange options:(NSAttributedStringEnumerationLongestEffectiveRangeNotRequired) usingBlock:^(UIView *view, NSRange range, BOOL *stop) {
        if (view && [view isKindOfClass:[UIView class]]) {
            if (view.superview != self) {
                [self addSubview:view];
            }
            id offsetValue = [tempMutableAttrStr attribute:NSViewOffsetAttributeName atIndex:range.location effectiveRange:&range];
#if DEBUG
            NSAssert(offsetValue,@"NSViewOffsetAttributeName is nil. That is imposable");
#endif
            CGFloat offset = [offsetValue isKindOfClass:[NSNumber class]]?[(NSNumber *)offsetValue floatValue]:0;
            
            // 插入view位置之前的attributed string，用于计算高度，相对y坐标
            NSAttributedString *headStr = [tempMutableAttrStr attributedSubstringFromRange:NSMakeRange(0, range.location)];
            // search '\n'
            NSRange lineBreakCharRange;
            NSAttributedString *strInSameLine = headStr;
            lineBreakCharRange = [headStr.string rangeOfString:@"\n" options:(NSBackwardsSearch)];
            if (lineBreakCharRange.length > 0) {
                // 与view同行的attributed string，用于计算宽度，相对y坐标
                strInSameLine = [headStr attributedSubstringFromRange:NSMakeRange(lineBreakCharRange.location+1, headStr.length-lineBreakCharRange.location-1/* "\n" */)];
            }
            CGFloat hStr = headStr.size.height;
            CGFloat hView = view.frame.size.height;
            CGFloat hStrInsameLine = strInSameLine.size.height;
            
            CGFloat xPos, yPos;
            yPos = hStr - (hStrInsameLine+hView)/2 + drawInRect.origin.y;
            xPos = strInSameLine.size.width + drawInRect.origin.x;
            
            view.frame =  (CGRect){ .origin={xPos, yPos+offset},
                                    .size=view.frame.size};
            NSLog(@"attributedString insert image at (%@ )", NSStringFromCGRect(view.frame));
        }
    }];
}

- (NSAttributedString *)adjustVerticalAlignmentIfNeed:(NSAttributedString *)attributedText {
    __block NSRange allRange = NSMakeRange(0, attributedText.length);
    __block NSMutableAttributedString *tempMutableAttrStr = nil;
    
    [attributedText enumerateAttribute:NSVerticalAlignAttributeName
                               inRange:allRange
                               options:(NSAttributedStringEnumerationLongestEffectiveRangeNotRequired)
                            usingBlock:^(NSNumber *value, NSRange range, BOOL *stop) {
                                
        if (value && [value isKindOfClass:[NSValue class]]) {
            if (tempMutableAttrStr == nil) {
                tempMutableAttrStr = [attributedText mutableCopy];
            }
            NSUInteger i;
            for (i = range.location-1; i > 0; i--) { // align with ahead non blank char
                unichar nonBlankChar = [tempMutableAttrStr.string characterAtIndex:i];
                if (nonBlankChar != ' ') {
                    break;
                }
            }
            NSRange aheadRange = NSMakeRange(0, i);
            UIFont *aheadCharFont = [tempMutableAttrStr attribute:NSFontAttributeName atIndex:i effectiveRange:&aheadRange];
            UIFont *currentFont = [tempMutableAttrStr attribute:NSFontAttributeName atIndex:range.location effectiveRange:&range];
            
            NSMutableAttributedString *currentStr = [[tempMutableAttrStr attributedSubstringFromRange:range] mutableCopy];
            CGFloat adjustOffset = 0.0f;
            
            // 测量大小间隔为4的"天"字，字型为HelveticaNeue，基线对齐，得出下面结果
            CGFloat scale = [UIScreen mainScreen].scale;
            CGFloat unitFont_4 = (aheadCharFont.pointSize-currentFont.pointSize)/4;
            CGFloat deltAscenderPixel = unitFont_4 * 6; // 大小相差4的文字顶部间距是6pixel
            CGFloat deltBottomToBaseLinePixel = unitFont_4 * 1;// 大小相差4的文字顶部间距是1pixel
            
            LGVerticalAlignment alignment = value.integerValue;
            switch (alignment) {
                case LGVerticalAlignmentTop: {
                    CGFloat deltAscenderPoint = deltAscenderPixel/scale;
                    adjustOffset = deltAscenderPoint; // 相对向上移动
                }
                    break;
                case LGVerticalAlignmentCenter: {
                    CGFloat medianToBaseLine_1 = aheadCharFont.xHeight;
                    CGFloat medianToBaseLine_2 = currentFont.xHeight;
                    adjustOffset = (medianToBaseLine_1 - medianToBaseLine_2)/2;
                }
                    break;
                case LGVerticalAlignmentBottom: {
                    CGFloat deltBottomToBaseLinePoint = deltBottomToBaseLinePixel/scale;
                    adjustOffset = -deltBottomToBaseLinePoint; // 相对向下移动
                }
                    break;
                default:
                    break;
            }
            [currentStr addAttribute:NSBaselineOffsetAttributeName value:@(adjustOffset) range:NSMakeRange(0, currentStr.length)];
            [tempMutableAttrStr replaceCharactersInRange:range withAttributedString:currentStr.copy];
            NSLog(@"attributedString vertical alignment adjust (%@)offset at range:%@", @(adjustOffset), NSStringFromRange(range));
        }
    }];
    return (tempMutableAttrStr ? tempMutableAttrStr.copy : attributedText);
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    
    CGSize textSize = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines].size;
    
    CGFloat xPos = 0; // NSTextAlignmentLeft
    if (self.textAlignment == NSTextAlignmentCenter) {
        xPos = (bounds.size.width - textSize.width)/2;
    } else if (self.textAlignment == NSTextAlignmentRight) {
        xPos = bounds.size.width - textSize.width;
    }
    
    if (self.verticalAlignment == LGVerticalAlignmentTop) {
        return CGRectMake(xPos, 0, (textSize.width), (textSize.height));
    } else if (self.verticalAlignment == LGVerticalAlignmentBottom) {
        return CGRectMake(xPos, (bounds.size.height-textSize.height), (textSize.width), (textSize.height));
    } else {
        return CGRectMake(xPos, (bounds.size.height-textSize.height)/2, textSize.width, textSize.height);
    }
}

- (void)drawTextInRect:(CGRect)rect {
    if (self.attributedText && !CGRectEqualToRect(self.cacheFrame, self.frame)) {
        self.cacheFrame = self.frame;
        NSAttributedString * tmpAttrStr = [self adjustSpaceWidthIfNeed:self.attributedText];
        tmpAttrStr = [self adjustLineLightIfNeed:tmpAttrStr];
        tmpAttrStr = [self adjustVerticalAlignmentIfNeed:tmpAttrStr];
        self.attributedText = tmpAttrStr;
        //NSLog(@"attri size:%@",NSStringFromCGSize(self.attributedText.size));
    }
    //NSLog(@"original rect:%@",NSStringFromCGRect(rect));
    CGRect r = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
    [self adjustViewFrameIfNeed:r];
    //NSLog(@"after rect:%@",NSStringFromCGRect(r));
    [super drawTextInRect:r];
}

@end

@implementation NSAttributedString (LGLabel)

+ (NSAttributedString *)attrSpaceWithWidth:(NSNumber *)widthInPoint {
    return LGAttributedSpace(widthInPoint, widthInPoint);
}

+ (NSAttributedString *)attrLineWithHeight:(NSNumber *)heightInPoint {
    return LGAttributedLine(heightInPoint, heightInPoint);
}

+ (NSAttributedString *)attrStringWithView:(UIView *)view {
    return LGAttributedView(view, @0);
}

+ (NSAttributedString *)attrStringWithView:(UIView *)view offset:(CGFloat)offset {
    return LGAttributedView(view, @(offset));
}

@end

@implementation NSMutableAttributedString (LGLabel)

- (NSMutableAttributedString *)appendAttrSpaceWithWidth:(NSNumber *)widthInPoint {
    NSAttributedString *attrSpace = [NSAttributedString attrSpaceWithWidth:widthInPoint];
    [self appendAttributedString:attrSpace];
    return self;
}
- (NSMutableAttributedString *)appendAttrLineWithHeight:(NSNumber *)heightInPoint {
    NSAttributedString *attrLine = [NSAttributedString attrLineWithHeight:heightInPoint];
    [self appendAttributedString:attrLine];
    return self;
}
- (NSMutableAttributedString *)appendAttrStringWithView:(UIView *)view {
    NSAttributedString *attrView = [NSAttributedString attrStringWithView:view];
    [self appendAttributedString:attrView];
    return self;
}

@end
         
