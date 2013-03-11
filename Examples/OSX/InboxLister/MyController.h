/* MyController */


@interface MyController : NSObject

@property IBOutlet id password;
@property IBOutlet id port;
@property IBOutlet id server;
@property IBOutlet id username;
@property IBOutlet id useTLS;
@property IBOutlet NSPopUpButton *foldersButton;

@property (NATOM, STRNG) NSMA 			*allFolders;
@property (RONLY) 		 NSUI 			mailboxCt;
@property (NATOM, STRNG) CTCoreAccount	*account;
@property (NATOM, STRNG) CTCoreFolder	*folder;
@property (NATOM, STRNG) NSS				*selectedFolderName;

@property (NATOM, STRNG) NSMA 			*messages;
@property (NATOM, STRNG) NSOQ 			*q;
@property (RONLY) 	 	 NSI 			messageRange;
@property (NATOM) 	 	 NSI			rangeIncrement;
@property (NATOM) 		 NSUI 			fetchQuantity;

- (IBAction)connect:(id)sender;
- (IBAction)loadFolder:(id)sender;
- (IBAction)loadMore:(id)sender;

@end
