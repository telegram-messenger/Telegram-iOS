#import "TLMsgDetailedInfo.h"

#import "../NSInputStream+TL.h"
#import "../NSOutputStream+TL.h"


@implementation TLMsgDetailedInfo

@synthesize answer_msg_id = _answer_msg_id;
@synthesize bytes = _bytes;
@synthesize status = _status;

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

@implementation TLMsgDetailedInfo$msg_detailed_info : TLMsgDetailedInfo

@synthesize msg_id = _msg_id;

- (int32_t)TLconstructorSignature
{
    return (int32_t)0x276d3ec6;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0xdee9ed72;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLMsgDetailedInfo$msg_detailed_info *object = [[TLMsgDetailedInfo$msg_detailed_info alloc] init];
    object.msg_id = metaObject->getInt64(0xf1cc383f);
    object.answer_msg_id = metaObject->getInt64(0x1dcaed32);
    object.bytes = metaObject->getInt32(0xec5ef20a);
    object.status = metaObject->getInt32(0xab757700);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.msg_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xf1cc383f, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.answer_msg_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x1dcaed32, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.bytes;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xec5ef20a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.status;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xab757700, value));
    }
}


@end

@implementation TLMsgDetailedInfo$msg_new_detailed_info : TLMsgDetailedInfo


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x809db6df;
}

- (int32_t)TLconstructorName
{
    return (int32_t)0x93d991f8;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::tr1::shared_ptr<TLMetaObject>)metaObject
{
    TLMsgDetailedInfo$msg_new_detailed_info *object = [[TLMsgDetailedInfo$msg_new_detailed_info alloc] init];
    object.answer_msg_id = metaObject->getInt64(0x1dcaed32);
    object.bytes = metaObject->getInt32(0xec5ef20a);
    object.status = metaObject->getInt32(0xab757700);
    return object;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)values
{
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt64;
        value.primitive.int64Value = self.answer_msg_id;
        values->insert(std::pair<int32_t, TLConstructedValue>(0x1dcaed32, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.bytes;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xec5ef20a, value));
    }
    {
        TLConstructedValue value;
        value.type = TLConstructedValueTypePrimitiveInt32;
        value.primitive.int32Value = self.status;
        values->insert(std::pair<int32_t, TLConstructedValue>(0xab757700, value));
    }
}


@end

