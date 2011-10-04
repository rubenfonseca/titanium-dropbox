//
//  MPOAuthCredentialConcreteStore.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.11.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "MPOAuthCredentialConcreteStore.h"
#import "MPURLRequestParameter.h"

#import "NSString+Dropbox.h"

extern NSString * const MPOAuthCredentialRequestTokenKey;
extern NSString * const MPOAuthCredentialRequestTokenSecretKey;
extern NSString * const MPOAuthCredentialAccessTokenKey;
extern NSString * const MPOAuthCredentialAccessTokenSecretKey;
extern NSString * const MPOAuthCredentialSessionHandleKey;

@interface MPOAuthCredentialConcreteStore ()
@property (nonatomic, readwrite, retain) NSMutableDictionary *store;
@property (nonatomic, readwrite, retain) NSURL *baseURL;
@property (nonatomic, readwrite, retain) NSURL *authenticationURL;
@end

@implementation MPOAuthCredentialConcreteStore

- (id)initWithCredentials:(NSDictionary *)inCredentials {
    return [self initWithCredentials:inCredentials forBaseURL:nil];
}

- (id)initWithCredentials:(NSDictionary *)inCredentials forBaseURL:(NSURL *)inBaseURL {
	return [self initWithCredentials:inCredentials forBaseURL:inBaseURL withAuthenticationURL:inBaseURL];
}

- (id)initWithCredentials:(NSDictionary *)inCredentials forBaseURL:(NSURL *)inBaseURL withAuthenticationURL:(NSURL *)inAuthenticationURL {
	if ((self = [super init])) {
		store_ = [[NSMutableDictionary alloc] initWithDictionary:inCredentials];
		self.baseURL = inBaseURL;
		self.authenticationURL = inAuthenticationURL;
    }
	return self;
}

- (oneway void)dealloc {
	self.store = nil;
	self.baseURL = nil;
	self.authenticationURL = nil;
	
	[super dealloc];
}

@synthesize store = store_;
@synthesize baseURL = baseURL_;
@synthesize authenticationURL = authenticationURL_;

#pragma mark -

- (NSString *)consumerKey {
	return [self.store objectForKey:kMPOAuthCredentialConsumerKey];
}

- (NSString *)consumerSecret {
	return [self.store objectForKey:kMPOAuthCredentialConsumerSecret];
}

- (NSString *)username {
	return [self.store objectForKey:kMPOAuthCredentialUsername];
}

- (NSString *)password {
	return [self.store objectForKey:kMPOAuthCredentialPassword];
}

- (NSString *)requestToken {
	return [self.store objectForKey:kMPOAuthCredentialRequestToken];
}

- (void)setRequestToken:(NSString *)inToken {
	if (inToken) {
		[self.store setObject:inToken forKey:kMPOAuthCredentialRequestToken];
	} else {
		[self.store removeObjectForKey:kMPOAuthCredentialRequestToken];
		[self removeValueFromKeychainUsingName:kMPOAuthCredentialRequestToken];
	}
}

- (NSString *)requestTokenSecret {
	return [self.store objectForKey:kMPOAuthCredentialRequestTokenSecret];
}

- (void)setRequestTokenSecret:(NSString *)inTokenSecret {
	if (inTokenSecret) {
		[self.store setObject:inTokenSecret forKey:kMPOAuthCredentialRequestTokenSecret];
	} else {
		[self.store removeObjectForKey:kMPOAuthCredentialRequestTokenSecret];
		[self removeValueFromKeychainUsingName:kMPOAuthCredentialRequestTokenSecret];
	}	
}

- (NSString *)accessToken {
	return [self.store objectForKey:kMPOAuthCredentialAccessToken];
}

- (void)setAccessToken:(NSString *)inToken {
	if (inToken) {
		[self.store setObject:inToken forKey:kMPOAuthCredentialAccessToken];
	} else {
		[self.store removeObjectForKey:kMPOAuthCredentialAccessToken];
		[self removeValueFromKeychainUsingName:kMPOAuthCredentialAccessToken];
	}	
}

- (NSString *)accessTokenSecret {
	return [self.store objectForKey:kMPOAuthCredentialAccessTokenSecret];
}

- (void)setAccessTokenSecret:(NSString *)inTokenSecret {
	if (inTokenSecret) {
		[self.store setObject:inTokenSecret forKey:kMPOAuthCredentialAccessTokenSecret];
	} else {
		[self.store removeObjectForKey:kMPOAuthCredentialAccessTokenSecret];
		[self removeValueFromKeychainUsingName:kMPOAuthCredentialAccessTokenSecret];
	}	
}

- (NSString *)sessionHandle {
	return [self.store objectForKey:kMPOAuthCredentialSessionHandle];
}

- (void)setSessionHandle:(NSString *)inSessionHandle {
	if (inSessionHandle) {
		[self.store setObject:inSessionHandle forKey:kMPOAuthCredentialSessionHandle];
	} else {
		[self.store removeObjectForKey:kMPOAuthCredentialSessionHandle];
		[self removeValueFromKeychainUsingName:kMPOAuthCredentialSessionHandle];
	}
}

#pragma mark -

- (NSString *)credentialNamed:(NSString *)inCredentialName {
	return [store_ objectForKey:inCredentialName];
}

- (void)setCredential:(id)inCredential withName:(NSString *)inName {
	[self.store setObject:inCredential forKey:inName];
	[self addToKeychainUsingName:inName andValue:inCredential];
}

- (void)removeCredentialNamed:(NSString *)inName {
	[self.store removeObjectForKey:inName];
	[self removeValueFromKeychainUsingName:inName];
}

- (void)discardOAuthCredentials {
	self.requestToken = nil;
	self.requestTokenSecret = nil;
	self.accessToken = nil;
	self.accessTokenSecret = nil;
	self.sessionHandle = nil;
}

#pragma mark -

- (NSString *)tokenSecret {
	NSString *tokenSecret = @"";
	
	if (self.accessToken) {
		tokenSecret = [self accessTokenSecret];
	} else if (self.requestToken) {
		tokenSecret = [self requestTokenSecret];
	}
	
	return tokenSecret;
}

- (NSString *)signingKey {
  NSString *consumerSecret = [DBNSString string:[self consumerSecret] byAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSString *tokenSecret = [DBNSString string:[self tokenSecret] byAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	return [NSString stringWithFormat:@"%@%&%@", consumerSecret, tokenSecret];
}

#pragma mark -

- (NSString *)timestamp {
	return [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
}

- (NSString *)signatureMethod {
	return [self.store objectForKey:kMPOAuthSignatureMethod];
}

- (NSArray *)oauthParameters {
	NSMutableArray *oauthParameters = [[NSMutableArray alloc] initWithCapacity:5];	
	MPURLRequestParameter *tokenParameter = [self oauthTokenParameter];
	
	[oauthParameters addObject:[self oauthConsumerKeyParameter]];
	if (tokenParameter) [oauthParameters addObject:tokenParameter];
	[oauthParameters addObject:[self oauthSignatureMethodParameter]];
	[oauthParameters addObject:[self oauthTimestampParameter]];
	[oauthParameters addObject:[self oauthNonceParameter]];
	[oauthParameters addObject:[self oauthVersionParameter]];
	
	return [oauthParameters autorelease];
}

- (void)setSignatureMethod:(NSString *)inSignatureMethod {
	[self.store setObject:inSignatureMethod forKey:kMPOAuthSignatureMethod];
}

- (MPURLRequestParameter *)oauthConsumerKeyParameter {
	MPURLRequestParameter *aRequestParameter = [[MPURLRequestParameter alloc] init];
	aRequestParameter.name = @"oauth_consumer_key";
	aRequestParameter.value = self.consumerKey;
	
	return [aRequestParameter autorelease];
}

- (MPURLRequestParameter *)oauthTokenParameter {
	MPURLRequestParameter *aRequestParameter = nil;
	
	if (self.accessToken || self.requestToken) {
		aRequestParameter = [[MPURLRequestParameter alloc] init];
		aRequestParameter.name = @"oauth_token";
		
		if (self.accessToken) {
			aRequestParameter.value = self.accessToken;
		} else if (self.requestToken) {
			aRequestParameter.value = self.requestToken;
		}
	}
	
	return [aRequestParameter autorelease];
}

- (MPURLRequestParameter *)oauthSignatureMethodParameter {
	MPURLRequestParameter *aRequestParameter = [[MPURLRequestParameter alloc] init];
	aRequestParameter.name = @"oauth_signature_method";
	aRequestParameter.value = self.signatureMethod;
	
	return [aRequestParameter autorelease];
}

- (MPURLRequestParameter *)oauthTimestampParameter {
	MPURLRequestParameter *aRequestParameter = [[MPURLRequestParameter alloc] init];
	aRequestParameter.name = @"oauth_timestamp";
	aRequestParameter.value = self.timestamp;
	
	return [aRequestParameter autorelease];
}

- (MPURLRequestParameter *)oauthNonceParameter {
	MPURLRequestParameter *aRequestParameter = [[MPURLRequestParameter alloc] init];
	aRequestParameter.name = @"oauth_nonce";
	
	NSString *generatedNonce = nil;
	CFUUIDRef generatedUUID = CFUUIDCreate(kCFAllocatorDefault);
	
	generatedNonce = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, generatedUUID);
	CFRelease(generatedUUID);
	
	aRequestParameter.value = generatedNonce;
	[generatedNonce release];
	
	return [aRequestParameter autorelease];
}

- (MPURLRequestParameter *)oauthVersionParameter {
	MPURLRequestParameter *versionParameter = [self.store objectForKey:@"versionParameter"];
	
	if (!versionParameter) {
		versionParameter = [[MPURLRequestParameter alloc] init];
		versionParameter.name = @"oauth_version";
		versionParameter.value = @"1.0";
		[versionParameter autorelease];
	}
	
	return versionParameter;
}

@end

//#if !TARGET_OS_IPHONE || (TARGET_IPHONE_SIMULATOR && !__IPHONE_3_0)
#if false

@interface MPOAuthCredentialConcreteStore (KeychainAdditionsMac)
- (NSString *)findValueFromKeychainUsingName:(NSString *)inName returningItem:(SecKeychainItemRef *)outKeychainItemRef;
@end

@implementation MPOAuthCredentialConcreteStore (Keychain)

- (void)addToKeychainUsingName:(NSString *)inName andValue:(NSString *)inValue {
	NSString *serverName = [self.baseURL host];
	NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
	NSString *securityDomain = [self.authenticationURL host];
	NSString *uniqueName = [NSString stringWithFormat:@"%@.%@", bundleID, inName];
	SecKeychainItemRef existingKeychainItem = NULL;
	
	if ([self findValueFromKeychainUsingName:inName returningItem:&existingKeychainItem]) {
		// This is MUCH easier than updating the item attributes/data
		SecKeychainItemDelete(existingKeychainItem);
	}
	
	SecKeychainAddInternetPassword(NULL /* default keychain */,
                                 [serverName length], [serverName UTF8String],
                                 [securityDomain length], [securityDomain UTF8String],
                                 [uniqueName length], [uniqueName UTF8String],	/* account name */
                                 0, NULL,	/* path */
                                 0,
                                 'oaut'	/* OAuth, not an official OSType code */,
                                 kSecAuthenticationTypeDefault,
                                 [inValue length], [inValue UTF8String],
                                 NULL);
}

- (NSString *)findValueFromKeychainUsingName:(NSString *)inName {
	return [self findValueFromKeychainUsingName:inName returningItem:NULL];
}

- (NSString *)findValueFromKeychainUsingName:(NSString *)inName returningItem:(SecKeychainItemRef *)outKeychainItemRef {
	NSString *foundPassword = nil;
	NSString *serverName = [self.baseURL host];
	NSString *securityDomain = [self.authenticationURL host];
	NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
	NSString *uniqueName = [NSString stringWithFormat:@"%@.%@", bundleID, inName];
	
	UInt32 passwordLength = 0;
	const char *passwordString = NULL;
	
	OSStatus status = SecKeychainFindInternetPassword(NULL	/* default keychain */,
                                                    [serverName length], [serverName UTF8String],
                                                    [securityDomain length], [securityDomain UTF8String],
                                                    [uniqueName length], [uniqueName UTF8String],
                                                    0, NULL,	/* path */
                                                    0,
                                                    kSecProtocolTypeAny,
                                                    kSecAuthenticationTypeAny,
                                                    (UInt32 *)&passwordLength,
                                                    (void **)&passwordString,
                                                    outKeychainItemRef);
	
	if (status == noErr && passwordLength) {
		NSData *passwordStringData = [NSData dataWithBytes:passwordString length:passwordLength];
		foundPassword = [[NSString alloc] initWithData:passwordStringData encoding:NSUTF8StringEncoding];
	}
	
	return [foundPassword autorelease];
}

- (void)removeValueFromKeychainUsingName:(NSString *)inName {
	SecKeychainItemRef aKeychainItem = NULL;
	
	[self findValueFromKeychainUsingName:inName returningItem:&aKeychainItem];
	
	if (aKeychainItem) {
		SecKeychainItemDelete(aKeychainItem);
	}
}

@end

#else

@interface MPOAuthCredentialConcreteStore (TokenAdditionsiPhone)
- (NSString *)findValueFromKeychainUsingName:(NSString *)inName returningItem:(NSDictionary **)outKeychainItemRef;
@end

@implementation MPOAuthCredentialConcreteStore (Keychain)

- (void)addToKeychainUsingName:(NSString *)inName andValue:(NSString *)inValue {
	NSString *serverName = [self.baseURL host];
	NSString *securityDomain = [self.authenticationURL host];
  //	NSString *itemID = [NSString stringWithFormat:@"%@.oauth.%@", [[NSBundle mainBundle] bundleIdentifier], inName];
	NSDictionary *searchDictionary = nil;
	NSDictionary *keychainItemAttributeDictionary = [NSDictionary dictionaryWithObjectsAndKeys:	(id)kSecClassInternetPassword, kSecClass,
                                                   securityDomain, kSecAttrSecurityDomain,
                                                   serverName, kSecAttrServer,
                                                   inName, kSecAttrAccount,
                                                   kSecAttrAuthenticationTypeDefault, kSecAttrAuthenticationType,
                                                   [NSNumber numberWithUnsignedLongLong:'oaut'], kSecAttrType,
                                                   [inValue dataUsingEncoding:NSUTF8StringEncoding], kSecValueData,
                                                   nil];
	
	
	if ([self findValueFromKeychainUsingName:inName returningItem:&searchDictionary]) {
		NSMutableDictionary *updateDictionary = [keychainItemAttributeDictionary mutableCopy];
		[updateDictionary removeObjectForKey:(id)kSecClass];
		
		SecItemUpdate((CFDictionaryRef)keychainItemAttributeDictionary, (CFDictionaryRef)updateDictionary);
		[updateDictionary release];
	} else {
		OSStatus success = SecItemAdd( (CFDictionaryRef)keychainItemAttributeDictionary, NULL);
		
		if (success == errSecNotAvailable) {
			[NSException raise:@"Keychain Not Available" format:@"Keychain Access Not Currently Available"];
		} else if (success == errSecDuplicateItem) {
			[NSException raise:@"Keychain duplicate item exception" format:@"Item already exists for %@", keychainItemAttributeDictionary];
		}
	}
}

- (NSString *)findValueFromKeychainUsingName:(NSString *)inName {
	return [self findValueFromKeychainUsingName:inName returningItem:NULL];
}

- (NSString *)findValueFromKeychainUsingName:(NSString *)inName returningItem:(NSDictionary **)outKeychainItemRef {
	NSString *foundPassword = nil;
	NSString *serverName = [self.baseURL host];
	NSString *securityDomain = [self.authenticationURL host];
	NSDictionary *attributesDictionary = nil;
	NSData *foundValue = nil;
	OSStatus status = noErr;
  //	NSString *itemID = [NSString stringWithFormat:@"%@.oauth.%@", [[NSBundle mainBundle] bundleIdentifier], inName];
	
	NSMutableDictionary *searchDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:(id)kSecClassInternetPassword, (id)kSecClass,
                                           securityDomain, (id)kSecAttrSecurityDomain,
                                           serverName, (id)kSecAttrServer,
                                           inName, (id)kSecAttrAccount,
                                           (id)kSecMatchLimitOne, (id)kSecMatchLimit,
                                           (id)kCFBooleanTrue, (id)kSecReturnData,
                                           (id)kCFBooleanTrue, (id)kSecReturnAttributes,
                                           (id)kCFBooleanTrue, (id)kSecReturnPersistentRef,
                                           nil];
  
	status = SecItemCopyMatching((CFDictionaryRef)searchDictionary, (CFTypeRef *)&attributesDictionary);		
	foundValue = [attributesDictionary objectForKey:(id)kSecValueData];
	if (outKeychainItemRef) {
		*outKeychainItemRef = attributesDictionary;
	}
	
	if (status == noErr && foundValue) {
		foundPassword = [[NSString alloc] initWithData:foundValue encoding:NSUTF8StringEncoding];
	}
	
	return [foundPassword autorelease];
}

- (void)removeValueFromKeychainUsingName:(NSString *)inName {
	NSString *serverName = [self.baseURL host];
	NSString *securityDomain = [self.authenticationURL host];
  
	NSMutableDictionary *searchDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:	(id)kSecClassInternetPassword, (id)kSecClass,
                                           securityDomain, (id)kSecAttrSecurityDomain,
                                           serverName, (id)kSecAttrServer,
                                           inName, (id)kSecAttrAccount,
                                           nil];
	
	OSStatus success = SecItemDelete((CFDictionaryRef)searchDictionary);
  
	if (success == errSecNotAvailable) {
		[NSException raise:@"Keychain Not Available" format:@"Keychain Access Not Currently Available"];
	} else if (success == errSecParam) {
		[NSException raise:@"Keychain parameter error" format:@"One or more parameters passed to the function were not valid from %@", searchDictionary];
	} else if (success == errSecAllocate) {
		[NSException raise:@"Keychain memory error" format:@"Failed to allocate memory"];			
	}
  
}

@end

#endif
