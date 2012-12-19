/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */

#import "CTCoreAccount.h"
#import "CTCoreFolder.h"
#import "CTXlistResult.h"
#import "MailCoreTypes.h"
#import "MailCoreUtilities.h"

@implementation CTCoreAccount
@synthesize lastError, pathDelimiter, connected;

- (id)init
{
	if (self != super.init ) return nil;
	connected = NO;
	myStorage = mailstorage_new(NULL);
	assert(myStorage != NULL);
	return self;
}

+ (NSSet*) keyPathsForValuesAffectingAllFolders { return [NSSet setWithArray:@[@"connected"]]; }

- (BOOL) connectToServer: (NSString*)server port:(int)port
		connectionType:(int)conType authType:(int)authType
		login: (NSString*)login password: (NSString*)password
{
	int err, imap_cached = 0;
	const char* auth_type_to_pass = authType == IMAP_AUTH_TYPE_SASL_CRAM_MD5 ?	"CRAM-MD5" : NULL;

	err = imap_mailstorage_init_sasl(myStorage,
									 (char *)[server cStringUsingEncoding:NSUTF8StringEncoding],
									 (uint16_t)port, NULL,
									 conType,
									 auth_type_to_pass,
									 NULL,
									 NULL, NULL,
									 (char *)[login cStringUsingEncoding:NSUTF8StringEncoding], (char *)[login cStringUsingEncoding:NSUTF8StringEncoding],
									 (char *)[password cStringUsingEncoding:NSUTF8StringEncoding], NULL,
									 imap_cached, NULL);

	if (err != MAILIMAP_NO_ERROR) {
		self.lastError = MailCoreCreateErrorFromIMAPCode(err);
		return NO;
	}
	err = mailstorage_connect(myStorage);
	if (err == MAIL_ERROR_LOGIN) {
		self.lastError = MailCoreCreateError(err, @"Invalid username or password");
		return NO;
	} else if (err != MAILIMAP_NO_ERROR) {
		self.lastError = MailCoreCreateErrorFromIMAPCode(err);
		return NO;
	}
	self.connected = YES;
	return YES;
}

- (NSSet *)capabilities
{
	NSMutableSet *capabilitiesSet = NSMutableSet.new;
	struct mailimap_capability_data *capabilities;
	int r = mailimap_capability(self.session, &capabilities);
	if (r != MAILIMAP_NO_ERROR) {
		self.lastError = MailCoreCreateErrorFromIMAPCode(r);
		return nil;
	}
	for(clistiter * cur = clist_begin(capabilities -> cap_list); cur != NULL ; cur = cur -> next) {
		struct mailimap_capability *capability;
		capability = clist_content(cur);
		NSString *name =
		capability -> cap_type == MAILIMAP_CAPABILITY_AUTH_TYPE ?
			[@"AUTH=" stringByAppendingString:[NSString stringWithUTF8String: capability -> cap_data.cap_auth_type]] :
		capability -> cap_type == MAILIMAP_CAPABILITY_NAME ?
			[NSString stringWithUTF8String: capability -> cap_data.cap_name] : nil;
		!name ?: [capabilitiesSet addObject:name];
	}
	mailimap_capability_data_free(capabilities);
	return capabilitiesSet;
}

- (void)disconnect
{
	!connected ?: ^{		self.connected = NO;
							mailstorage_disconnect(myStorage);
	}();
}

- (CTCoreFolder *)folderWithPath: (NSString*)path
{
	return [CTCoreFolder.alloc initWithPath:path inAccount:self];
}


- (mailimap *)session
{
	struct imap_cached_session_state_data 	*cached_data;

	mailsession *session = myStorage -> sto_session;
	if(session == nil) return nil;
	if (strcasecmp( session -> sess_driver -> sess_name, "imap-cached" ) == 0) {
		cached_data = session -> sess_data;
		session = cached_data -> imap_ancestor;
	}
	struct imap_session_state_data *data = session -> sess_data;
	return data -> imap_session;
}


- (struct mailstorage *)storageStruct {	return myStorage;	}


- (NSSet *)subscribedFolders
{
	struct mailimap_mailbox_list 	*mailboxStruct;
	clist 							*subscribedList;
	clistiter 						*cur;
	NSString 						*mailboxNameObject;
	char 							*mailboxName;

	NSMutableSet *subscribedFolders = NSMutableSet.new;

	//Fill the subscribed folder array
	int err = mailimap_lsub([self session], "", "*", &subscribedList);
	if ( err != MAILIMAP_NO_ERROR ) {
		self.lastError = MailCoreCreateErrorFromIMAPCode(err);
		return nil;
	}
	for(cur = clist_begin(subscribedList); cur != NULL; cur = cur -> next) {
		mailboxStruct = cur -> data;
		struct mailimap_mbx_list_flags *flags = mailboxStruct -> mb_flag;
		BOOL selectable = flags ? !(flags -> mbf_type==MAILIMAP_MBX_LIST_FLAGS_SFLAG && flags -> mbf_sflag==MAILIMAP_MBX_LIST_SFLAG_NOSELECT) : YES;

		if (selectable) {
			mailboxName = mailboxStruct -> mb_name;
			// Per RFC 3501, mailbox names must use 7-bit enconding (UTF-7).
			mailboxNameObject = (NSString*)CFStringCreateWithCString(NULL, mailboxName, kCFStringEncodingUTF7_IMAP);

			self.pathDelimiter = mailboxStruct -> mb_delimiter ?
				[NSString stringWithFormat:@"%c", mailboxStruct -> mb_delimiter] :
				@"/";
			[subscribedFolders addObject:mailboxNameObject];
			[mailboxNameObject release];
		}
	}
	mailimap_list_result_free(subscribedList);
	return subscribedFolders;
}

- (NSSet *)allFolders
{
	NSLog(@"requesting allfolders");
	if (!connected) return nil;
	
	struct mailimap_mailbox_list 	*mailboxStruct;
	clist 							*allList;
	clistiter 						*cur;
	NSString 						*mailboxNameObject;
	char 							*mailboxName;

	NSMutableSet *allFolders = NSMutableSet.new;

	//Now, fill the all folders array // TODO Fix this so it doesn't use *
	int err = mailimap_list([self session], "", "*", &allList);
	if (err != MAILIMAP_NO_ERROR) {
		self.lastError = MailCoreCreateErrorFromIMAPCode(err);
		return nil;
	}
	for(cur = clist_begin(allList); cur != NULL; cur = cur -> next )
	{
		mailboxStruct = cur -> data;
		struct mailimap_mbx_list_flags *flags = mailboxStruct -> mb_flag;
		BOOL selectable = flags ? !( flags -> mbf_type == MAILIMAP_MBX_LIST_FLAGS_SFLAG && flags -> mbf_sflag==MAILIMAP_MBX_LIST_SFLAG_NOSELECT) : YES;
		if (selectable) {
			mailboxName = mailboxStruct -> mb_name;
			// Per RFC 3501, mailbox names must use 7-bit enconding (UTF-7).
			mailboxNameObject = (NSString*)CFStringCreateWithCString(NULL, mailboxName, kCFStringEncodingUTF7_IMAP);
			
			self.pathDelimiter = mailboxStruct -> mb_delimiter ?
				[NSString stringWithFormat:@"%c", mailboxStruct -> mb_delimiter] :
				@"/";
			[allFolders addObject:mailboxNameObject];
			[mailboxNameObject release];
		}
	}
	mailimap_list_result_free(allList);
	return allFolders;
}

- (NSSet *)allFoldersExtended
{
	struct mailimap_mailbox_list 	*mailboxStruct;
	struct mailimap_mbx_list_oflag 	*oflagStruct;
	clist 							*allList;
	clistiter 						*flagIter, 			*cur;
	NSString 						*mailboxNameObject,	*flagNameObject;
	char 							*mailboxName,		*flagName;
	
	NSMutableSet *allFolders = NSMutableSet.new;
	CTXlistResult *listResult;
	
	//	Now, fill the all folders array	//	TODO Fix this so it doesn't use *
	int err = mailimap_xlist([self session], "", "*", &allList);
	if (err != MAILIMAP_NO_ERROR) {
		self.lastError = MailCoreCreateErrorFromIMAPCode(err);
		return nil;
	}
	for(cur = clist_begin(allList); cur != NULL; cur = cur -> next)
	{
		mailboxStruct = cur -> data;
		struct mailimap_mbx_list_flags *flags = mailboxStruct -> mb_flag;
		BOOL selectable = flags ? !( flags -> mbf_type == MAILIMAP_MBX_LIST_FLAGS_SFLAG && flags -> mbf_sflag==MAILIMAP_MBX_LIST_SFLAG_NOSELECT) : YES;
		if (selectable) {
			mailboxName = mailboxStruct -> mb_name;
			// Per RFC 3501, mailbox names must use 7-bit enconding (UTF-7).
			mailboxNameObject = (NSString*)CFStringCreateWithCString(NULL, mailboxName, kCFStringEncodingUTF7_IMAP);
			
			self.pathDelimiter = mailboxStruct -> mb_delimiter ?
				[NSString stringWithFormat:@"%c", mailboxStruct -> mb_delimiter] :
				@"/";
			
			listResult = CTXlistResult.new;
			listResult.name = mailboxNameObject;
			[mailboxNameObject release];
			
			if (flags) {
				for (flagIter = clist_begin( flags -> mbf_oflags); flagIter != NULL; flagIter = flagIter -> next) {
					oflagStruct 	= flagIter -> data;
					flagName 		= oflagStruct -> of_flag_ext;
					flagNameObject 	= (NSString*)CFStringCreateWithCString(NULL, flagName, kCFStringEncodingUTF7_IMAP);
					[listResult addFlag:flagNameObject];
					[flagNameObject release];
				}
			}
			[allFolders addObject:listResult];
			[listResult release];
		}
	}
	mailimap_list_result_free(allList);
	return allFolders;
}

- (void)dealloc
{
	mailstorage_disconnect(myStorage);
	mailstorage_free(myStorage);
	self.lastError = nil;
	self.pathDelimiter = nil;
	[super dealloc];
}

@end
