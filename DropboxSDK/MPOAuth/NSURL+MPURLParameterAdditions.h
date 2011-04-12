//
//  NSURL+MPURLParameterAdditions.h
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.08.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBNSURL : NSObject

+ (NSURL *)url:(NSURL *)url byAddingParameters:(NSArray *)inParameters;
+ (NSURL *)url:(NSURL *)url byAddingParameterDictionary:(NSDictionary *)inParameters;
+ (NSURL *)urlbrlByRemovingQuery:(NSURL *)url;
+ (NSString *)absoluteNormalizedString:(NSURL *)url;

+ (BOOL)url:(NSURL *)url domainMatches:(NSString *)inString;
+ (NSString *)string:(NSURL *)url byAddingURIPercentEscapesUsingEncoding:(NSStringEncoding)inEncoding;

@end
