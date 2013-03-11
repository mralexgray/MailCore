/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <libetpan/libetpan.h>

/**	CTCoreMessage is how you work with messages. The easiest way to instantiate a CTCoreMessage
	is to first setup a CTCoreAccount object and then get a CTCoreFolder object and then use it's
 	convenience method messageWithUID: to get a message object you can work with.
 	Anything that begins with "fetch", requires that an active network connection is present.	*/

@class CTCoreFolder, CTCoreAddress, CTCoreAttachment, CTMIME;
@interface CTCoreMessage : NSObject
{
	struct mailimf_single_fields 	*myFields;
//	NSUInteger 						mySequenceNumber;
}

@property	mailmessage *theMessage;

/**	If an error occurred (nil or return of NO) call this method to get the error	*/
/**	If a method returns nil or in the case of a BOOL returns NO, call this to get the error that occured	*/
@property (nonatomic, strong) NSError 		*lastError;
@property (nonatomic, strong) CTCoreFolder	*parentFolder;
/**	If the body structure has been fetched, this will contain the MIME structure	*/
@property (nonatomic, strong) CTMIME *mime;

/**	Used to instantiate an empty message object.	*/
- (id) init;
/**	Used to instantiate a message object with the contents of a mailmessage struct
	(a LibEtPan type). The mailmessage struct does not include any body information,
 	so after calling this method the message will have a body which is NULL.	*/
- (id) initWithMessageStruct:(struct mailmessage *)message;
/**	Used to instantiate a message object based off the contents of a file on disk.
	The file on disk must be a valid MIME message.	*/
- (id) initWithFileAtPath: 	(NSString*)path;
/**	Used to instantiate a message object based off a string that contains a valid MIME message	*/
- (id) initWithString: 		(NSString*)msgData;

/**	Returns YES if this message body structure has been downloaded, and NO otherwise.	*/
@property (readonly) BOOL hasBodyStructure;
/**	If the messages body structure hasn't been downloaded already it will be fetched from the server.
	The body structure is needed to get attachments or the message body
	@return Return YES on success, NO on error. Call method lastError to get error if one occurred	*/
- (BOOL) fetchBodyStructure;

/**	This method returns the parsed plain text message body as an NSString.
 	If a plaintext body isn't found an empty string is returned
	@set This method sets the message body. Plaintext only please!	*/
/**	This method returns the html body as an NSString.
	Use this method to set the body if you have HTML content.	*/
@property (nonatomic, strong) NSString 	*body, *htmlBody;

/** Returns a message body as an NSString.
	@param isHTML Pass in a BOOL pointer that will be set to YES if an HTML body is loaded
	First attempts to retrieve a plain text body, if that fails then tries for an HTML body.	*/
- (NSString*)bodyPreferringPlainText:(BOOL *)isHTML;

/**	A list of attachments this message has	*/
- (NSArray*) attachments;

/**	Add an attachment to the message.
Only used when sending e-mail	*/
- (void)addAttachment:(CTCoreAttachment *)attachment;

/**	Returns the subject of the message.
	Will set the subject of the message, use this when composing e-mail.	*/
@property (nonatomic, strong) NSString* subject;

/**	Returns the date as given in the Date mail field	*/
@property (weak, readonly) NSString *displayDate;
/**	Returns the date as given in the Date mail field	*/
@property (weak, readonly) NSDate *senderDate;
/**	Returns YES if the message is unread.	*/
@property (readonly) BOOL isUnread;
/**	Returns YES if the message is recent and unread.	*/
@property (readonly) BOOL isNew;
/**	Returns YES if the message is starred (flagged in IMAP terms).	*/
@property (readonly) BOOL isStarred;
/**	A machine readable ID that is guaranteed unique by the host that generated the message	*/
@property (weak, readonly) NSString *messageId;
/**	Returns an NSUInteger containing the messages UID. This number is unique across sessions	*/
@property (readonly) NSUInteger uid;
/**	Returns the message sequence number, this number cannot be used across sessions	*/
@property (readonly) NSUInteger sequenceNumber;
/**	Returns the message size in bytes	*/
@property (readonly) NSUInteger messageSize;
/**	Returns the message flags.
	The flags contain if there user has replied, forwarded, read, delete etc.
 	See MailCoreTypes.h for a list of constants	*/
@property (readonly) NSUInteger flags;

/**	Set the message sequence number.
This will NOT set any thing on the server.
 This is used to assign sequence numbers after retrieving the message list.	*/
- (void)setSequenceNumber:(NSUInteger)sequenceNumber;

@property (strong, nonatomic) NSImage *favicon;
@property (weak, readonly) NSString *fromDomain;
@property (weak, readonly) NSString *fromString;
@property (nonatomic, strong) NSSet *from;
/**	Parses the from list, the result is an NSSet containing CTCoreAddress's	*/
//- (NSSet *)from;
/**	Sets the message's from addresses
	@param addresses A NSSet containing CTCoreAddress's	*/
//- (void)setFrom:(NSSet *)addresses;

/**	Returns the sender.
The sender which isn't always the actual person who sent the message, it's usually the
 address of the machine that sent the message. In reality, this method isn't very useful, use from: instead.	*/
- (CTCoreAddress *)sender;

@property (nonatomic, strong) NSSet *to;
/**	Returns the list of people the message was sent to, returns an NSSet containing CTAddress's.	*/
//- (NSSet *)to;
/**	Sets the message's to addresses
	@param addresses A NSSet containing CTCoreAddress's	*/
//- (void)setTo:(NSSet *)addresses;

@property (nonatomic, strong) NSArray *inReplyTo;
/**	Return the list of messageIds from the in-reply-to field	*/
//- (NSArray *)inReplyTo;
/**	Sets the message's in-reply-to messageIds
	@param messageIds A NSArray containing NSString messageId's	*/
//- (void)setInReplyTo:(NSArray *)messageIds;

@property (nonatomic, strong) NSArray *references;
/**	Return the list of messageIds from the references field	*/
//- (NSArray *)references;
/**	Sets the message's references
	@param messageIds A NSArray containing NSString messageId's	*/
//- (void)setReferences:(NSArray *)messageIds;

@property (nonatomic, strong) NSSet *cc;
/**	Returns the list of people the message was cced to, returns an NSSet containing CTAddress's.	*/
//- (NSSet *)cc;
/**	Sets the message's cc addresses
	@param addresses A NSSet containing CTCoreAddress's	*/
//- (void)setCc:(NSSet *)addresses;
/**	Returns the list of people the message was bcced to, returns an NSSet containing CTAddress's.
	Sets the message's bcc addresses
 	@param addresses A NSSet containing CTCoreAddress's	*/
@property (nonatomic, strong) NSSet *bcc;

@property (nonatomic, strong) NSSet *replyTo;
/**	Returns the list of people the message was in reply-to, returns an NSSet containing CTAddress's.
	Sets the message's reply to addresses
	@param addresses A NSSet containing CTCoreAddress's	*/

/**	Returns the message rendered as the appropriate MIME and IMF content.
	Use this only if you want the raw encoding of the message.	*/
- (NSString*)render;
/**	Returns the message in the format Mail.app uses, Emlx. 
	This format stores the message headers, body, and flags.	*/
- (NSData *)messageAsEmlx;
/**	Fetches from the server the rfc822 content of the message, which are the headers and the message body.
	@return Return nil on error. Call method lastError to get error if one occurred	*/
- (NSString*)rfc822;
/**	Fetches from the server the rfc822 content of the message headers.
	@return Return nil on error. Call method lastError to get error if one occurred	*/
- (NSString*)rfc822Header;

- (BOOL) isEqual:(id)object;


/* Intended for advanced use only */
- (struct mailmessage*)	messageStruct;
- (mailimap*)			imapSession;
- (void) setBodyStructure:(struct mailmime*)		mime;
- (void) setFields: 	  (struct mailimf_fields*)	fields;
@end

//- (NSString*)subject;
//- (void)setSubject: (NSString*)subject;
//- (void)setReplyTo:(NSSet *)addresses;
//- (NSSet *)replyTo;
//- (void)setBcc:(NSSet *)addresses;
//- (NSSet *)bcc;
//- (NSString*)body;
//- (NSString*)htmlBody;
//- (void) setBody: (NSString*)body;
//- (void) setHTMLBody: (NSString*)body;

