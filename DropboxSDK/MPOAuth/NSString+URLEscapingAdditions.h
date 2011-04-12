//
//  NSString+URLEscapingAdditions.h
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.07.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DBNSString : NSObject

+ (BOOL)isIPAddress:(NSString *)string;
+ (NSString *)string:(NSString *)string byAddingURIPercentEscapesUsingEncoding:(NSStringEncoding)inEncoding;

@end

