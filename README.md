# react-native-meta-share

Share Images or Video to Facebook/Instagram

## Installation

With npm:

```sh
> npm install @react-native-async-storage/async-storage
```

With Yarn:

```sh
> yarn add @react-native-async-storage/async-storage
```

## Link

#### Android & iOS

Requires **React Native 0.60+**

[CLI autolink feature](https://github.com/react-native-community/cli/blob/main/docs/autolinking.md) links the module while building the app.

On iOS, use CocoaPods to add the native react-native-meta-share to your project:

```sh
> npx pod-install
```

## Usage

```js
import {
  sharePhotosToFacebook,
  shareVideoToFacebook,
  shareVideoToInstagram,
  shareImageToInstagram,
  shareToInstagramStory,
} from 'react-native-meta-share';

// ...

const result = await shareToInstagramStory('appid', {
  backgroundBottomColor: '#FFA500',
  backgroundTopColor: '#FF0000',
  stickerImageAsset: 'image uri',
  backgroundVideoAsset: 'video uri',
});

const result = await sharePhotosToFacebook(['image1 uri', 'image2 uri']);

const result = await shareVideoToFacebook('video uri');

const result = await shareVideoToInstagram('video uri');

const result = await shareImageToInstagram('image uri');
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
