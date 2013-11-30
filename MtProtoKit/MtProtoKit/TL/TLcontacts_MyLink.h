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


@interface TLcontacts_MyLink : NSObject <TLObject>


@end

@interface TLcontacts_MyLink$contacts_myLinkEmpty : TLcontacts_MyLink


@end

@interface TLcontacts_MyLink$contacts_myLinkRequested : TLcontacts_MyLink

@property (nonatomic) bool contact;

@end

@interface TLcontacts_MyLink$contacts_myLinkContact : TLcontacts_MyLink


@end

