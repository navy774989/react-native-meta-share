import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-meta-share' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const MetaShare = NativeModules.MetaShare
  ? NativeModules.MetaShare
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function sharePhotosToFacebook(imageURIs: string[]): Promise<string[]> {
  return MetaShare.sharePhotos(imageURIs);
}

export function shareToFacebookReels(
  appID: string,
  videoURI: string = '',
  imageURI?: string
): Promise<string[]> {
  return MetaShare.shareToFacebookReels(appID, videoURI, imageURI);
}

export function shareVideoToFacebook(videoURI: string): Promise<string[]> {
  return MetaShare.shareVideo(videoURI);
}

export function shareVideoToInstagram(videoURI: string): Promise<string[]> {
  return MetaShare.shareVideoToInstagram(videoURI);
}

export function shareImageToInstagram(imageURI: string): Promise<string[]> {
  return MetaShare.shareImageToInstagram(imageURI);
}
export function shareToInstagramStory(
  appID: string,
  data: {
    backgroundImageAsset?: string;
    stickerImageAsset?: string;
    backgroundTopColor?: string;
    backgroundBottomColor?: string;
    backgroundVideoAsset?: string;
  }
): Promise<string[]> {
  console.log(data);
  return MetaShare.shareToInstagramStory(appID, data);
}
