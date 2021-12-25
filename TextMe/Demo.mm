//
//  Demo.m
//  Guys!
//
//  Created by SARFO KANTANKA FRIMPONG on 7/21/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import "Demo.h"

@implementation Demo

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    m_skip=[[UIButton alloc]initWithFrame:CGRectMake(frame.size.width-90,frame.size.height-90, 70, 70)];
    m_next=[[UIButton alloc]initWithFrame:CGRectMake(frame.size.width-90,frame.size.height-90, 70, 70)];
    [self addSubview:m_skip];
    
    m_imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0,frame.size.height-90, frame.size.width,frame.size.height-70)];
    [self addSubview:m_imageView];
    return self;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
