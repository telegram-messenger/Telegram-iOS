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


@interface TLcontacts_ImportedContacts : NSObject <TLObject>

@property (nonatomic, retain) NSArray *imported;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLcontacts_ImportedContacts$contacts_importedContacts : TLcontacts_ImportedContacts


@end

