/* MyController */


@interface MyController : NSObject

@property (ASS) IBOutlet AZPropellerView *prop;

@property (ASS) IBOutlet NSTXTF *password;
@property (ASS) IBOutlet NSBUTT *port;
@property (ASS) IBOutlet NSTXTF *server;
@property (ASS) IBOutlet NSTXTF *username;
@property (ASS) IBOutlet NSBUTT *useTLS;
@property (ASS) IBOutlet NSPopUpButton *foldersButton;

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
