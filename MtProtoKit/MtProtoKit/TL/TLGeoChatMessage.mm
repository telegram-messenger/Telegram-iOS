#import "TLGeoChatMessage.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLMessageMedia.h"
#import "TLMessageAction.h"

@implementation TLGeoChatMessage

@synthesize chat_id = _chat_id;
@synthesize n_id = _n_id;

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

@implementation TLGeoChatMessage$geoChatMessageEmpty : TLGeoChatMessage


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x60311a9b;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x18e13300;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLGeoChatMessage$geoChatMessageEmpty *object = [[TLGeoChatMessage$geoChatMessageEmpty alloc] init];
    object.chat_id = metaObject->getInt32(0x7234457c);
    object.n_id = metaObject->getInt32(0x7a5601fb);
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
        value.primitive.int32Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x7a5601fb, value));
    }
}


@end

@implementation TLGeoChatMessage$geoChatMessage : TLGeoChatMessage

@synthesize from_id = _from_id;
@synthesize date = _date;
@synthesize message = _message;
@synthesize media = _media;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x4505f8e1;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1d1c67c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLGeoChatMessage$geoChatMessage *object = [[TLGeoChatMessage$geoChatMessage alloc] init];
    object.chat_id = metaObject->getInt32(0x7234457c);
    object.n_id = metaObject->getInt32(0x7a5601fb);
    object.from_id = metaObject->getInt32(0xf39a7861);
    object.date = metaObject->getInt32(0xb76958ba);
    object.message = metaObject->getString(0xc43b7853);
    object.media = metaObject->getObject(0x598de2e7);
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
        value.primitive.int32Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.from_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xf39a7861, value));
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
        value.nativeObject = self.message;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xc43b7853, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.media;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x598de2e7, value));
    }
}


@end

@implementation TLGeoChatMessage$geoChatMessageService : TLGeoChatMessage

@synthesize from_id = _from_id;
@synthesize date = _date;
@synthesize action = _action;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xd34fa24e;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfd776121;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLGeoChatMessage$geoChatMessageService *object = [[TLGeoChatMessage$geoChatMessageService alloc] init];
    object.chat_id = metaObject->getInt32(0x7234457c);
    object.n_id = metaObject->getInt32(0x7a5601fb);
    object.from_id = metaObject->getInt32(0xf39a7861);
    object.date = metaObject->getInt32(0xb76958ba);
    object.action = metaObject->getObject(0xc2d4a0f7);
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
        value.primitive.int32Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.from_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xf39a7861, value));
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
        value.nativeObject = self.action;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xc2d4a0f7, value));
    }
}


@end

