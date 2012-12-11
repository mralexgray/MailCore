/* MyController */

#import <Cocoa/Cocoa.h>
#import <MailCore/MailCore.h>

@interface MyController : NSObject
{
    IBOutlet id password;
    IBOutlet id port;
    IBOutlet id server;
    IBOutlet id username;
    IBOutlet id useTLS;
}
- (IBAction)connect:(id)sender;

@property (RONLY) NSUI inboxCt;
@property (NATOM, STRNG) CTCoreAccount	*myAccount;
@property (NATOM, STRNG) CTCoreFolder	*inbox;

@property (NATOM, STRNG) NSMA *messages;
@property (NATOM, STRNG) NSOQ *q;
@end
