//
//  LGLabel.h
//  LeGengApp
//
//  Created by DengJinlong on 5/3/15.
//  Copyright (c) 2015 LeGeng. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, LGVerticalAlignment) {
    LGVerticalAlignmentCenter  = 0,
    LGVerticalAlignmentTop     = 1,
    LGVerticalAlignmentBottom  = 2,
};

/*!
 @brief  使用此属性汉字，会与之前非空字符比较，按LGVerticalAlignment调整base line offset
         对汉子对齐有效。如果是字母数据，使用font高度属性手动调整base line offset
 */
extern NSString * const NSVerticalAlignAttributeName;


@interface LGLabel : UILabel

@property (nonatomic, assign) LGVerticalAlignment verticalAlignment; //default is LGVerticalAlignmentCenter

@end

@interface NSAttributedString (LGLabel)

/*!
 @brief  插入指定宽度的空格，length为1，
         如果值为负数，则插入一定间隔，使空白后内容显示在当前行边界
 @param  widthInPoint 会设置空格的kern属性
 @return 返回带属性的空格
 
 @note  如果前后两段字符长度超过label width，则此属性无效。
        只支持手动换行（\n)，不支持label自动换行。
 */
+ (NSAttributedString *)attrSpaceWithWidth:(NSNumber *)widthInPoint;

/*!
 @brief  插入指定高度的空行，字符为"\n \n"，length为3，
         如果值为负数，则插入一定间隔，使空行后内容显示在底部边界
 */
+ (NSAttributedString *)attrLineWithHeight:(NSNumber *)heightInPoint;

/*!
 @brief  在指定位置插入view，默认居中对齐，
 @param view 需要插入的view
 @param offset 用于控制上下偏移
 @return 带view属性的空格字符
 
 @note  view的大小自己控制
 */
+ (NSAttributedString *)attrStringWithView:(UIView *)view offset:(CGFloat)offset;
+ (NSAttributedString *)attrStringWithView:(UIView *)view;

@end

@interface NSMutableAttributedString (LGLabel)
// return self
- (NSMutableAttributedString *)appendAttrSpaceWithWidth:(NSNumber *)widthInPoint;
- (NSMutableAttributedString *)appendAttrLineWithHeight:(NSNumber *)heightInPoint;
- (NSMutableAttributedString *)appendAttrStringWithView:(UIView *)view; 
@end


