//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import <SignalServiceKit/BaseModel.h>
#import <SignalServiceKit/TSPaymentModels.h>

NS_ASSUME_NONNULL_BEGIN

@class SignalServiceAddress;
@class TSPaymentAmount;

// TSPaymentRequest is a sub-model of TSMessages used
// for the messaging of requests. It is only persisted
// in the database in the durable queue of outgoing messages.
//
// TSPaymentRequestModel is used for request bookkeeping
// and is stored in the database.
@interface TSPaymentRequestModel : BaseModel

@property (nonatomic, readonly) NSString *requestUuidString;

// The address of the sender/recipient.
@property (nonatomic, readonly) NSString *addressUuidString;
@property (nonatomic, readonly) NSUUID *addressUuid;
@property (nonatomic, readonly) SignalServiceAddress *address;

@property (nonatomic, readonly) BOOL isIncomingRequest;

@property (nonatomic, readonly) TSPaymentAmount *paymentAmount;

@property (nonatomic, readonly, nullable) NSString *memoMessage;

@property (nonatomic, readonly) uint64_t createdTimestamp;
@property (nonatomic, readonly) NSDate *createdDate;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithUniqueId:(NSString *)uniqueId NS_UNAVAILABLE;
- (instancetype)initWithGrdbId:(int64_t)grdbId uniqueId:(NSString *)uniqueId NS_UNAVAILABLE;

- (instancetype)initWithRequestUuidString:(NSString *)requestUuidString
                        addressUuidString:(NSString *)addressUuidString
                        isIncomingRequest:(BOOL)isIncomingRequest
                            paymentAmount:(TSPaymentAmount *)paymentAmount
                              memoMessage:(nullable NSString *)memoMessage
                              createdDate:(NSDate *)createdDate NS_DESIGNATED_INITIALIZER;

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run `sds_codegen.sh`.

// clang-format off

- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
               addressUuidString:(NSString *)addressUuidString
                createdTimestamp:(uint64_t)createdTimestamp
               isIncomingRequest:(BOOL)isIncomingRequest
                     memoMessage:(nullable NSString *)memoMessage
                   paymentAmount:(TSPaymentAmount *)paymentAmount
               requestUuidString:(NSString *)requestUuidString
NS_DESIGNATED_INITIALIZER NS_SWIFT_NAME(init(grdbId:uniqueId:addressUuidString:createdTimestamp:isIncomingRequest:memoMessage:paymentAmount:requestUuidString:));

// clang-format on

// --- CODE GENERATION MARKER

@end

NS_ASSUME_NONNULL_END
