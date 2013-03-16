#import "MyController.h"

@implementation MyController
@synthesize password, username, useTLS, server;

- (id)init	{								if (self != super.init ) return nil;
	_fetchQuantity 	= 100;					_rangeIncrement = 1;
	_account 		= CTCoreAccount.new; 	_q 	 			= NSOQ.new;
	_messages		= NSMA.new;				_allFolders		= NSMA.new;		return self;
}
+ (NSSet*) keyPathsForValuesAffectingMailboxCt 		{ return NSSET(@"folder"); }

+ (NSSet*) keyPathsForValuesAffectingMessageRange 	{ return NSSET(@"mailboxCt"); }

- (NSUI) mailboxCt	{	NSUI theCount;	return [_folder totalMessageCount:&theCount] ? theCount : 0;	}

- (NSI) messageRange
{
	NSLog(@"base_range:%ld", _rangeIncrement);
	if ( self.mailboxCt == 0) return -1;
	if ( self.mailboxCt != 0) return (self.mailboxCt - (_rangeIncrement * _fetchQuantity)) + 1;
	return 0;
}

- (IBAction)connect:(id)sender	{	NSLog(@"Connecting..."); [_prop spin];		[_q addOperationWithBlock:^{

	[_account   connectToServer: [server stringValue]
						   port: [_port intValue] > 0 	? [_port intValue] : 993
				 connectionType: [(NSBUTT*)useTLS state] == NSOnState ? CONNECTION_TYPE_TLS : CONNECTION_TYPE_PLAIN
					   authType: IMAP_AUTH_TYPE_PLAIN
						  login: username.stringValue
					   password: password.stringValue];

	if(![_account isConnected]) {	NSRunCriticalAlertPanel(@"Connection Error", @"Please check your connection details and try again.", @"OK", nil, nil);	return;		}

	self.allFolders = _account.allFolders.allObjects.mutableCopy;	}];
}
- (IBAction)loadFolder:(id)sender
{
	if (_selectedFolderName != [sender titleOfSelectedItem]) self.selectedFolderName = [sender titleOfSelectedItem]; else return;
	self.rangeIncrement = 1;		NSLog( @"Folders %@", _account.allFolders );
	self.folder = [_account folderWithPath:_selectedFolderName]; //@"GV"];
	//		[self bind:@"inboxCt" toObject:_inbox withKeyPath:@"totalMessageCount" options:nil];
	NSLog(@"Active Folder is %@", _folder);
	[self loadMore:nil];
	// set the toIndex to 0 so all messages are loaded

}

- (IBAction)loadMore:(id)sender
{
	if (self.messageRange == -1) 	return;
	while (self.messageRange == 0) 	LOG_EXPR([self messageRange]);

	NSLog(@"MessageRange %ld" ,  self.messageRange);
	NSA *all = [_folder messagesFromSequenceNumber:self.messageRange to:self.messageRange + _fetchQuantity withFetchAttributes:CTFetchAttrEnvelope];
	NSLog(@"all count: %ld", all.count);
	self.rangeIncrement++;
	[all eachWithIndex:^(CTCoreMessage* m, NSInteger idx) {
		[_messages doesNotContainObject:m] ? [self insertObject:m inMessagesAtIndex:_messages.count] : nil;
	 }];

	//		NSLog(@"Done getting list of messages... %@", messageSet);
	//	}];
	//	NSMutableSet *messagesProxy = [self mutableSetValueForKey:@"messages"];
	//	[messageSet each:^(id obj) {
	//		BOOL canya = [obj fetchBodyStructure];
	//		NSLog(@"can fetch body:%@  for %@", StringFromBOOL(canya), obj);
	//		!canya ?: [self.messages addObject:obj];
	////		[messa/gesProxy addObject:msg];
	//	}];
	[_prop stop];
}

- (NSUI)countOfMessages											{	return self.messages.count; 				}

- (id)objectInMessagesAtIndex:(NSUI)index						{	return self.messages[index];	 			}

- (void)removeObjectFromMessagesAtIndex:(NSUI)index 				{ 	[self.messages removeObjectAtIndex:index];	}

- (void)insertObject:(CTCoreMessage *)object inMessagesAtIndex:(NSUI)index { self.messages[index] = object; 		}


//- (void) setMessages:(NSA*)messages	{
//	[messages each:^(id object){
////		[_q addOperationWithBlock:^{
//			BOOL canya = [object fetchBodyStructure];
////			NSLog(@"props: %@", [object classPropertiesAndTypes]);// propertiesPlease]);
//			NSLog(@"can fetch body:%@  for %@", StringFromBOOL(canya), object);
//			if (canya) [self insertObject:object inMessagesAtIndex:_messages.count];// i arrayByAddingObject:object];
////			!canya ?: [self didChangeValueForKey:@"messages"];
////		}];
//	}];
//}

@end
