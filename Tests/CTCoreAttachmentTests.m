/** MailCore * Copyright (C) 2007 - Matt Ronge * All rights reserved. * Redistribution and use in source and binary forms, with or without * modification, are permitted provided that the following conditions * are met:  .edistributions of source code must retain the above copyright	notice, this list of conditions and the following disclaimer.	2. Redistributions in binary form must reproduce the above copyright		notice, this list of conditions and the following disclaimer in	documentation and/or other materials provided with the distribution.	3. Neither the name of the MailCore project nor the names of its	contributors may be used to endorse or promote products derived	from this software without specific prior written permission. */

#import "CTCoreAttachmentTests.h"


@implementation CTCoreAttachmentTests
- (void)testJPEG {
	NSString *path = [NSString stringWithFormat:@"%@%@",filePrefix,@"TestData/DSC_6201.jpg"];
	CTCoreAttachment *attach = [[CTCoreAttachment alloc] initWithContentsOfFile:path];
	STAssertEqualObjects(@"image/jpeg", [attach contentType], @"The content-type should have been image/jpeg");
	STAssertTrue([attach data] != nil, @"Data should not have been nil");
	[attach release];
}

- (void)testPNG {
	NSString *path = [NSString stringWithFormat:@"%@%@",filePrefix,@"TestData/DSC_6202.png"];
	CTCoreAttachment *attach = [[CTCoreAttachment alloc] initWithContentsOfFile:path];
	STAssertEqualObjects(@"image/png", [attach contentType], @"The content-type should have been image/png");
	STAssertTrue([attach data] != nil, @"Data should not have been nil");
	[attach release];
}

- (void)testTIFF {
	NSString *path = [NSString stringWithFormat:@"%@%@",filePrefix,@"TestData/DSC_6193.tif"];
	CTCoreAttachment *attach = [[CTCoreAttachment alloc] initWithContentsOfFile:path];
	STAssertEqualObjects(@"image/tiff", [attach contentType], @"The content-type should have been image/TIFF");
	STAssertTrue([attach data] != nil, @"Data should not have been nil");
	[attach release];
}

- (void)testNEF {
	NSString *path = [NSString stringWithFormat:@"%@%@",filePrefix,@"TestData/DSC_6204.NEF"];
	CTCoreAttachment *attach = [[CTCoreAttachment alloc] initWithContentsOfFile:path];
	STAssertEqualObjects(@"application/octet-stream", [attach contentType], 
		@"The content-type should have been application/octet-stream");
	STAssertTrue([attach data] != nil, @"Data should not have been nil");
	[attach release];
}
@end
