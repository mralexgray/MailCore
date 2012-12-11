/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */

#import <Foundation/Foundation.h>
#import "CTBareAttachment.h"

/**	 A message's attachment	*/
@interface CTCoreAttachment : CTBareAttachment {
    NSData *mData;
}
@property(retain) NSData *data;

/**	Load the attachment from a local file
 NOTE: This currently only works on Mac OS X, use initWithData:contentType:filename: instead on iOS	*/

- (id)initWithContentsOfFile: (NSString*)path;
/**	Create an attachment from a chunk of data
@param data The actual attachment data
	@param contentType The MIME content type you'd like to use
	@param filename The filename you'd like the attachment to be given in the e-mail message	*/
- (id)initWithData:(NSData *)data contentType: (NSString*)contentType filename: (NSString*)filename;

/**	Used to save the attachment locally	*/
- (BOOL) writeToFile: (NSString*)path;
@end
