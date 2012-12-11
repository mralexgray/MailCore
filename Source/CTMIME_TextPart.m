/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */

#import "CTMIME_TextPart.h"

#import <libetpan/libetpan.h>
#import "MailCoreTypes.h"

@implementation CTMIME_TextPart
+ (id)mimeTextPartWithString: (NSString*)str {
	return [[[CTMIME_TextPart alloc] initWithString:str] autorelease];
}

- (id)initWithString: (NSString*)string {
	self = [super init];
	if (self) {
		[self setString:string];
	}
	return self;
}

- (id)content {
	if (mMimeFields != NULL) {
		// We are decoding from an existing msg so read
		// the charset and convert from that to UTF-8
		char *converted;
		size_t converted_len;

		char *source_charset = mMimeFields->fld_content_charset;
		if (source_charset == NULL) {
			source_charset = DEST_CHARSET;
		}

		int r = charconv_buffer(DEST_CHARSET, source_charset,
								self.data.bytes, self.data.length,
								&converted, &converted_len);
		NSString *str = @"";
		if (r == MAIL_CHARCONV_NO_ERROR) {
			NSData *newData = [NSData dataWithBytes:converted length:converted_len];
			str = [[[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding] autorelease];
		}
		charconv_buffer_free(converted);
		return str;
	} else {
		// Don't have a charset available so treat data as UTF-8
		// This will happen when we are creating a msg and not decoding
		// an existing one
		return [[[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding] autorelease];
	}
}

- (void)setString: (NSString*)str {
	self.data = [str dataUsingEncoding:NSUTF8StringEncoding];
	// The data is all local, so we don't want it to do any fetching
	self.fetched = YES;
}

- (struct mailmime *)buildMIMEStruct {
	struct mailmime_fields *mime_fields;
	struct mailmime *mime_sub;
	struct mailmime_content *content;
	struct mailmime_parameter *param;
	int r;

	/* text/plain part */
	mime_fields = mailmime_fields_new_encoding(MAILMIME_MECHANISM_QUOTED_PRINTABLE);
	content = mailmime_content_new_with_str("text/plain");
	param = mailmime_parameter_new(strdup("charset"), strdup(DEST_CHARSET));
	r = clist_append(content->ct_parameters, param);
	mime_sub = mailmime_new_empty(content, mime_fields);
	NSString *str = [self content];
	NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
	r = mailmime_set_body_text(mime_sub, strdup([data bytes]), [data length]);
	return mime_sub;
}
@end
