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

@class TLMessage;
@class TLChatParticipants;
@class TLUserStatus;
@class TLcontacts_MyLink;
@class TLcontacts_ForeignLink;
@class TLPhoneCall;
@class TLPhoneConnection;
@class TLUserProfilePhoto;
@class TLGeoChatMessage;
@class TLEncryptedMessage;
@class TLEncryptedChat;

@interface TLUpdate : NSObject <TLObject>


@end

@interface TLUpdate$updateNewMessage : TLUpdate

@property (nonatomic, retain) TLMessage *message;
@property (nonatomic) int32_t pts;

@end

@interface TLUpdate$updateMessageID : TLUpdate

@property (nonatomic) int32_t n_id;
@property (nonatomic) int64_t random_id;

@end

@interface TLUpdate$updateReadMessages : TLUpdate

@property (nonatomic, retain) NSArray *messages;
@property (nonatomic) int32_t pts;

@end

@interface TLUpdate$updateDeleteMessages : TLUpdate

@property (nonatomic, retain) NSArray *messages;
@property (nonatomic) int32_t pts;

@end

@interface TLUpdate$updateRestoreMessages : TLUpdate

@property (nonatomic, retain) NSArray *messages;
@property (nonatomic) int32_t pts;

@end

@interface TLUpdate$updateUserTyping : TLUpdate

@property (nonatomic) int32_t user_id;

@end

@interface TLUpdate$updateChatUserTyping : TLUpdate

@property (nonatomic) int32_t chat_id;
@property (nonatomic) int32_t user_id;

@end

@interface TLUpdate$updateChatParticipants : TLUpdate

@property (nonatomic, retain) TLChatParticipants *participants;

@end

@interface TLUpdate$updateUserStatus : TLUpdate

@property (nonatomic) int32_t user_id;
@property (nonatomic, retain) TLUserStatus *status;

@end

@interface TLUpdate$updateUserName : TLUpdate

@property (nonatomic) int32_t user_id;
@property (nonatomic, retain) NSString *first_name;
@property (nonatomic, retain) NSString *last_name;

@end

@interface TLUpdate$updateContactRegistered : TLUpdate

@property (nonatomic) int32_t user_id;
@property (nonatomic) int32_t date;

@end

@interface TLUpdate$updateContactLink : TLUpdate

@property (nonatomic) int32_t user_id;
@property (nonatomic, retain) TLcontacts_MyLink *my_link;
@property (nonatomic, retain) TLcontacts_ForeignLink *foreign_link;

@end

@interface TLUpdate$updateContactLocated : TLUpdate

@property (nonatomic, retain) NSArray *contacts;

@end

@interface TLUpdate$updateActivation : TLUpdate

@property (nonatomic) int32_t user_id;

@end

@interface TLUpdate$updateNewAuthorization : TLUpdate

@property (nonatomic) int64_t auth_key_id;
@property (nonatomic) int32_t date;
@property (nonatomic, retain) NSString *device;
@property (nonatomic, retain) NSString *location;

@end

@interface TLUpdate$updatePhoneCallRequested : TLUpdate

@property (nonatomic, retain) TLPhoneCall *phone_call;

@end

@interface TLUpdate$updatePhoneCallConfirmed : TLUpdate

@property (nonatomic) int64_t n_id;
@property (nonatomic, retain) NSData *a_or_b;
@property (nonatomic, retain) TLPhoneConnection *connection;

@end

@interface TLUpdate$updatePhoneCallDeclined : TLUpdate

@property (nonatomic) int64_t n_id;

@end

@interface TLUpdate$updateUserPhoto : TLUpdate

@property (nonatomic) int32_t user_id;
@property (nonatomic) int32_t date;
@property (nonatomic, retain) TLUserProfilePhoto *photo;
@property (nonatomic) bool previous;

@end

@interface TLUpdate$updateNewGeoChatMessage : TLUpdate

@property (nonatomic, retain) TLGeoChatMessage *message;

@end

@interface TLUpdate$updateNewEncryptedMessage : TLUpdate

@property (nonatomic, retain) TLEncryptedMessage *message;
@property (nonatomic) int32_t qts;

@end

@interface TLUpdate$updateEncryptedChatTyping : TLUpdate

@property (nonatomic) int32_t chat_id;

@end

@interface TLUpdate$updateEncryption : TLUpdate

@property (nonatomic, retain) TLEncryptedChat *chat;
@property (nonatomic) int32_t date;

@end

@interface TLUpdate$updateEncryptedMessagesRead : TLUpdate

@property (nonatomic) int32_t chat_id;
@property (nonatomic) int32_t max_date;
@property (nonatomic) int32_t date;

@end

