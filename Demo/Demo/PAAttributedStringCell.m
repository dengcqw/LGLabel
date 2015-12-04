//
//  PAAttributedStringCell.m
//  Demo
//
//  Created by eileen on 15/12/4.
//  Copyright © 2015年 dengjinlong. All rights reserved.
//

#import "PAAttributedStringCell.h"
#import "NSAttributedString+helper.h"
#import "LGLabel.h"
#import "UIView+MGEasyFrame.h"
//应用高度
#define APPLICATIONHEIGHT                           [[UIScreen mainScreen] applicationFrame].size.height
//应用宽度
#define APPLICATIONWIDTH                            [[UIScreen mainScreen] applicationFrame].size.width

@interface PAAttributedStringCell ()
@property (strong, nonatomic) UIImageView *houseImageView;
@property (strong, nonatomic) LGLabel *descriptionLabel;
@end

@implementation PAAttributedStringCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.houseImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 80, 75)];
        self.houseImageView.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:self.houseImageView];
        
        self.descriptionLabel = [[LGLabel alloc]initWithFrame:CGRectMake(100, 10, APPLICATIONWIDTH-100, 80)];
        self.descriptionLabel.numberOfLines = 0;  //多行显示
        self.descriptionLabel.top = self.houseImageView.top;
        self.descriptionLabel.height = self.houseImageView.height;
        self.descriptionLabel.left = self.houseImageView.right+10;
        self.descriptionLabel.width = self.width-self.houseImageView.right-10-10;
        self.descriptionLabel.attributedText = [self attributedStringInLabel];
        [self.contentView addSubview:self.descriptionLabel];
        
    }
    return self;
}

#define LineHeight @(11.5)

- (NSMutableAttributedString *)attributedStringInLabel{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]init];
    [attrStr appendString:@"花艺园" fontSize:14 color:[UIColor blackColor]];
    [attrStr appendAttrSpaceWithWidth:@(-1)];
    [attrStr appendString:@"350" font:[UIFont boldSystemFontOfSize:15] color:[UIColor orangeColor]];
    [attrStr appendString:@"万" fontSize:14 color:[UIColor blackColor]];

    [attrStr appendAttrLineWithHeight:LineHeight];
    
    [attrStr appendString:@"沪南路2668号" fontSize:13 color:[UIColor lightGrayColor]];
    
    [attrStr appendAttrLineWithHeight:LineHeight];
    
    [attrStr appendString:@"3室1厅 | 118㎡ | 4/12" fontSize:13 color:[UIColor lightGrayColor]];
    
    return attrStr;
}

- (UIImageView *)houseImageView {
    if (!_houseImageView) {
        _houseImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 100, 100)];
    }
    return _houseImageView;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
