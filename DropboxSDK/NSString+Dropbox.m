//
//  NSString+Dropbox.m
//  DropboxSDK
//
//  Created by Brian Smith on 7/19/10.
//  Copyright 2010 Dropbox, Inc. All rights reserved.
//

#import "NSString+Dropbox.h"


@implementation DBNSString

+ (NSString*)normalizedDropboxPath:(NSString *)string {
    if ([string isEqual:@"/"]) return @"";
    return [[string lowercaseString] precomposedStringWithCanonicalMapping];
}

+ (BOOL)string:(NSString *)string isEqualToDropboxPath:(NSString*)otherPath {
  return [[DBNSString normalizedDropboxPath:string] isEqualToString:[DBNSString normalizedDropboxPath:otherPath]];
}

+ (BOOL)isIPAddress:(NSString *)string {
	BOOL isIPAddress = NO;
	NSArray *components = [string componentsSeparatedByString:@"."];
	NSCharacterSet *invalidCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet]; 
  
	if ([components count] == 4) {
		NSString *part1 = [components objectAtIndex:0];
		NSString *part2 = [components objectAtIndex:1];
		NSString *part3 = [components objectAtIndex:2];
		NSString *part4 = [components objectAtIndex:3];
    
		if ([part1 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
        [part2 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
        [part3 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
        [part4 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound ) {
      
			if ([part1 intValue] < 255 &&
          [part2 intValue] < 255 &&
          [part3 intValue] < 255 &&
          [part4 intValue] < 255) {
				isIPAddress = YES;
			}
		}
	}
	
	return isIPAddress;
}

+ (NSString *)string:(NSString *)string byAddingURIPercentEscapesUsingEncoding:(NSStringEncoding)inEncoding {
	NSString *escapedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                (CFStringRef)string,
                                                                                NULL,
                                                                                (CFStringRef)@":/?=,!$&'()*+;[]@#",
                                                                                CFStringConvertNSStringEncodingToEncoding(inEncoding));
	
	return [escapedString autorelease];
}

@end
