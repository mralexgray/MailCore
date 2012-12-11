/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */

#import <Foundation/Foundation.h>
#import "CTMIME_SinglePart.h"

@interface CTMIME_TextPart : CTMIME_SinglePart {
}
+ (id)mimeTextPartWithString: (NSString*)str;
- (id)initWithString: (NSString*)string;
- (void)setString: (NSString*)str;
@end
