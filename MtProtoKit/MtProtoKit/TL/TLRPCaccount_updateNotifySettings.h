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

@class TLInputNotifyPeer;
@class TLInputPeerNotifySettings;

@interface TLRPCaccount_updateNotifySettings : TLMetaRpc

@property (nonatomic, retain) TLInputNotifyPeer *peer;
@property (nonatomic, retain) TLInputPeerNotifySettings *settings;

- (Class)responseClass;

- (int)impliedResponseSignature;

@end

@interface TLRPCaccount_updateNotifySettings$account_updateNotifySettings : TLRPCaccount_updateNotifySettings


@end

