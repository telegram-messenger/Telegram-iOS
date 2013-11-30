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

@class TLInputPeer;
@class TLInputGeoChat;

@interface TLInputNotifyPeer : NSObject <TLObject>


@end

@interface TLInputNotifyPeer$inputNotifyPeer : TLInputNotifyPeer

@property (nonatomic, retain) TLInputPeer *peer;

@end

@interface TLInputNotifyPeer$inputNotifyUsers : TLInputNotifyPeer


@end

@interface TLInputNotifyPeer$inputNotifyChats : TLInputNotifyPeer


@end

@interface TLInputNotifyPeer$inputNotifyAll : TLInputNotifyPeer


@end

@interface TLInputNotifyPeer$inputNotifyGeoChatPeer : TLInputNotifyPeer

@property (nonatomic, retain) TLInputGeoChat *peer;

@end

