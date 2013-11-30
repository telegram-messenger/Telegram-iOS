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

@class TLInputFile;
@class TLInputPhotoCrop;
@class TLInputPhoto;

@interface TLInputChatPhoto : NSObject <TLObject>


@end

@interface TLInputChatPhoto$inputChatPhotoEmpty : TLInputChatPhoto


@end

@interface TLInputChatPhoto$inputChatUploadedPhoto : TLInputChatPhoto

@property (nonatomic, retain) TLInputFile *file;
@property (nonatomic, retain) TLInputPhotoCrop *crop;

@end

@interface TLInputChatPhoto$inputChatPhoto : TLInputChatPhoto

@property (nonatomic, retain) TLInputPhoto *n_id;
@property (nonatomic, retain) TLInputPhotoCrop *crop;

@end

