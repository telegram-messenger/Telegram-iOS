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


@interface TLcontacts_ForeignLink : NSObject <TLObject>


@end

@interface TLcontacts_ForeignLink$contacts_foreignLinkUnknown : TLcontacts_ForeignLink


@end

@interface TLcontacts_ForeignLink$contacts_foreignLinkRequested : TLcontacts_ForeignLink

@property (nonatomic) bool has_phone;

@end

@interface TLcontacts_ForeignLink$contacts_foreignLinkMutual : TLcontacts_ForeignLink


@end

