/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */

#import <Foundation/Foundation.h>
#import "MailCoreTypes.h"

/**	This is not a class you instantiate! It has only two class methods, and that is all you need to send e-mail.
 First use CTCoreMessage to compose an e-mail and then pass the e-mail to the method sendMessage: with
 the necessary server settings and CTSMTPConnection will send the message.	*/

@class CTCoreMessage, CTCoreAddress;

@interface CTSMTPConnection : NSObject {

}
/**	This method...it sends e-mail.
	@param message	Just pass in a CTCoreMessage which has the body, subject, from, to etc. that you want
	@param server The server address
	@param username The username, if there is none then pass in an empty string. For some servers you may have to specify the username as username@domain
	@param password The password, if there is none then pass in an empty string.
	@param port The port to use, the standard port is 25
	@param connectionType What kind of connection, either: CTSMTPConnectionTypePlain, CTSMTPConnectionTypeStartTLS, CTSMTPConnectionTypeTLS
	@param auth Pass in YES if you would like to use SASL authentication
	@param error Will contain an error when the method returns NO
	@return Returns YES on success, NO on error	*/
+ (BOOL)sendMessage:(CTCoreMessage *)message
			 server: (NSString*)server
		   username: (NSString*)username
		   password: (NSString*)password
			   port:(unsigned int)port
	 connectionType:(CTSMTPConnectionType)connectionType
			useAuth:(BOOL)auth
			  error:(NSError **)error;

/**	Use this method to test the user's credentials.
This is useful for account setup. You can have the user enter in their credentials and then verify they work without sending a message.
	@param server The server address
	@param username The username, if there is none then pass in an empty string. For some servers you may have to specify the username as username@domain
	@param password The password, if there is none then pass in an empty string.
	@param port The port to use, the standard port is 25
	@param connectionType What kind of connection, either: CTSMTPConnectionTypePlain, CTSMTPConnectionTypeStartTLS, CTSMTPConnectionTypeTLS
	@param auth Pass in YES if you would like to use SASL authentication
	@param error Will contain an error when the method returns NO
	@return Returns YES on success, NO on error
 */
+ (BOOL)canConnectToServer: (NSString*)server
				  username: (NSString*)username
				  password: (NSString*)password
					  port:(unsigned int)port
			connectionType:(CTSMTPConnectionType)connectionType
				   useAuth:(BOOL)auth
					 error:(NSError **)error;

@end
