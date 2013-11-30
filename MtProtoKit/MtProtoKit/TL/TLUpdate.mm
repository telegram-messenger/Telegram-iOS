#import "TLUpdate.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLMessage.h"
#import "TLChatParticipants.h"
#import "TLUserStatus.h"
#import "TLcontacts_MyLink.h"
#import "TLcontacts_ForeignLink.h"
#import "TLPhoneCall.h"
#import "TLPhoneConnection.h"
#import "TLUserProfilePhoto.h"
#import "TLGeoChatMessage.h"
#import "TLEncryptedMessage.h"
#import "TLEncryptedChat.h"

@implementation TLUpdate


- (int32_t)TLconstructorSignature
{
    TGLog(@"constructorSignature is not implemented for base type");
    return 0;
}

- (int32_t)TLconstructorName
{
    TGLog(@"constructorName is not implemented for base type");
    return 0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)__unused metaObject
{
    TGLog(@"TLbuildFromMetaObject is not implemented for base type");
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
    TGLog(@"TLfillFieldsWithValues is not implemented for base type");
}


@end

@implementation TLUpdate$updateNewMessage : TLUpdate

@synthesize message = _message;
@synthesize pts = _pts;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x13abdb3;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1238c8f8;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateNewMessage *object = [[TLUpdate$updateNewMessage alloc] init];
    object.message = metaObject->getObject(0xc43b7853);
    object.pts = metaObject->getInt32(0x4fc5f572);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.message;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xc43b7853, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x4fc5f572, value));
    }
}


@end

@implementation TLUpdate$updateMessageID : TLUpdate

@synthesize n_id = _n_id;
@synthesize random_id = _random_id;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4e90bfd6;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfbcd22b5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateMessageID *object = [[TLUpdate$updateMessageID alloc] init];
    object.n_id = metaObject->getInt32(0x7a5601fb);
    object.random_id = metaObject->getInt64(0xca5a160a);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.random_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xca5a160a, value));
    }
}


@end

@implementation TLUpdate$updateReadMessages : TLUpdate

@synthesize messages = _messages;
@synthesize pts = _pts;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc6649e31;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xbb94dc27;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateReadMessages *object = [[TLUpdate$updateReadMessages alloc] init];
    object.messages = metaObject->getArray(0x8c97b94f);
    object.pts = metaObject->getInt32(0x4fc5f572);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.messages;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x8c97b94f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x4fc5f572, value));
    }
}


@end

@implementation TLUpdate$updateDeleteMessages : TLUpdate

@synthesize messages = _messages;
@synthesize pts = _pts;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xa92bfe26;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x5e1b624e;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateDeleteMessages *object = [[TLUpdate$updateDeleteMessages alloc] init];
    object.messages = metaObject->getArray(0x8c97b94f);
    object.pts = metaObject->getInt32(0x4fc5f572);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.messages;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x8c97b94f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x4fc5f572, value));
    }
}


@end

@implementation TLUpdate$updateRestoreMessages : TLUpdate

@synthesize messages = _messages;
@synthesize pts = _pts;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd15de04d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8c21e474;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateRestoreMessages *object = [[TLUpdate$updateRestoreMessages alloc] init];
    object.messages = metaObject->getArray(0x8c97b94f);
    object.pts = metaObject->getInt32(0x4fc5f572);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.messages;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x8c97b94f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.pts;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x4fc5f572, value));
    }
}


@end

@implementation TLUpdate$updateUserTyping : TLUpdate

@synthesize user_id = _user_id;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6baa8508;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x83cd7672;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateUserTyping *object = [[TLUpdate$updateUserTyping alloc] init];
    object.user_id = metaObject->getInt32(0xafdf4073);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xafdf4073, value));
    }
}


@end

@implementation TLUpdate$updateChatUserTyping : TLUpdate

@synthesize chat_id = _chat_id;
@synthesize user_id = _user_id;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x3c46cfe6;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xecc51515;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateChatUserTyping *object = [[TLUpdate$updateChatUserTyping alloc] init];
    object.chat_id = metaObject->getInt32(0x7234457c);
    object.user_id = metaObject->getInt32(0xafdf4073);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.chat_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x7234457c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xafdf4073, value));
    }
}


@end

@implementation TLUpdate$updateChatParticipants : TLUpdate

@synthesize participants = _participants;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x7761198;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xcc141a77;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateChatParticipants *object = [[TLUpdate$updateChatParticipants alloc] init];
    object.participants = metaObject->getObject(0xe0e25c28);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.participants;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xe0e25c28, value));
    }
}


@end

@implementation TLUpdate$updateUserStatus : TLUpdate

@synthesize user_id = _user_id;
@synthesize status = _status;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1bfbd823;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x48b263c8;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateUserStatus *object = [[TLUpdate$updateUserStatus alloc] init];
    object.user_id = metaObject->getInt32(0xafdf4073);
    object.status = metaObject->getObject(0xab757700);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.status;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xab757700, value));
    }
}


@end

@implementation TLUpdate$updateUserName : TLUpdate

@synthesize user_id = _user_id;
@synthesize first_name = _first_name;
@synthesize last_name = _last_name;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xda22d9ad;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xe13ece0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateUserName *object = [[TLUpdate$updateUserName alloc] init];
    object.user_id = metaObject->getInt32(0xafdf4073);
    object.first_name = metaObject->getString(0xa604f05d);
    object.last_name = metaObject->getString(0x10662e0e);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.first_name;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xa604f05d, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.last_name;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x10662e0e, value));
    }
}


@end

@implementation TLUpdate$updateContactRegistered : TLUpdate

@synthesize user_id = _user_id;
@synthesize date = _date;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x2575bbb9;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa8b24c75;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateContactRegistered *object = [[TLUpdate$updateContactRegistered alloc] init];
    object.user_id = metaObject->getInt32(0xafdf4073);
    object.date = metaObject->getInt32(0xb76958ba);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xb76958ba, value));
    }
}


@end

@implementation TLUpdate$updateContactLink : TLUpdate

@synthesize user_id = _user_id;
@synthesize my_link = _my_link;
@synthesize foreign_link = _foreign_link;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x51a48a9a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x78cd1dc2;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateContactLink *object = [[TLUpdate$updateContactLink alloc] init];
    object.user_id = metaObject->getInt32(0xafdf4073);
    object.my_link = metaObject->getObject(0xc9f9705a);
    object.foreign_link = metaObject->getObject(0x1c49ffaf);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.my_link;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xc9f9705a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.foreign_link;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x1c49ffaf, value));
    }
}


@end

@implementation TLUpdate$updateContactLocated : TLUpdate

@synthesize contacts = _contacts;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5f83b963;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x35d0d4f0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateContactLocated *object = [[TLUpdate$updateContactLocated alloc] init];
    object.contacts = metaObject->getArray(0x48dc7107);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeVector;
        value.nativeObject = self.contacts;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x48dc7107, value));
    }
}


@end

@implementation TLUpdate$updateActivation : TLUpdate

@synthesize user_id = _user_id;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6f690963;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1b92ff80;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateActivation *object = [[TLUpdate$updateActivation alloc] init];
    object.user_id = metaObject->getInt32(0xafdf4073);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xafdf4073, value));
    }
}


@end

@implementation TLUpdate$updateNewAuthorization : TLUpdate

@synthesize auth_key_id = _auth_key_id;
@synthesize date = _date;
@synthesize device = _device;
@synthesize location = _location;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x8f06529a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xedb1c6b6;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateNewAuthorization *object = [[TLUpdate$updateNewAuthorization alloc] init];
    object.auth_key_id = metaObject->getInt64(0x17400465);
    object.date = metaObject->getInt32(0xb76958ba);
    object.device = metaObject->getString(0x8bec2723);
    object.location = metaObject->getString(0x504a1f06);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.auth_key_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x17400465, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xb76958ba, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.device;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x8bec2723, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.location;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x504a1f06, value));
    }
}


@end

@implementation TLUpdate$updatePhoneCallRequested : TLUpdate

@synthesize phone_call = _phone_call;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xdad7490e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd2a99b80;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updatePhoneCallRequested *object = [[TLUpdate$updatePhoneCallRequested alloc] init];
    object.phone_call = metaObject->getObject(0x77bcd691);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.phone_call;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x77bcd691, value));
    }
}


@end

@implementation TLUpdate$updatePhoneCallConfirmed : TLUpdate

@synthesize n_id = _n_id;
@synthesize a_or_b = _a_or_b;
@synthesize connection = _connection;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5609ff88;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x65fc818b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updatePhoneCallConfirmed *object = [[TLUpdate$updatePhoneCallConfirmed alloc] init];
    object.n_id = metaObject->getInt64(0x7a5601fb);
    object.a_or_b = metaObject->getBytes(0xd2c3dff4);
    object.connection = metaObject->getObject(0xb5b12f84);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeBytes;
        value.nativeObject = self.a_or_b;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xd2c3dff4, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.connection;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xb5b12f84, value));
    }
}


@end

@implementation TLUpdate$updatePhoneCallDeclined : TLUpdate

@synthesize n_id = _n_id;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x31ae2cc2;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xd99045cb;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updatePhoneCallDeclined *object = [[TLUpdate$updatePhoneCallDeclined alloc] init];
    object.n_id = metaObject->getInt64(0x7a5601fb);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x7a5601fb, value));
    }
}


@end

@implementation TLUpdate$updateUserPhoto : TLUpdate

@synthesize user_id = _user_id;
@synthesize date = _date;
@synthesize photo = _photo;
@synthesize previous = _previous;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x95313b0c;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x88f33ef8;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateUserPhoto *object = [[TLUpdate$updateUserPhoto alloc] init];
    object.user_id = metaObject->getInt32(0xafdf4073);
    object.date = metaObject->getInt32(0xb76958ba);
    object.photo = metaObject->getObject(0xe6c52372);
    object.previous = metaObject->getBool(0x34505af2);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.user_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xafdf4073, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xb76958ba, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.photo;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xe6c52372, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.previous;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x34505af2, value));
    }
}


@end

@implementation TLUpdate$updateNewGeoChatMessage : TLUpdate

@synthesize message = _message;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5a68e3f7;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc732b5d8;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateNewGeoChatMessage *object = [[TLUpdate$updateNewGeoChatMessage alloc] init];
    object.message = metaObject->getObject(0xc43b7853);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.message;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xc43b7853, value));
    }
}


@end

@implementation TLUpdate$updateNewEncryptedMessage : TLUpdate

@synthesize message = _message;
@synthesize qts = _qts;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x12bcbd9a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x8cfe55d7;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateNewEncryptedMessage *object = [[TLUpdate$updateNewEncryptedMessage alloc] init];
    object.message = metaObject->getObject(0xc43b7853);
    object.qts = metaObject->getInt32(0x3c528e55);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.message;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xc43b7853, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.qts;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x3c528e55, value));
    }
}


@end

@implementation TLUpdate$updateEncryptedChatTyping : TLUpdate

@synthesize chat_id = _chat_id;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x1710f156;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xaeaf448f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateEncryptedChatTyping *object = [[TLUpdate$updateEncryptedChatTyping alloc] init];
    object.chat_id = metaObject->getInt32(0x7234457c);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.chat_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x7234457c, value));
    }
}


@end

@implementation TLUpdate$updateEncryption : TLUpdate

@synthesize chat = _chat;
@synthesize date = _date;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xb4a2e88d;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x4f822e35;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateEncryption *object = [[TLUpdate$updateEncryption alloc] init];
    object.chat = metaObject->getObject(0xa8950b16);
    object.date = metaObject->getInt32(0xb76958ba);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.chat;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xa8950b16, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xb76958ba, value));
    }
}


@end

@implementation TLUpdate$updateEncryptedMessagesRead : TLUpdate

@synthesize chat_id = _chat_id;
@synthesize max_date = _max_date;
@synthesize date = _date;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x38fe25b7;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb8e3d3c4;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLUpdate$updateEncryptedMessagesRead *object = [[TLUpdate$updateEncryptedMessagesRead alloc] init];
    object.chat_id = metaObject->getInt32(0x7234457c);
    object.max_date = metaObject->getInt32(0xf4d47b51);
    object.date = metaObject->getInt32(0xb76958ba);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.chat_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x7234457c, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.max_date;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xf4d47b51, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xb76958ba, value));
    }
}


@end

