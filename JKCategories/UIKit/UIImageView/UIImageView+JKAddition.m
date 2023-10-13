//
//  UIImageView+Addition.m
//  JKCategories (https://github.com/shaojiankui/JKCategories)
//
//  Created by Jakey on 14/12/15.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import "UIImageView+JKAddition.h"

@implementation UIImageView (JKAddition)
+ (id)jk_imageViewWithImageNamed:(NSString*)imageName
{
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
}
+ (id)jk_imageViewWithFrame:(CGRect)frame
{
    return [[UIImageView alloc] initWithFrame:frame];
}
+ (id)jk_imageViewWithStretchableImage:(NSString*)imageName Frame:(CGRect)frame
{
    UIImage *image =[UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = [image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2];
    return imageView;
}
- (void)jk_setImageWithStretchableImage:(NSString*)imageName
{
    UIImage *image =[UIImage imageNamed:imageName];
    self.image = [image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2];
}
+ (id)jk_imageViewWithImageArray:(NSArray *)imageArray duration:(NSTimeInterval)duration;
{
    if (imageArray && [imageArray count]<=0)
    {
        return nil;
    }
    UIImageView *imageView = [UIImageView jk_imageViewWithImageNamed:[imageArray objectAtIndex:0]];
    NSMutableArray *images = [NSMutableArray array];
    for (NSInteger i = 0; i < imageArray.count; i++)
    {
        UIImage *image = [UIImage imageNamed:[imageArray objectAtIndex:i]];
        [images addObject:image];
    }
    [imageView setImage:[images objectAtIndex:0]];
    [imageView setAnimationImages:images];
    [imageView setAnimationDuration:duration];
    [imageView setAnimationRepeatCount:0];
    return imageView;
}
// 画水印
- (void)jk_setImage:(UIImage *)image withWaterMark:(UIImage *)mark inRect:(CGRect)rect
{
    
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.frame.size];
    self.image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGContextRef context = rendererContext.CGContext;
        //原图
        [image drawInRect:self.bounds];
        //水印图
        [mark drawInRect:rect];
    }];
}
- (void)jk_setImage:(UIImage *)image withStringWaterMark:(NSString *)markString inRect:(CGRect)rect color:(UIColor *)color font:(UIFont *)font
{
    
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.frame.size];
    self.image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        [image drawInRect:self.bounds];
        [color set];
        [markString drawInRect:rect withAttributes:@{NSFontAttributeName:font}];

    }];
}
- (void)jk_setImage:(UIImage *)image withStringWaterMark:(NSString *)markString atPoint:(CGPoint)point color:(UIColor *)color font:(UIFont *)font
{
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.frame.size];
    self.image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        [image drawInRect:self.bounds];
        [color set];
        [markString drawAtPoint:point withAttributes:@{NSFontAttributeName:font}];
    }];
    
}

@end
