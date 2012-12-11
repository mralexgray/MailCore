/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */

#import <Foundation/Foundation.h>

/**	This is a very simple class designed to make it easier to work with email addresses since many times
 the e-mail address and name are both encoded in the MIME e-mail fields. This class should be very straight
 forward, you can get and set a name and an e-mail address.	*/

@interface CTCoreAddress : NSObject
//{
//	NSString *email;
//	NSString *name;
//}
/**	Returns a CTCoreAddress with the name and e-mail address set as an empty string.	*/
+ (id)address;

/**	Returns a CTCoreAddress set with the specified name and email.	*/
+ (id)addressWithName: (NSString*)aName email: (NSString*)aEmail;

/**	Returns a CTCoreAddress set with the specified name and email.	*/
- (id)initWithName: (NSString*)aName email: (NSString*)aEmail;

@property (nonatomic, strong) NSString *name, *email;
@property (readonly) NSString *decodedName;

/**	Returns the name as a NSString	*/
//- (NSString*) name;
//- (NSString*) decodedName; // added by Gabor

/**	Sets the name.	*/
//- (void)setName: (NSString*)aValue;
/**	Returns the e-mail as a NSString	*/
//- (NSString*)email;
/**	Sets the e-mail.	*/
//- (void)setEmail: (NSString*)aValue;

/**	Works like the typical isEqual: method	*/
- (BOOL) isEqual:(id)object;

/**	Standard description method	*/
- (NSString*)description;
@end
