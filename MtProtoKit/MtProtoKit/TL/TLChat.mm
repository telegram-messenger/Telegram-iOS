#import "TLChat.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"

#import "TLChatPhoto.h"
#import "TLGeoPoint.h"

@implementation TLChat

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

@implementation TLChat$chatEmpty : TLChat


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x9ba2d800;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xaae285ba;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLChat$chatEmpty *object = [[TLChat$chatEmpty alloc] init];
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

@implementation TLChat$chat : TLChat

@synthesize title = _title;
@synthesize photo = _photo;
@synthesize participants_count = _participants_count;
@synthesize date = _date;
@synthesize left = _left;
@synthesize version = _version;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x6e9c9bc7;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa8950b16;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLChat$chat *object = [[TLChat$chat alloc] init];
    object.n_id = metaObject->getInt32(0x7a5601fb);
    object.title = metaObject->getString(0xcdebf414);
    object.photo = metaObject->getObject(0xe6c52372);
    object.participants_count = metaObject->getInt32(0xeb6aa445);
    object.date = metaObject->getInt32(0xb76958ba);
    object.left = metaObject->getBool(0x4a1fdec2);
    object.version = metaObject->getInt32(0x4ea810e9);
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
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.title;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xcdebf414, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.photo;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xe6c52372, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.participants_count;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xeb6aa445, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xb76958ba, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.left;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x4a1fdec2, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.version;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x4ea810e9, value));
    }
}


@end

@implementation TLChat$chatForbidden : TLChat

@synthesize title = _title;
@synthesize date = _date;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xfb0ccc41;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x5ec2aeb5;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLChat$chatForbidden *object = [[TLChat$chatForbidden alloc] init];
    object.n_id = metaObject->getInt32(0x7a5601fb);
    object.title = metaObject->getString(0xcdebf414);
    object.date = metaObject->getInt32(0xb76958ba);
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
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.title;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xcdebf414, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xb76958ba, value));
    }
}


@end

@implementation TLChat$geoChat : TLChat

@synthesize access_hash = _access_hash;
@synthesize title = _title;
@synthesize address = _address;
@synthesize venue = _venue;
@synthesize geo = _geo;
@synthesize photo = _photo;
@synthesize participants_count = _participants_count;
@synthesize date = _date;
@synthesize checked_in = _checked_in;
@synthesize version = _version;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x75eaea5a;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xb55a2d7c;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLChat$geoChat *object = [[TLChat$geoChat alloc] init];
    object.n_id = metaObject->getInt32(0x7a5601fb);
    object.access_hash = metaObject->getInt64(0x8f305224);
    object.title = metaObject->getString(0xcdebf414);
    object.address = metaObject->getString(0x1a893fea);
    object.venue = metaObject->getString(0x689665bb);
    object.geo = metaObject->getObject(0x3c803e05);
    object.photo = metaObject->getObject(0xe6c52372);
    object.participants_count = metaObject->getInt32(0xeb6aa445);
    object.date = metaObject->getInt32(0xb76958ba);
    object.checked_in = metaObject->getBool(0x85f50fcd);
    object.version = metaObject->getInt32(0x4ea810e9);
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
        value.primitive.int64Value = self.access_hash;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x8f305224, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.title;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xcdebf414, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.address;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x1a893fea, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.venue;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x689665bb, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.geo;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x3c803e05, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeObject;
        value.nativeObject = self.photo;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xe6c52372, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.participants_count;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xeb6aa445, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.date;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xb76958ba, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveBool;
        value.primitive.boolValue = self.checked_in;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x85f50fcd, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.version;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x4ea810e9, value));
    }
}


@end

