import * as React from 'react';

import { StyleSheet, View, Text, Pressable } from 'react-native';
import {
  sharePhotosToFacebook,
  shareVideoToFacebook,
  shareVideoToInstagram,
  shareImageToInstagram,
  shareToInstagramStory,
  shareToFacebookReels,
} from 'react-native-meta-share';

export default function App() {
  return (
    <View style={styles.container}>
      <Pressable
        onPress={() => {
          // sharePhotos([

          //   'https://plus.unsplash.com/premium_photo-1671641798046-3ef40e6d2e0b?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1064&q=80',
          //   'https://images.unsplash.com/photo-1678379679866-0cb2d81cae9f?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1940&q=80',
          // ]);
          shareToInstagramStory('219376304', {
            stickerImageAsset:
              'https://images.unsplash.com/photo-1678379679866-0cb2d81cae9f?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1940&q=80',
            backgroundVideoAsset:
              'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
            // backgroundImageAsset:
            //   'https://plus.unsplash.com/premium_photo-1671641798046-3ef40e6d2e0b?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1064&q=80',
          });
        }}
        style={styles.box}
      >
        <Text>Share To Instagram Story</Text>
      </Pressable>
      <Pressable
        onPress={() => {
          shareToFacebookReels(
            '219376304',
            'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
            'https://images.unsplash.com/photo-1678379679866-0cb2d81cae9f?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1940&q=80'
          );
        }}
        style={styles.box}
      >
        <Text>Share To Facebook Reels</Text>
      </Pressable>
      <Pressable
        onPress={() => {
          sharePhotosToFacebook([
            'https://plus.unsplash.com/premium_photo-1671641798046-3ef40e6d2e0b?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1064&q=80',
            'https://images.unsplash.com/photo-1678379679866-0cb2d81cae9f?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1940&q=80',
          ]);
        }}
        style={styles.box}
      >
        <Text>Share Photos To Facebook</Text>
      </Pressable>
      <Pressable
        onPress={() => {
          shareVideoToFacebook(
            'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4'
          );
        }}
        style={styles.box}
      >
        <Text>Share Video To Facebook</Text>
      </Pressable>
      <Pressable
        onPress={() => {
          shareVideoToInstagram(
            'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4'
          );
        }}
        style={styles.box}
      >
        <Text>Share Video To Instagram</Text>
      </Pressable>
      <Pressable
        onPress={() => {
          shareImageToInstagram(
            'https://plus.unsplash.com/premium_photo-1671641798046-3ef40e6d2e0b?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1064&q=80'
          );
        }}
        style={styles.box}
      >
        <Text>Share Image To Instagram</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    paddingHorizontal: 10,
    paddingVertical: 5,
    backgroundColor: 'white',
    marginVertical: 20,
  },
});
