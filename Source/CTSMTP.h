/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */

#import <Foundation/Foundation.h>
#import <libetpan/libetpan.h>

/*
 This class is used internally by CTSMTPConnection for SMTP connections, clients
 should not use this directly.	*/

@interface CTSMTP : NSObject {
	mailsmtp *mySMTP; /* This resource is created and freed by CTSMTPConnection */
	NSError *lastError;
}
/*
 If an error occurred (nil or return of NO) call this method to get the error	*/
@property(nonatomic, retain) NSError *lastError;

- (id)initWithResource:(mailsmtp *)smtp;
- (BOOL) connectToServer: (NSString*)server port:(unsigned int)port;
- (BOOL) connectWithTlsToServer: (NSString*)server port:(unsigned int)port;
- (BOOL) helo;
- (BOOL) startTLS;
- (BOOL) authenticateWithUsername: (NSString*)username password: (NSString*)password server: (NSString*)server;
- (BOOL) setFrom: (NSString*)fromAddress;
- (BOOL) setRecipients:(id)recipients;
- (BOOL) setRecipientAddress: (NSString*)recAddress;
- (BOOL) setData: (NSString*)data;
- (mailsmtp *)resource;
@end
