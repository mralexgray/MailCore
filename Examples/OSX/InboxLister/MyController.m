#import "MyController.h"

@implementation MyController

- (id)init
{
	if (self != super.init ) return nil;
	_myAccount 	= CTCoreAccount.new;
	_messages	= NSMA.new;
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

- (void) setMessages:(NSA*)messages
{
	[messages each:^(id object){
//		[_q addOperationWithBlock:^{

			BOOL canya = [object fetchBodyStructure];
//			NSLog(@"props: %@", [object classPropertiesAndTypes]);// propertiesPlease]);
			NSLog(@"can fetch body:%@  for %@", StringFromBOOL(canya), object);
			if (canya) [self insertObject:object inMessagesAtIndex:_messages.count];// i arrayByAddingObject:object];
//			!canya ?: [self didChangeValueForKey:@"messages"];
//		}];
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


- (NSUI)countOfMessages											{	return self.messages.count; 				}

- (id)objectInMessagesAtIndex:(NSUI)index						{	return self.messages[index];	 			}

- (void)removeObjectFromMessagesAtIndex:(NSUI)index 				{ 	[self.messages removeObjectAtIndex:index];	}

- (void)insertObject:(CTCoreMessage *)object inMessagesAtIndex:(NSUI)index { self.messages[index] = object; 		}


@end
