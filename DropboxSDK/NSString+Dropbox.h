//
//  NSString+Dropbox.h
//  DropboxSDK
//
//  Created by Brian Smith on 7/19/10.
//  Copyright 2010 Dropbox, Inc. All rights reserved.
//


@interface DBNSString : NSObject

// This will take a path for a resource and normalize so you can compare paths
+ (NSString*)normalizedDropboxPath:(NSString *)string;

// Normalizes both paths and compares them
+ (BOOL)string:(NSString *)string isEqualToDropboxPath:(NSString*)otherPath;

@end
