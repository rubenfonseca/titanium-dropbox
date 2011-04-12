//
//  NSURL+MPURLParameterAdditions.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.08.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "NSURL+MPURLParameterAdditions.h"
#import "MPURLRequestParameter.h"
#import "NSString+URLEscapingAdditions.h"

@implementation DBNSURL

+ (NSURL *)url:(NSURL *)url byAddingParameters:(NSArray *)inParameters {
	NSMutableArray *parameters = [[NSMutableArray alloc] init];
	NSString *queryString = [url query];
	NSString *absoluteString = [url absoluteString];
	NSRange parameterRange = [absoluteString rangeOfString:@"?"];
	
	if (parameterRange.location != NSNotFound) {
		parameterRange.length = [absoluteString length] - parameterRange.location;
		[parameters addObjectsFromArray:[MPURLRequestParameter parametersFromString:queryString]];
		absoluteString = [absoluteString substringToIndex:parameterRange.location];
	}
	
	[parameters addObjectsFromArray:inParameters];
	
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", absoluteString, [MPURLRequestParameter parameterStringForParameters:[parameters autorelease]]]];
}

+ (NSURL *)url:(NSURL *)url byAddingParameterDictionary:(NSDictionary *)inParameters {
	NSMutableDictionary *parameterDictionary = [inParameters mutableCopy];
	NSString *queryString = [url query];
	NSString *absoluteString = [url absoluteString];
	NSRange parameterRange = [absoluteString rangeOfString:@"?"];
	NSURL *composedURL = url;
	
	if (parameterRange.location != NSNotFound) {
		parameterRange.length = [absoluteString length] - parameterRange.location;
		
		//[parameterDictionary addEntriesFromDictionary:inParameterDictionary];
		[parameterDictionary addEntriesFromDictionary:[MPURLRequestParameter parameterDictionaryFromString:queryString]];
		
		composedURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [absoluteString substringToIndex:parameterRange.location], [MPURLRequestParameter parameterStringForDictionary:parameterDictionary]]];
	} else if ([parameterDictionary count]) {
		composedURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", absoluteString, [MPURLRequestParameter parameterStringForDictionary:parameterDictionary]]];
	}
	
	[parameterDictionary release];

	return composedURL;
}

+ (NSURL *)urlbrlByRemovingQuery:(NSURL *)url {
	NSURL *composedURL = url;
	NSString *absoluteString = [url absoluteString];
	NSRange queryRange = [absoluteString rangeOfString:@"?"];
	
	if (queryRange.location != NSNotFound) {
		NSString *urlSansQuery = [absoluteString substringToIndex:queryRange.location];
		composedURL = [NSURL URLWithString:urlSansQuery];
	}
	
	return composedURL;
}

+ (NSString *)absoluteNormalizedString:(NSURL *)url {
	NSString *normalizedString = [url absoluteString];

	if ([[url path] length] == 0 && [[url query] length] == 0) {
		normalizedString = [NSString stringWithFormat:@"%@/", [url absoluteString]];
	}
	
	return normalizedString;
}

+ (BOOL)url:(NSURL *)url domainMatches:(NSString *)inString {
	BOOL matches = NO;
	
	NSString *domain = [url host];
  matches = [DBNSString isIPAddress:domain] && [domain isEqualToString:inString];
	
	int domainLength = [domain length];
	int requestedDomainLength = [inString length];
	
	if (!matches) {
		if (domainLength > requestedDomainLength) {
			matches = [domain rangeOfString:inString].location == (domainLength - requestedDomainLength);
		} else if (domainLength == (requestedDomainLength - 1)) {
			matches = ([inString compare:domain options:NSCaseInsensitiveSearch range:NSMakeRange(1, domainLength)] == NSOrderedSame);
		}
	}
	
	return matches;
}

+ (NSString *)string:(NSURL *)url byAddingURIPercentEscapesUsingEncoding:(NSStringEncoding)inEncoding {
  
  return [DBNSString string:[url absoluteString] byAddingURIPercentEscapesUsingEncoding:inEncoding];
}

@end
