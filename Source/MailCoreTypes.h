/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */

#import <libetpan/libetpan.h>
#define DEST_CHARSET "UTF-8"
#define CTContentTypesPath @"/System/Library/Frameworks/Foundation.framework/Resources/types.plist"

/** Constants for fetching messages **/
typedef NS_ENUM(NSUInteger, CTFetchAttributes) {
	CTFetchAttrDefaultsOnly	 	= 0,
	CTFetchAttrBodyStructure		= 1 << 0,
	CTFetchAttrEnvelope		 	= 1 << 1
};

/** Constants for IDLE **/
typedef NS_ENUM(NSUInteger, CTIdleResult) {
	CTIdleNewData,
	CTIdleTimeout,
	CTIdleCancelled,
	CTIdleError
};

/** Connection Constants **/
typedef NS_ENUM(NSUInteger, CTSMTPConnectionType) {
	CTSMTPConnectionTypePlain,
	CTSMTPConnectionTypeStartTLS,
	CTSMTPConnectionTypeTLS
};

/** Async SMTP Status **/
typedef NS_ENUM(NSUInteger, CTSMTPAsyncStatus)
{
	CTSMTPAsyncSuccess 	= 0,
	CTSMTPAsyncCanceled = 1,
	CTSMTPAsyncError 	= 2
};

/* when the connection is plain text */
#define CTConnectionTypePlain	   	CONNECTION_TYPE_PLAIN
/* when the connection is first plain, then, we want to switch to TLS (secure connection) */
#define CTConnectionTypeStartTLS	CONNECTION_TYPE_STARTTLS
/* the connection is first plain, then, we will try to switch to TLS */
#define CTConnectionTypeTryStartTLS CONNECTION_TYPE_TRY_STARTTLS
/* the connection is over TLS */
#define CTConnectionTypeTLS		 	CONNECTION_TYPE_TLS
#define CTImapAuthTypePlain		 	IMAP_AUTH_TYPE_PLAIN

/** List of Message Flags **/
#define CTFlagNew			MAIL_FLAG_NEW
#define CTFlagSeen			MAIL_FLAG_SEEN
#define CTFlagFlagged		MAIL_FLAG_FLAGGED
#define CTFlagDeleted		MAIL_FLAG_DELETED
#define CTFlagAnswered		MAIL_FLAG_ANSWERED
#define CTFlagForwarded		MAIL_FLAG_FORWARDED
#define CTFlagCancelled 	MAIL_FLAG_CANCELLED

