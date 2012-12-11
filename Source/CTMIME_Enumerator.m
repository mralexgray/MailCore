/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */

#import "CTMIME_Enumerator.h"

#import "CTMIME.h"
#import "CTMIME_MultiPart.h"
#import "CTMIME_MessagePart.h"

@implementation CTMIME_Enumerator
- (id)initWithMIME:(CTMIME *)mime {
    self = [super init];
    if (self) {
        mToVisit = [[NSMutableArray alloc] init];
        [mToVisit addObject:mime];
    }
    return self;
}

- (NSArray *)allObjects {
    NSMutableArray *objects = [NSMutableArray array];

    id obj;
    while ((obj = [self nextObject])) {
        [objects addObject:obj];
    }
    return objects;
}

- (id)nextObject {
    if ([mToVisit count] == 0) {
        return nil;
    }

    id mime = [mToVisit objectAtIndex:0];
    if ([mime isKindOfClass:[CTMIME_MessagePart class]]) {
        if ([mime content] != nil) {
            [mToVisit addObject:[mime content]];
        }
    }
    else if ([mime isKindOfClass:[CTMIME_MultiPart class]]) {
        NSEnumerator *enumer = [[mime content] objectEnumerator];
        CTMIME *subpart;
        while ((subpart = [enumer nextObject])) {
            [mToVisit addObject:subpart];
        }
    }
    [mToVisit removeObjectAtIndex:0];
    return mime;
}

- (void)dealloc {
    [mToVisit release];
    [super dealloc];
}
@end
