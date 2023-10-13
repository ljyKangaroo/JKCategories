//
//  UIView+JKScreenshot.m
//  JKCategories (https://github.com/shaojiankui/JKCategories)
//
//  Created by Jakey on 15/1/10.
//  Copyright (c) 2015年 www.skyfox.org. All rights reserved.
//

#import "UIView+JKScreenshot.h"
#import <QuartzCore/QuartzCore.h>
@implementation UIView (JKScreenshot)
/**
 *  @brief  view截图
 *
 *  @return 截图
 */
- (UIImage *)jk_screenshot {

    UIGraphicsImageRendererFormat *rendererFormat = [[UIGraphicsImageRendererFormat alloc] init];
    rendererFormat.scale = [UIScreen mainScreen].scale;
    rendererFormat.opaque = NO;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.bounds.size format:rendererFormat];
    UIImage *screenshot = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    }];
    return screenshot;
}
/**
 *  @author Jakey
 *
 *  @brief  截图一个view中所有视图 包括旋转缩放效果
 *
 *  @param maxWidth 限制缩放的最大宽度 保持默认传0
 *
 *  @return 截图
 */
- (UIImage *)jk_screenshot:(CGFloat)maxWidth{
    CGAffineTransform oldTransform = self.transform;
    CGAffineTransform scaleTransform = CGAffineTransformIdentity;
    
//    if (!isnan(scale)) {
//        CGAffineTransform transformScale = CGAffineTransformMakeScale(scale, scale);
//        scaleTransform = CGAffineTransformConcat(oldTransform, transformScale);
//    }
    if (!isnan(maxWidth) && maxWidth>0) {
        CGFloat maxScale = maxWidth/CGRectGetWidth(self.frame);
        CGAffineTransform transformScale = CGAffineTransformMakeScale(maxScale, maxScale);
        scaleTransform = CGAffineTransformConcat(oldTransform, transformScale);
        
    }
    if(!CGAffineTransformEqualToTransform(scaleTransform, CGAffineTransformIdentity)){
        self.transform = scaleTransform;
    }
    
    CGRect actureFrame = self.frame; //已经变换过后的frame
    CGRect actureBounds= self.bounds;//CGRectApplyAffineTransform();
    
    //begin
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:actureFrame.size];
    UIImage *screenshot = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGContextRef context = rendererContext.CGContext;
        CGContextSaveGState(context);
        //    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1, -1);
        CGContextTranslateCTM(context,actureFrame.size.width/2, actureFrame.size.height/2);
        CGContextConcatCTM(context, self.transform);
        CGPoint anchorPoint = self.layer.anchorPoint;
        CGContextTranslateCTM(context,
                              -actureBounds.size.width * anchorPoint.x,
                              -actureBounds.size.height * anchorPoint.y);
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    }];
    //end
    self.transform = oldTransform;
    
    return screenshot;
}
@end
