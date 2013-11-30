/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLcontacts_Contacts : NSObject <TLObject>


@end

@interface TLcontacts_Contacts$contacts_contacts : TLcontacts_Contacts

@property (nonatomic, retain) NSArray *contacts;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLcontacts_Contacts$contacts_contactsNotModified : TLcontacts_Contacts


@end

