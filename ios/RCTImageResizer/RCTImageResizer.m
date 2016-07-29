//
//  ImageResize.m
//  ChoozItApp
//
//  Created by Florian Rival on 19/11/15.
//

#include "RCTImageResizer.h"
#include "ImageHelpers.h"
#import "RCTImageLoader.h"

@implementation ImageResizer

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

void saveImage(NSString * fullPath, UIImage * image, float quality)
{
    NSData* data = UIImageJPEGRepresentation(image, quality / 100.0);
    NSFileManager* fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:fullPath contents:data attributes:nil];
}

NSString * generateFilePath(NSString * ext, NSString * outputPath)
{
    NSString* directory;

    if ([outputPath length] == 0) {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        directory = [paths firstObject];
    } else {
        directory = outputPath;
    }

    NSString* name = [[NSUUID UUID] UUIDString];
    NSString* fullName = [NSString stringWithFormat:@"%@.%@", name, ext];
    NSString* fullPath = [directory stringByAppendingPathComponent:fullName];

    return fullPath;
}

RCT_EXPORT_METHOD(createResizedImage:(NSString *)imageURL
                  width:(float)width
                  height:(float)height
                  quality:(float)quality
                  outputPath:(NSString *)outputPath
                  callback:(RCTResponseSenderBlock)callback)
{
    CGSize newSize = CGSizeMake(width, height);
    NSString* fullPath = generateFilePath(@"jpg", outputPath);

    NSURLRequest *imageURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];

    [_bridge.imageLoader loadImageWithURLRequest:imageURLRequest callback:^(NSError *error, UIImage *image) {
        if (error || image == nil) {
            callback(@[@"Can't retrieve the file from the path.", @""]);
            return;
        }

        // Do the resizing
        UIImage * scaledImage = [image scaleToSize:newSize];
        if (scaledImage == nil) {
            callback(@[@"Can't resize the image.", @""]);
            return;
        }

        saveImage(fullPath, scaledImage, quality);
        callback(@[[NSNull null], fullPath]);
    }];
}

@end
