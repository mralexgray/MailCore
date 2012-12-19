/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */

#import "CTCoreAttachment.h"
#import "MailCoreTypes.h"

@implementation CTCoreAttachment
@synthesize data=mData;

- (id)initWithContentsOfFile: (NSString*)path
{
	NSData 	 *data 			= [NSData dataWithContentsOfFile:path];
	NSString *filePathExt 	= path.pathExtension;
	NSString *contentType 	= nil;
	NSString *typesPath 	= [NSBundle.mainBundle pathForResource:@"types" ofType:@"plist"];
	NSDictionary *contentTypes = [NSDictionary dictionaryWithContentsOfFile:typesPath];

	for (NSString *key in [contentTypes allKeys]) {
		NSArray *fileExtensions = contentTypes[key];
		for (NSString *ext in fileExtensions) {
			if ([filePathExt isEqual:ext]) {
				contentType = key;
				break;
			}
		}
		if (contentType != nil) break;
	}
	// We couldn't find a content-type, set it to something generic
	contentType = contentType ?: @"application/octet-stream";
	NSString *filename = path.lastPathComponent;
	return [self initWithData:data contentType:contentType filename:filename];
}

- (id)initWithData:(NSData *)data contentType: (NSString*)contentType 
		filename: (NSString*)filename
{
	if (self != super.init ) return nil;
	self.data = data;
	self.contentType = contentType;
	self.filename = filename;
	return self;
}

- (BOOL) writeToFile: (NSString*)path {	return [mData writeToFile:path atomically:YES];	}


@end
