//
//  NSString+URLEscapingAdditions.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.07.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "NSString+URLEscapingAdditions.h"


@implementation DBNSString

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
