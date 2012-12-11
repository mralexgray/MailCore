/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */


#import "CTCoreAddress.h"
#import "MailCoreUtilities.h"

@implementation CTCoreAddress
@synthesize email, name;

+ (id)address {	return [CTCoreAddress.alloc init];	}


+ (id)addressWithName: (NSString*)aName email: (NSString*)aEmail {
	return  [CTCoreAddress.alloc initWithName:aName email:aEmail];
}

- (id)initWithName: (NSString*)aName email: (NSString*)aEmail
{
	if (self != super.init ) return nil;
	name = aName;
	email = aEmail;
	return self;
}

- (id)init
{
	if (self != super.init ) return nil;
	[self setName:@""];
	[self setEmail:@""];
	return self;
}

-(NSString*)decodedName {
	return MailCoreDecodeMIMEPhrase((char *)[self.name UTF8String]);
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<%@,%@>", [self name],[self email]];
}

- (BOOL) isEqual:(id)object
{
	if (![object isKindOfClass:[CTCoreAddress class]])	return NO;
	return [[object name] isEqualToString:self.name] && [[object email] isEqualToString:self.email];
}

- (void)dealloc {
	[email release];
	[name release];
	[super dealloc];
}
@end
