//
//  ZLMusicFlowDecorativeView.m
//  ZLMusicFlowWaveViewDemo
//
//  Created by Zhixuan Lai on 11/17/14.
//  Copyright (c) 2014 Zhixuan Lai. All rights reserved.
//

#import "ZLMusicFlowDecorativeView.h"

@implementation ZLMusicFlowDecorativeView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.shadowRadius = 5;
        self.layer.shadowOffset = CGSizeMake(5, 5);
        
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor* color = [UIColor colorWithRed: 1.0 green: 1.0 blue: 1.0 alpha: 1];
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect))];
    CGContextSaveGState(context);
    [color setFill];
    [ovalPath fill];
    CGContextRestoreGState(context);
}
@end
