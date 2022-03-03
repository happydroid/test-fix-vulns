//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import <SignalServiceKit/SSKJobRecord.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSKMessageDecryptJobRecord : SSKJobRecord

@property (nonatomic, readonly, nullable) NSData *envelopeData;
@property (nonatomic, readonly) uint64_t serverDeliveryTimestamp;

- (instancetype)initWithLabel:(NSString *)label NS_UNAVAILABLE;

- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithEnvelopeData:(NSData *)message
             serverDeliveryTimestamp:(uint64_t)serverDeliveryTimestamp
                               label:(NSString *)label NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
                  failureCount:(NSUInteger)failureCount
                         label:(NSString *)label
                        sortId:(unsigned long long)sortId
                        status:(SSKJobRecordStatus)status NS_UNAVAILABLE;

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run `sds_codegen.sh`.

// clang-format off

- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
      exclusiveProcessIdentifier:(nullable NSString *)exclusiveProcessIdentifier
                    failureCount:(NSUInteger)failureCount
                           label:(NSString *)label
                          sortId:(unsigned long long)sortId
                          status:(SSKJobRecordStatus)status
                    envelopeData:(nullable NSData *)envelopeData
         serverDeliveryTimestamp:(uint64_t)serverDeliveryTimestamp
NS_DESIGNATED_INITIALIZER NS_SWIFT_NAME(init(grdbId:uniqueId:exclusiveProcessIdentifier:failureCount:label:sortId:status:envelopeData:serverDeliveryTimestamp:));

// clang-format on

// --- CODE GENERATION MARKER

@end

NS_ASSUME_NONNULL_END
