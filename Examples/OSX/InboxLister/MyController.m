#import "MyController.h"

@implementation MyController

- (id)init
{
	if (self != super.init ) return nil;
	_myAccount 	= CTCoreAccount.new;
//	_messages 	= NSA.new;
    _q 	 		= NSOQ.new;
	
	return self;
}

+ (NSSet*) keyPathsForValuesAffectingInboxCt { return NSSET(@"messages"); }

- (NSUI) inboxCt
{
	NSUI theCount;
	BOOL itWorked = [_inbox totalMessageCount:&theCount];
	return itWorked ? theCount : 0;
}

- (void) setMessages:(NSA*)messages {
	[self willChangeValueForKey:@"messages"];
	_messages = NSA.new;
	[self didChangeValueForKey:@"messages"];
	[messages each:^(id object){
		[[NSThread mainThread]performBlock:^{
			
			BOOL canya = [object fetchBodyStructure];
			NSLog(@"can fetch body:%@  for %@", StringFromBOOL(canya), object);
			!canya ?: [self willChangeValueForKey:@"messages"];
			_messages = [_messages arrayByAddingObject:object];
			!canya ?: [self didChangeValueForKey:@"messages"];
		}];
	}];

}
- (IBAction)connect:(id)sender
{
    NSLog(@"Connecting...");


	[_q addOperationWithBlock:^{

		int portNumber = [port intValue];
		BOOL ssl = [(NSBUTT*)useTLS state] == NSOnState;
		
		[_myAccount connectToServer:[server stringValue]
							  port:portNumber > 0 ? portNumber : 993
					connectionType:ssl ? CONNECTION_TYPE_TLS : CONNECTION_TYPE_PLAIN
						  authType:IMAP_AUTH_TYPE_PLAIN
							 login:[username stringValue]
						  password:[password stringValue]];
		
		if(![_myAccount isConnected]) {
			NSRunCriticalAlertPanel(@"Connection Error", @"Please check your connection details and try again.", @"OK", nil, nil);
			return;
		}
		
		 NSLog(@"Folders %@", [_myAccount allFolders]);

		self.inbox = [_myAccount folderWithPath:@"INBOX"];
//		[self bind:@"inboxCt" toObject:_inbox withKeyPath:@"totalMessageCount" options:nil];

		NSLog(@"INBOX %@", _inbox);
		// set the toIndex to 0 so all messages are loaded
		self.messages = [_inbox messagesFromSequenceNumber:1 to:0 withFetchAttributes:CTFetchAttrEnvelope];
//		NSLog(@"Done getting list of messages... %@", messageSet);
	}];
//    NSMutableSet *messagesProxy = [self mutableSetValueForKey:@"messages"];
//	[messageSet each:^(id obj) {
//		BOOL canya = [obj fetchBodyStructure];
//		NSLog(@"can fetch body:%@  for %@", StringFromBOOL(canya), obj);
//		!canya ?: [self.messages addObject:obj];
////        [messa/gesProxy addObject:msg];
//    }];
}


@end
