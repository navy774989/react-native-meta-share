#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(MetaShare, NSObject)

RCT_EXTERN_METHOD(sharePhotos:(NSArray)photos
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(shareVideo:(NSString)videoURI
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(shareVideoToInstagram:(NSString)videoURI
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(shareImageToInstagram:(NSString)imageURI
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(shareToInstagramStory:(NSString)appID
                 withData:(NSDictionary)data
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(shareToFacebookReels:(NSString)appID
				  withVideoURI:(NSString)videoURI
				  withImageURI:(NSString)imageURI
				  withResolver:(RCTPromiseResolveBlock)resolve
				  withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
