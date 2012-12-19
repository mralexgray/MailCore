/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */

#import <Foundation/Foundation.h>
#import <libetpan/libetpan.h>
#import "MailCoreTypes.h"

/**	CTCoreAccount is the base class with which you establish a connection to the
 IMAP server. After establishing a connection with CTCoreAccount you can access
 all of the folders (I use the term folder instead of mailbox) on the server.	*/

@class CTCoreFolder;

@interface CTCoreAccount : NSObject
{
	struct mailstorage *myStorage;
}

/**	If an error occurred (nil or return of NO) call this method to get the error	*/
@property(nonatomic, strong) NSError *lastError;
@property(nonatomic, strong) NSString *pathDelimiter;

/**	Retrieves the list of all the available folders from the server.
	@return Returns a NSSet which contains NSStrings of the folders pathnames, nil on error	*/
@property (weak, readonly) NSSet *allFolders;

/**	Retrieves the list of all the available folders from the server using the extended list command (XLIST).
	This is only supported by Gmail.
	@return Returns a NSSet which contains CTXlistResults, nil on error	*/
@property (weak, readonly) NSSet *allFoldersExtended;

/**	Retrieves a list of only the subscribed folders from the server.
	@return Returns a NSSet which contains NSStrings of the folders pathnames, nil on error	*/
@property (weak, readonly) NSSet *subscribedFolders;

/**	If you have the path of a folder on the server use this method to retrieve just the one folder.
	@param path A NSString specifying the path of the folder to retrieve from the server.
	@return Returns a CTCoreFolder.	*/
- (CTCoreFolder *)folderWithPath: (NSString*)path;

/**	This method initiates the connection to the server.
	@param server The address of the server.
	@param port The port to connect to.
	@param connnectionType What kind of connection to use, it can be one of these three values:
 CTConnectionTypePlain, CTConnectionTypeStartTLS, CTConnectionTypeTryStartTLS, CTConnectionTypeTLS. See MailCoreTypes.h for more information
	@param authType The authentication type, only CTImapAuthTypePlain is currently supported
	@param login The username to connect with.
	@param password The password to use to connect.
	@return Return YES on success, NO on error. Call method lastError to get error if one occurred	*/
- (BOOL) connectToServer: (NSS*)server port:(int)port connectionType:(int)conType authType:(int)authType
						login: (NSS*)login password: (NSS*)password;

/**	This method returns the current connection status.
	@return Returns YES or NO as the status of the connection.	*/
@property (getter=isConnected) BOOL connected;

/**	Terminates the connection. If you terminate this connection it will also affect the
 connectivity of CTCoreFolders and CTMessages that rely on this account.	*/
- (void)disconnect;

- (NSSet *)capabilities;

/* Intended for advanced use only */
- (mailimap*)			session;
- (struct mailstorage*) storageStruct;
@end
