/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */

#import <Foundation/Foundation.h>
#import "CTMIME.h"

typedef void (^CTProgressBlock)(size_t curr, size_t max);

@interface CTMIME_SinglePart : CTMIME {
	struct mailmime *mMime;
	struct mailmessage *mMessage;
	struct mailmime_single_fields *mMimeFields;

	NSData *mData;
	BOOL mAttached;
	BOOL mFetched;
	NSString *mFilename;
	NSString *mContentId;
	NSError *lastError;
}
@property(nonatomic) BOOL attached;
@property(nonatomic) BOOL fetched;
@property(nonatomic, retain) NSString *filename;
@property(nonatomic, retain) NSString *contentId;
@property(nonatomic, retain) NSData *data;
@property(nonatomic, readonly) size_t size;

/*
 If an error occurred (nil or return of NO) call this method to get the error	*/
@property(nonatomic, retain) NSError *lastError;

+ (id)mimeSinglePartWithData:(NSData *)data;
- (id)initWithData:(NSData *)data;
- (BOOL) fetchPart;
- (BOOL) fetchPartWithProgress:(CTProgressBlock)block;
@end
