//
//  UIImage+Capture.m
//  JKCategories (https://github.com/shaojiankui/JKCategories)
//
//  Created by Jakey on 15/1/10.
//  Copyright (c) 2015年 www.skyfox.org. All rights reserved.
//

#import "UIImage+JKCapture.h"
#import <QuartzCore/QuartzCore.h>
@implementation UIImage (JKCapture)
/**
 *  @brief  截图指定view成图片
 *
 *  @param view 一个view
 *
 *  @return 图片
 */
+ (UIImage *)jk_captureWithView:(UIView *)view
{
    UIGraphicsImageRendererFormat *rendererFormat = [[UIGraphicsImageRendererFormat alloc] init];
    rendererFormat.scale =  [UIScreen mainScreen].scale;
    rendererFormat.opaque = view.opaque;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:view.bounds.size format:rendererFormat];
    UIImage *screenshot = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    }];
    return screenshot;
}

+ (UIImage *)jk_getImageWithSize:(CGRect)myImageRect FromImage:(UIImage *)bigImage
{
    //大图bigImage
    //定义myImageRect，截图的区域
    CGImageRef imageRef = bigImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    CGSize size;
    size.width = CGRectGetWidth(myImageRect);
    size.height = CGRectGetHeight(myImageRect);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGContextRef context = rendererContext.CGContext;
        CGContextDrawImage(context, myImageRect, subImageRef);
    }];
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    return smallImage;
}

/**
 *  @author Jakey
 *
 *  @brief  截图一个view中所有视图 包括旋转缩放效果
 *
 *  @param aView    指定的view
 *  @param maxWidth 宽的大小 0为view默认大小
 *
 *  @return 截图
 */
+ (UIImage *)jk_screenshotWithView:(UIView *)aView limitWidth:(CGFloat)maxWidth{
    CGAffineTransform oldTransform = aView.transform;
    
    CGAffineTransform scaleTransform = CGAffineTransformIdentity;
    if (!isnan(maxWidth) && maxWidth>0) {
        CGFloat maxScale = maxWidth/CGRectGetWidth(aView.frame);
        CGAffineTransform transformScale = CGAffineTransformMakeScale(maxScale, maxScale);
        scaleTransform = CGAffineTransformConcat(oldTransform, transformScale);
    
    }
    if(!CGAffineTransformEqualToTransform(scaleTransform, CGAffineTransformIdentity)){
        aView.transform = scaleTransform;
    }
    
    CGRect actureFrame = aView.frame; //已经变换过后的frame
    CGRect actureBounds= aView.bounds;//CGRectApplyAffineTransform();
    
    //begin
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:actureFrame.size];
    UIImage *screenshot = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGContextRef context = rendererContext.CGContext;
        CGContextSaveGState(context);
        //    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1, -1);
        CGContextTranslateCTM(context,actureFrame.size.width/2, actureFrame.size.height/2);
        CGContextConcatCTM(context, aView.transform);
        CGPoint anchorPoint = aView.layer.anchorPoint;
        CGContextTranslateCTM(context,
                              -actureBounds.size.width * anchorPoint.x,
                              -actureBounds.size.height * anchorPoint.y);
        [aView drawViewHierarchyInRect:aView.bounds afterScreenUpdates:NO];

    }];
    //end
    aView.transform = oldTransform;
    
    return screenshot;
}
@end
