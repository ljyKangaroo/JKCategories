//
//  UIImage+Vector.m
//  UIImage+Vector
//
//  Created by David Keegan on 8/7/13.
//  Copyright (c) 2013 David Keegan All rights reserved.
//

#import "UIImage+JKVector.h"
#import <CoreText/CoreText.h>

@implementation UIImage(JKVector)

+ (NSCache *)jk_cache{
    static NSCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
    });
    return cache;
}

+ (UIImage *)jk_iconWithFont:(UIFont *)font named:(NSString *)iconNamed withTintColor:(UIColor *)tintColor clipToBounds:(BOOL)clipToBounds forSize:(CGFloat)fontSize{
    NSString *identifier = [NSString stringWithFormat:@"%@%@%@%@%d%f", NSStringFromSelector(_cmd), font.fontName, tintColor, iconNamed, clipToBounds, fontSize];
    UIImage *image = [[self jk_cache] objectForKey:identifier];
    if(image == nil){
        NSMutableAttributedString *ligature = [[NSMutableAttributedString alloc] initWithString:iconNamed];
        [ligature setAttributes:@{(NSString *)kCTLigatureAttributeName: @(2),
                                  (NSString *)kCTFontAttributeName: font}
                          range:NSMakeRange(0, [ligature length])];

        CGSize imageSize = [ligature size];
        imageSize.width = ceil(imageSize.width);
        imageSize.height = ceil(imageSize.height);
        if(!CGSizeEqualToSize(CGSizeZero, imageSize)){
            UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:imageSize];
            image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
                [ligature drawAtPoint:CGPointZero];
            }];

            if(tintColor){
                UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:imageSize];
                image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
                    CGContextRef context = rendererContext.CGContext;
                    CGContextScaleCTM(context, 1, -1);
                    CGContextTranslateCTM(context, 0, -imageSize.height);
                    CGContextClipToMask(context, (CGRect){.size=imageSize}, [image CGImage]);
                    [tintColor setFill];
                    CGContextFillRect(context, (CGRect){.size=imageSize});
                }];
            }

            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wundeclared-selector"
            if(clipToBounds && [image respondsToSelector:@selector(imageClippedToPixelBounds)]){
                image = [image performSelector:@selector(imageClippedToPixelBounds)];
            }
            #pragma clang diagnostic pop

            [[self jk_cache] setObject:image forKey:identifier];
        }
    }
    return image;
}

+ (UIImage *)jk_imageWithPDFNamed:(NSString *)pdfNamed forHeight:(CGFloat)height{
    return [self jk_imageWithPDFNamed:pdfNamed withTintColor:nil forHeight:height];
}

+ (UIImage *)jk_imageWithPDFNamed:(NSString *)pdfNamed withTintColor:(UIColor *)tintColor forHeight:(CGFloat)height{
    NSString *pdfFile = [[NSBundle mainBundle] pathForResource:pdfNamed ofType:@"pdf"];
    return [self jk_imageWithPDFFile:pdfFile withTintColor:tintColor forSize:CGSizeMake(MAXFLOAT, height)];
}

+ (UIImage *)jk_imageWithPDFFile:(NSString *)pdfFile withTintColor:(UIColor *)tintColor forSize:(CGSize)size{
    if(!pdfFile || CGSizeEqualToSize(size, CGSizeZero)){
        return nil;
    }

    NSString *identifier = [NSString stringWithFormat:@"%@%@%@%@", NSStringFromSelector(_cmd), pdfFile, tintColor, NSStringFromCGSize(size)];
    UIImage *image = [[self jk_cache] objectForKey:identifier];
    if(image){
        return image;
    }

    NSURL *url = [NSURL fileURLWithPath:pdfFile];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
    if(!pdf){
        return nil;
    }

    CGPDFPageRef page1 = CGPDFDocumentGetPage(pdf, 1);
    CGRect mediaRect = CGPDFPageGetBoxRect(page1, kCGPDFCropBox);

    CGSize imageSize = mediaRect.size;
    if(imageSize.height < size.height && size.height != MAXFLOAT){
        imageSize.width = round(size.height/imageSize.height*imageSize.width);
        imageSize.height = size.height;
    }
    if(imageSize.width < size.width && size.width != MAXFLOAT){
        imageSize.height = round(size.width/imageSize.width*imageSize.height);
        imageSize.width = size.width;
    }

    if(imageSize.height > size.height){
        imageSize.width = round(size.height/imageSize.height*imageSize.width);
        imageSize.height = size.height;
    }
    if(imageSize.width > size.width){
        imageSize.height = round(size.width/imageSize.width*imageSize.height);
        imageSize.width = size.width;
    }

    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:imageSize];
    image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGContextRef context = rendererContext.CGContext;
        CGFloat scale = MIN(imageSize.width/mediaRect.size.width, imageSize.height/mediaRect.size.height);
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -imageSize.height);
        CGContextScaleCTM(context, scale, scale);
        CGContextDrawPDFPage(context, page1);
        CGPDFDocumentRelease(pdf);
    }];

    if(tintColor){
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:imageSize];
        image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
            CGContextRef context = rendererContext.CGContext;
            CGContextScaleCTM(context, 1, -1);
            CGContextTranslateCTM(context, 0, -imageSize.height);
            CGContextClipToMask(context, (CGRect){.size=imageSize}, [image CGImage]);
            [tintColor setFill];
            CGContextFillRect(context, (CGRect){.size=imageSize});
        }];
    }

    return image;
}

@end
