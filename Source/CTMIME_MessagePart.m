/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */


#import "CTMIME_MessagePart.h"
#import <libetpan/libetpan.h>
#import "MailCoreTypes.h"
#import "CTMIMEFactory.h"

@implementation CTMIME_MessagePart
+ (id)mimeMessagePartWithContent:(CTMIME *)mime {
	return [[[CTMIME_MessagePart alloc] initWithContent:mime] autorelease];
}

- (id)initWithMIMEStruct:(struct mailmime *)mime 
			  forMessage:(struct mailmessage *)message {
	self = [super initWithMIMEStruct:mime forMessage:message];
	if (self) {
		struct mailmime *content = mime->mm_data.mm_message.mm_msg_mime;
		myMessageContent = [[CTMIMEFactory createMIMEWithMIMEStruct:content
														 forMessage:message] retain];
		myFields = mime->mm_data.mm_message.mm_fields;
	}
	return self;
}

- (id)initWithContent:(CTMIME *)messageContent {
	self = [super init];
	if (self) {
		[self setContent:messageContent];
	}
	return self;
}

- (void)dealloc {
	[myMessageContent release];
	[super dealloc];
}

- (void)setContent:(CTMIME *)aContent {
	[aContent retain];
	[myMessageContent release];
	myMessageContent = aContent;
}

- (id)content {
	return myMessageContent;
}

- (struct mailmime *)buildMIMEStruct {
	struct mailmime *mime = mailmime_new_message_data([myMessageContent buildMIMEStruct]);
	if (myFields != NULL) {
		mailmime_set_imf_fields(mime, myFields);
	}
	return mime;
}

- (void)setIMFFields:(struct mailimf_fields *)imfFields {
	myFields = imfFields;
}
@end
