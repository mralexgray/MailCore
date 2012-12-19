/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */

#import "CTMIME_MultiPart.h"
#import "CTMIME_MessagePart.h"
#import <libetpan/libetpan.h>
#import "MailCoreTypes.h"
#import "CTMIMEFactory.h"


@implementation CTMIME_MultiPart
+ (id)mimeMultiPart {
	return [[CTMIME_MultiPart alloc] init];
}

- (id)initWithMIMEStruct:(struct mailmime *)mime forMessage:(struct mailmessage *)message {
	self = [super initWithMIMEStruct:mime forMessage:message];
	if (self) {
		myContentList = [[NSMutableArray alloc] init];
		clistiter *cur = clist_begin(mime -> mm_data.mm_multipart.mm_mp_list);
		for (; cur != NULL; cur=clist_next(cur)) {
			CTMIME *content = [CTMIMEFactory createMIMEWithMIMEStruct:clist_content(cur) forMessage:message];
			if (content != nil) {
				[myContentList addObject:content];
			}
		}
	}
	return self;
}

- (id)init {
	self = [super init];
	if (self) {
		myContentList = [[NSMutableArray alloc] init];
		self.contentType = @"multipart/mixed";
	}
	return self;
}


- (void)addMIMEPart:(CTMIME *)mime {
	[myContentList addObject:mime];
}

- (id)content {
	return myContentList;
}

- (struct mailmime *)buildMIMEStruct {
	struct mailmime *mime = mailmime_multiple_new([self.contentType UTF8String]);

	NSEnumerator *enumer = [myContentList objectEnumerator];

	CTMIME *part;
	while ((part = [enumer nextObject])) {
		mailmime_smart_add_part(mime, [part buildMIMEStruct]);
	}
	return mime;
}
@end
