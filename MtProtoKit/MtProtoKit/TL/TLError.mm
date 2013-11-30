#import "TLError.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLError

@synthesize code = _code;

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

@implementation TLError$error : TLError

@synthesize text = _text;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0xc4b9f9bb;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xa0494afb;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLError$error *object = [[TLError$error alloc] init];
    object.code = metaObject->getInt32(0x806ab544);
    object.text = metaObject->getString(0x94f1580d);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.code;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x806ab544, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.text;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x94f1580d, value));
    }
}


@end

@implementation TLError$richError : TLError

@synthesize type = _type;
@synthesize description = _description;
@synthesize debug = _debug;
@synthesize request_params = _request_params;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x59aefc57;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x1d86ae1f;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLError$richError *object = [[TLError$richError alloc] init];
    object.code = metaObject->getInt32(0x806ab544);
    object.type = metaObject->getString(0x9211ab0a);
    object.description = metaObject->getString(0x4baddf54);
    object.debug = metaObject->getString(0x859bf05a);
    object.request_params = metaObject->getString(0xb8ccdd50);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.code;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x806ab544, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.type;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x9211ab0a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.description;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x4baddf54, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.debug;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x859bf05a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypeString;
        value.nativeObject = self.request_params;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xb8ccdd50, value));
    }
}


@end

