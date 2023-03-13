# react-native-meta-share

meta platform's share

## Installation

```sh
npm install react-native-meta-share
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
