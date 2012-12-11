/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */

#import "CTBareAttachment.h"

#import "MailCoreUtilities.h"
#import "MailCoreTypes.h"
#import "CTMIME_SinglePart.h"
#import "CTCoreAttachment.h"

@implementation CTBareAttachment
@synthesize contentType=mContentType;
@synthesize filename=mFilename;

- (id)initWithMIMESinglePart:(CTMIME_SinglePart *)part {
    self = [super init];
    if (self) {
        mMIMEPart = [part retain];
        self.filename = mMIMEPart.filename;
        self.contentType = mMIMEPart.contentType;
    }
    return self;
}

-(NSString*)decodedFilename {
    return MailCoreDecodeMIMEPhrase((char *)[self.filename UTF8String]);
}

- (NSString*)description {
    return [NSString stringWithFormat:@"ContentType: %@\tFilename: %@",
                self.contentType, self.filename];
}

- (CTCoreAttachment *)fetchFullAttachment {
    return [self fetchFullAttachmentWithProgress:^(size_t curr, size_t max) {}];
}

- (CTCoreAttachment *)fetchFullAttachmentWithProgress:(CTProgressBlock)block {
    [mMIMEPart fetchPartWithProgress:block];
    CTCoreAttachment *attach = [[CTCoreAttachment alloc] initWithData:mMIMEPart.data
                                                          contentType:self.contentType filename:self.filename];
    return [attach autorelease];
}

- (CTMIME_SinglePart *)part {
    return mMIMEPart;
}

- (void)dealloc {
    [mMIMEPart release];
    [mFilename release];
    [mContentType release];
    [super dealloc];
}
@end
