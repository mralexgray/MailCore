/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */

#import "CTMIMEFactory.h"

#import "MailCoreTypes.h"
#import "MailCoreUtilities.h"
#import "CTMIME_SinglePart.h"
#import "CTMIME_MessagePart.h"
#import "CTMIME_MultiPart.h"
#import "CTMIME_TextPart.h"
#import "CTMIME.h"


@implementation CTMIMEFactory
+ (CTMIME *)createMIMEWithMIMEStruct:(struct mailmime *)mime 
						  forMessage:(struct mailmessage *)message {
	if (mime == nil) {
		return nil;
	}

	switch (mime -> mm_type) {
		case MAILMIME_SINGLE:
			return [CTMIMEFactory createMIMESinglePartWithMIMEStruct:mime
														  forMessage:message];
			break;
		case MAILMIME_MULTIPLE:
			return [[CTMIME_MultiPart alloc] initWithMIMEStruct:mime
													 forMessage:message];
			break;
		case MAILMIME_MESSAGE:
			return [[CTMIME_MessagePart alloc] initWithMIMEStruct:mime
														forMessage:message];
			break;
	}
	return NULL;
}

+ (CTMIME_SinglePart *)createMIMESinglePartWithMIMEStruct:(struct mailmime *)mime 
											   forMessage:(struct mailmessage *)message {
	struct mailmime_type *aType = mime -> mm_content_type -> ct_type;
	if (aType -> tp_type != MAILMIME_TYPE_DISCRETE_TYPE) {
		/* What do you do with a composite single part? */
		return nil;
	}
	CTMIME_SinglePart *content = nil;
	switch (aType -> tp_data.tp_discrete_type -> dt_type) {
		case MAILMIME_DISCRETE_TYPE_TEXT:
			content = [[CTMIME_TextPart alloc] initWithMIMEStruct:mime
													   forMessage:message];
			break;
		default:
			content = [[CTMIME_SinglePart alloc] initWithMIMEStruct:mime
														 forMessage:message];
			break;
	}
	return content;
}
@end 
