/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */

#import "CTSMTP.h"
#import "CTCoreAddress.h"
#import "CTCoreMessage.h"
#import "MailCoreTypes.h"
#import "MailCoreUtilities.h"

@implementation CTSMTP
@synthesize lastError;

- (id)initWithResource:(mailsmtp *)smtp {
    self = [super init];
    if (self) {
        mySMTP = smtp;
    }
    return self;
}

- (void)dealloc {
    self.lastError = nil;
    [super dealloc];
}

- (BOOL) connectToServer: (NSString*)server port:(unsigned int)port {
    /* first open the stream */
    int ret = mailsmtp_socket_connect([self resource], [server cStringUsingEncoding:NSUTF8StringEncoding], port);
    if (ret != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromSMTPCode(ret);
        return NO;
    }
    return YES;
}

- (BOOL) connectWithTlsToServer: (NSString*)server port:(unsigned int)port {
    /* first open the stream */
    int ret = mailsmtp_ssl_connect([self resource], [server cStringUsingEncoding:NSUTF8StringEncoding], port);
    if (ret != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromSMTPCode(ret);
        return NO;
    }
    return YES;
}

- (BOOL) helo {
    /*  The server doesn't support esmtp, so try regular smtp */
    int ret = mailsmtp_helo([self resource]);
    if (ret != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromSMTPCode(ret);
        return NO;
    }
    return YES; /* The server supports helo so return YES */
}

- (BOOL) startTLS {
    return YES;
}

- (BOOL) authenticateWithUsername: (NSString*)username password: (NSString*)password server: (NSString*)server {
    return YES;
}

- (BOOL) setFrom: (NSString*)fromAddress {
    int ret = mailsmtp_mail([self resource], [fromAddress cStringUsingEncoding:NSUTF8StringEncoding]);
    if (ret != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromSMTPCode(ret);
        return NO;
    }
    return YES;
}


- (BOOL) setRecipients:(id)recipients {
    NSEnumerator *objEnum = [recipients objectEnumerator];
    CTCoreAddress *rcpt;
    while ((rcpt = [objEnum nextObject])) {
        BOOL success = [self setRecipientAddress:[rcpt email]];
        if (!success) {
            return NO;
        }
    }
    return YES;
}


- (BOOL) setRecipientAddress: (NSString*)recAddress {
    int ret = mailsmtp_rcpt([self resource], [recAddress cStringUsingEncoding:NSUTF8StringEncoding]);
    if (ret != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromSMTPCode(ret);
        return NO;
    }
    return YES;
}

- (BOOL) setData: (NSString*)data {
    NSData *dataObj = [data dataUsingEncoding:NSUTF8StringEncoding];
    int ret = mailsmtp_data([self resource]);
    if (ret != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromSMTPCode(ret);
        return NO;
    }
    ret = mailsmtp_data_message([self resource], [dataObj bytes], [dataObj length]);
    if (ret != MAIL_NO_ERROR) {
        self.lastError = MailCoreCreateErrorFromSMTPCode(ret);
        return NO;
    }
    return YES;
}

- (mailsmtp *)resource {
    return mySMTP;
}
@end
