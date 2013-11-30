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


@interface TLP_Q_inner_data : NSObject <TLObject>

@property (nonatomic, retain) NSData *pq;
@property (nonatomic, retain) NSData *p;
@property (nonatomic, retain) NSData *q;
@property (nonatomic, retain) NSData *nonce;
@property (nonatomic, retain) NSData *server_nonce;
@property (nonatomic, retain) NSData *n_new_nonce;

@end

@interface TLP_Q_inner_data$p_q_inner_data : TLP_Q_inner_data


@end

