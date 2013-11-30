#import "TLMessage.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLPeer.h"
#import "TLMessageMedia.h"
#import "TLMessageAction.h"

@implementation TLMessage

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

@implementation TLMessage$messageEmpty : TLMessage


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x83e5de54;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x777e7e3c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLMessage$messageEmpty *object = [[TLMessage$messageEmpty alloc] init];
    object.n_id = metaObject->getInt32(0x7a5601fb);
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
}


@end

@implementation TLMessage$message : TLMessage

@synthesize from_id = _from_id;
@synthesize to_id = _to_id;
@synthesize out = _out;
@synthesize unread = _unread;
@synthesize date = _date;
@synthesize message = _message;
@synthesize media = _media;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x22eb6aba;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xc43b7853;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLMessage$message *object = [[TLMessage$message alloc] init];
    object.n_id = metaObject->getInt32(0x7a5601fb);
    object.from_id = metaObject->getInt32(0xf39a7861);
    object.to_id = metaObject->getObject(0x98822893);
    object.out = metaObject->getBool(0xcb409efc);
    object.unread = metaObject->getBool(0x5027354e);
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
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.to_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x98822893, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.out;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xcb409efc, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.unread;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x5027354e, value));
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

@implementation TLMessage$messageForwarded : TLMessage

@synthesize fwd_from_id = _fwd_from_id;
@synthesize fwd_date = _fwd_date;
@synthesize from_id = _from_id;
@synthesize to_id = _to_id;
@synthesize out = _out;
@synthesize unread = _unread;
@synthesize date = _date;
@synthesize message = _message;
@synthesize media = _media;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x5f46804;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x349f2f8b;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLMessage$messageForwarded *object = [[TLMessage$messageForwarded alloc] init];
    object.n_id = metaObject->getInt32(0x7a5601fb);
    object.fwd_from_id = metaObject->getInt32(0x3d97b085);
    object.fwd_date = metaObject->getInt32(0xb08aba8b);
    object.from_id = metaObject->getInt32(0xf39a7861);
    object.to_id = metaObject->getObject(0x98822893);
    object.out = metaObject->getBool(0xcb409efc);
    object.unread = metaObject->getBool(0x5027354e);
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
        value.primitive.int32Value = self.n_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x7a5601fb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.fwd_from_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x3d97b085, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.fwd_date;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xb08aba8b, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.from_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xf39a7861, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.to_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x98822893, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.out;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xcb409efc, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.unread;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x5027354e, value));
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

@implementation TLMessage$messageService : TLMessage

@synthesize from_id = _from_id;
@synthesize to_id = _to_id;
@synthesize out = _out;
@synthesize unread = _unread;
@synthesize date = _date;
@synthesize action = _action;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9f8d60bb;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xfa56953c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLMessage$messageService *object = [[TLMessage$messageService alloc] init];
    object.n_id = metaObject->getInt32(0x7a5601fb);
    object.from_id = metaObject->getInt32(0xf39a7861);
    object.to_id = metaObject->getObject(0x98822893);
    object.out = metaObject->getBool(0xcb409efc);
    object.unread = metaObject->getBool(0x5027354e);
    object.date = metaObject->getInt32(0xb76958ba);
    object.action = metaObject->getObject(0xc2d4a0f7);
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
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.from_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xf39a7861, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.to_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x98822893, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.out;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xcb409efc, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.unread;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x5027354e, value));
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

