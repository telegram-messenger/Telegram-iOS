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


@interface TLClient_DH_Inner_Data : NSObject <TLObject>

@property (nonatomic, retain) NSData *nonce;
@property (nonatomic, retain) NSData *server_nonce;
@property (nonatomic) int64_t retry_id;
@property (nonatomic, retain) NSData *g_b;

@end

@interface TLClient_DH_Inner_Data$client_DH_inner_data : TLClient_DH_Inner_Data


@end

