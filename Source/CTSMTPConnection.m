/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */

#import "CTSMTPConnection.h"
#import <libetpan/libetpan.h>
#import "CTCoreAddress.h"
#import "CTCoreMessage.h"
#import "MailCoreTypes.h"

#import "CTSMTP.h"
#import "CTESMTP.h"

//TODO Add more descriptive error messages using mailsmtp_strerror
@implementation CTSMTPConnection
+ (BOOL)sendMessage:(CTCoreMessage *)message server: (NSString*)server username: (NSString*)username
           password: (NSString*)password port:(unsigned int)port connectionType:(CTSMTPConnectionType)connectionType
            useAuth:(BOOL)auth error:(NSError **)error {
    BOOL success;
    mailsmtp *smtp = NULL;
    smtp = mailsmtp_new(0, NULL);

    CTSMTP *smtpObj = [[CTESMTP alloc] initWithResource:smtp];
    if (connectionType == CTSMTPConnectionTypeStartTLS || connectionType == CTSMTPConnectionTypePlain) {
        success = [smtpObj connectToServer:server port:port];
    } else if (connectionType == CTSMTPConnectionTypeTLS) {
        success = [smtpObj connectWithTlsToServer:server port:port];
    }
    if (!success) {
        goto error;
    }
    if ([smtpObj helo] == NO) {
        /* The server didn't support ESMTP, so switching to STMP */
        [smtpObj release];
        smtpObj = [[CTSMTP alloc] initWithResource:smtp];
        success = [smtpObj helo];
        if (!success) {
            goto error;
        }
    }
    if (connectionType == CTSMTPConnectionTypeStartTLS) {
        success = [smtpObj startTLS];
        if (!success) {
            goto error;
        }
    }
    if (auth) {
        success = [smtpObj authenticateWithUsername:username password:password server:server];
        if (!success) {
            goto error;
        }
    }

    success = [smtpObj setFrom:[[[message from] anyObject] email]];
    if (!success) {
        goto error;
    }

    /* recipients */
    NSMutableSet *rcpts = [NSMutableSet set];
    [rcpts unionSet:[message to]];
    [rcpts unionSet:[message bcc]];
    [rcpts unionSet:[message cc]];
    success = [smtpObj setRecipients:rcpts];
    if (!success) {
        goto error;
    }

    /* data */
    success = [smtpObj setData:[message render]];
    if (!success) {
        goto error;
    }
    
    mailsmtp_quit(smtp);
    mailsmtp_free(smtp);
    
    [smtpObj release];
    return YES;
error:
    *error = smtpObj.lastError;
    [smtpObj release];
    mailsmtp_free(smtp);
    return NO;
}

+ (BOOL)canConnectToServer: (NSString*)server username: (NSString*)username password: (NSString*)password
                      port:(unsigned int)port connectionType:(CTSMTPConnectionType)connectionType
                   useAuth:(BOOL)auth error:(NSError **)error {
  BOOL success;
  mailsmtp *smtp = NULL;
  smtp = mailsmtp_new(0, NULL);
    
  CTSMTP *smtpObj = [[CTESMTP alloc] initWithResource:smtp];
  if (connectionType == CTSMTPConnectionTypeStartTLS || connectionType == CTSMTPConnectionTypePlain) {
     success = [smtpObj connectToServer:server port:port];
  } else if (connectionType == CTSMTPConnectionTypeTLS) {
     success = [smtpObj connectWithTlsToServer:server port:port];
  }
  if (!success) {
    goto error;
  }
  if ([smtpObj helo] == NO) {
    /* The server didn't support ESMTP, so switching to STMP */
    [smtpObj release];
    smtpObj = [[CTSMTP alloc] initWithResource:smtp];
    success = [smtpObj helo];
    if (!success) {
      goto error;
    }
  }
  if (connectionType == CTSMTPConnectionTypeStartTLS) {
    success = [smtpObj startTLS];
    if (!success) {
      goto error;
    }
  }
  if (auth) {
    success = [smtpObj authenticateWithUsername:username password:password server:server];
    if (!success) {
      goto error;
    }
  }

  mailsmtp_quit(smtp);
  mailsmtp_free(smtp);
    
  [smtpObj release];
  return YES;
error:
  *error = smtpObj.lastError;
  [smtpObj release];
  mailsmtp_free(smtp);
  return NO;
}
@end
