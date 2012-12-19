/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */


#import <libetpan/libetpan.h>

#import "CTCoreAddress.h"
#import "CTCoreMessage.h"
#import "CTESMTP.h"
#import "CTSMTP.h"
#import "CTSMTPAsyncConnection.h"


//setup to allow c callback fxn:
CTSMTPAsyncConnection *ptrToSelf;

void
smtpProgress(size_t aCurrent, size_t aTotal) {
	if (ptrToSelf != nil) {
		float theProgress = (float) aCurrent / (float) aTotal * 100;
		[ptrToSelf performSelector:@selector(handleSmtpProgress:)
						withObject:@(theProgress)];
	}
}

@interface CTSMTPAsyncConnection (PrivateMethods)

- (void)sendMailThread;

- (void)handleSmtpProgress:(NSNumber *)aProgress;

- (void)threadWillExitHandler:(NSNotification *)aNote;

- (void)cleanupAfterThread;

@end


@implementation CTSMTPAsyncConnection

@synthesize message = mMessage;
@synthesize serverSettings = mServerSettings;
@synthesize status = mStatus;

- (id)initWithServer: (NSString*)aServer
			username: (NSString*)aUsername
			password: (NSString*)aPassword
				port:(unsigned int)aPort
			  useTLS:(BOOL)aTls
			 useAuth:(BOOL)aAuth
			delegate:(id <CTSMTPConnectionDelegate>)aDelegate {

	self = [super init];
	if (self) {
		mStatus = CTSMTPAsyncSuccess;
		ptrToSelf = self;
		mSMTPObj = nil;
		mSMTP = NULL;
		mMailThread = nil;
		mDelegate = aDelegate;
		mServerSettings =
			[@{@"server": aServer,
														@"username": aUsername,
														@"password": aPassword,
														@"port": @(aPort),
														@"tls": @(aTls),
														@"auth": @(aAuth)} retain];

		//save clients from themselves (they could be leaking us - no dealloc)
		[NSNotificationCenter.defaultCenter removeObserver:self];
		[NSNotificationCenter.defaultCenter addObserver:self
												 selector:@selector(threadWillExitHandler:)
													 name:NSThreadWillExitNotification
												   object:nil];
	}
	return self;
}

- (void)dealloc {
	[NSNotificationCenter.defaultCenter removeObserver:self];
	[self cleanupAfterThread];
	[super dealloc];
}

- (void)finalize {
	[NSNotificationCenter.defaultCenter removeObserver:self];
	[self cleanupAfterThread];
	[super finalize];
}


- (void)sendMessageInBackgroundAndNotify:(CTCoreMessage *)aMessage {
	if (aMessage == nil) {
		NSLog(@"CTCoreMessage param cannot be nil");
		return;
	}

	if (mMailThread != nil && [mMailThread isExecuting]) {
		NSLog(@"Can only send one message at a time, we're busy, sheesh.");
		return;
	}

	NSAssert( mMailThread == nil, @"Invalid smtp thread state" );

	self.message = aMessage;

	//start thread:
	mMailThread = [NSThread alloc];
	[mMailThread initWithTarget:self selector:@selector(sendMailThread) object:nil];
	[mMailThread start];
}

- (void)cancel {
	if (![mMailThread isExecuting] || [mMailThread isCancelled]) {
		return;
	}
	//mark thread as cancelled
	[mMailThread cancel];
	//cancel libetpan smtp stream
	mailstream_cancel(mSMTP -> stream);
	mailstream_close(mSMTP -> stream);
	mSMTP -> stream = NULL;
	mailsmtp_free(mSMTP);
	mSMTP = NULL;
}

- (BOOL) isBusy {
	return (mMailThread != nil && [mMailThread isExecuting]);
}

@end

@implementation CTSMTPAsyncConnection (PrivateMethods)

- (void)sendMailThread {
	NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init];
	BOOL success;

	void (*progFxn)(size_t, size_t) = &smtpProgress;
	mSMTP = NULL;
	mSMTP = mailsmtp_new(30, progFxn);
	mSMTPObj = [[CTESMTP alloc] initWithResource:mSMTP];

	NSDictionary *theSettings = self.serverSettings;

	success = [mSMTPObj connectToServer:theSettings[@"server"]
		port:[theSettings[@"port"] unsignedIntValue]];
	if (!success) {
		goto error;
	}
	if ([mSMTPObj helo] == NO) {
		/* The server didn't support ESMTP, so switching to STMP */
		[mSMTPObj release];
		mSMTPObj = [[CTSMTP alloc] initWithResource:mSMTP];
		success = [mSMTPObj helo];
		if (!success) {
			goto error;
		}
	}
	if ([(NSNumber *) theSettings[@"tls"] boolValue]) {
		success = [mSMTPObj startTLS];
		if (!success) {
			goto error;
		}
	}
	if ([(NSNumber *) theSettings[@"auth"] boolValue]) {
		success = [mSMTPObj authenticateWithUsername:theSettings[@"username"]
			password:theSettings[@"password"]
			server:theSettings[@"server"]];
		if (!success) {
			goto error;
		}
	}

	CTCoreMessage *theMessage = self.message;
	success = [mSMTPObj setFrom:[[[theMessage from] anyObject] email]];
	if (!success) {
		goto error;
	}

	NSMutableSet *rcpts = [NSMutableSet set];
	[rcpts unionSet:[theMessage to]];
	[rcpts unionSet:[theMessage bcc]];
	[rcpts unionSet:[theMessage cc]];
	success = [mSMTPObj setRecipients:rcpts];
	if (!success) {
		goto error;
	}

	//send
	success = [mSMTPObj setData:[theMessage render]];
	if (success) {
		mStatus = CTSMTPAsyncSuccess;
	} else if (success && [mMailThread isCancelled]) {
		//libetpan was cancelled from another thread
		mStatus = CTSMTPAsyncCanceled;
	} else {
		mStatus = CTSMTPAsyncError;
	}
	[thePool drain];
	return;
error:
	mStatus = CTSMTPAsyncError;
	[thePool drain];
}

- (void)handleSmtpProgress:(NSNumber *)aProgress {
	//check if cancelled before sending an update
	if ([mMailThread isCancelled] && [NSThread currentThread] == mMailThread) {
		return;
	}

	unsigned int theProgress = [aProgress unsignedIntValue];
	if (theProgress > mLastProgress) {
		mLastProgress = theProgress;
		//call delegate
		if (mDelegate) {
			[mDelegate smtpProgress:mLastProgress];
		}
	}
}

- (void)threadWillExitHandler:(NSNotification *)aNote {
	if ([aNote object] != mMailThread) {
		return;
	}
	if (mDelegate) {
		[mDelegate smtpDidFinishSendingMessage:mStatus];
	}
	[self cleanupAfterThread];
}

- (void)cleanupAfterThread {
	[mSMTPObj release];
	mSMTPObj = nil;

	if (mSMTP) {
		if (mSMTP -> stream) {
			mailstream_cancel(mSMTP -> stream);
			mailstream_close(mSMTP -> stream);
			mSMTP -> stream = NULL;
		}
		mailsmtp_free(mSMTP);
		mSMTP = NULL;
	}

	[mServerSettings release];
	mServerSettings = nil;

	[mMessage release];
	mMessage = nil;

	[mMailThread release];
	mMailThread = nil;
}

@end
