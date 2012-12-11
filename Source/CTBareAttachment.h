/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */

#import <Foundation/Foundation.h>
#import "CTMIME_SinglePart.h"

@class CTCoreAttachment;

/**	Represents an attachment before it has been fully fetched.	*/
@interface CTBareAttachment : NSObject {
	CTMIME_SinglePart *mMIMEPart;
	NSString *mFilename;
	NSString *mContentType;
}
@property(retain) NSString *filename;
@property(retain) NSString *contentType;
@property(readonly) CTMIME_SinglePart *part;

-(NSString*)decodedFilename;
- (id)initWithMIMESinglePart:(CTMIME_SinglePart *)part;
/**	Fetches the full attachment	*/
- (CTCoreAttachment *)fetchFullAttachment;
/**	Fetches the full attachment
Also has a progress handler	*/
- (CTCoreAttachment *)fetchFullAttachmentWithProgress:(CTProgressBlock)block;
@end
