package com.metashare;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.FileProvider;

import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.share.Sharer;
import com.facebook.share.model.SharePhoto;
import com.facebook.share.model.SharePhotoContent;
import com.facebook.share.model.ShareVideo;
import com.facebook.share.model.ShareVideoContent;
import com.facebook.share.widget.ShareDialog;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

@ReactModule(name = MetaShareModule.NAME)
public class MetaShareModule extends ReactContextBaseJavaModule implements ActivityEventListener {
  public static final String NAME = "MetaShare";

  public MetaShareModule(ReactApplicationContext reactContext) {
    super(reactContext);
    reactContext.addActivityEventListener(this);
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  @ReactMethod
  public void shareImageToInstagram(String imageURI, Promise promise) {
    String type = "image/*";
    String mediaPath = getReactApplicationContext().getCacheDir() + "/temp_1.jpg";
    FileDownloader downloader = new FileDownloader();

    downloader.setAllDownloadsDoneCallback(new FileDownloader.AllDownloadsDoneCallback() {
      @Override
      public void onAllDownloadsDone(List<Boolean> results) {
        Intent share = new Intent(Intent.ACTION_SEND);
        share.setType(type);
        File media = new File(getReactApplicationContext().getCacheDir(), "temp_1.jpg");
        Uri fileUri = FileProvider.getUriForFile(getReactApplicationContext(), getReactApplicationContext().getPackageName() + ".fileprovider", media);
        share.putExtra(Intent.EXTRA_STREAM, fileUri);
        getCurrentActivity().startActivity(Intent.createChooser(share, "Share to"));
      }
    });
    downloader.execute(imageURI, mediaPath);
  }

  @ReactMethod
  public void shareVideoToInstagram(String videoURI, Promise promise) {
    String type = "video/*";
    String fileName = "/temp_1.mp4";
    String mediaPath = getReactApplicationContext().getCacheDir() + fileName;
    Log.d("mediaPath", mediaPath);
    FileDownloader downloader = new FileDownloader();

    downloader.setAllDownloadsDoneCallback(new FileDownloader.AllDownloadsDoneCallback() {
      @Override
      public void onAllDownloadsDone(List<Boolean> results) {
        Intent share = new Intent(Intent.ACTION_SEND);
        share.setType(type);
        File media = new File(getReactApplicationContext().getCacheDir(), fileName);
        Uri fileUri = FileProvider.getUriForFile(getReactApplicationContext(), getReactApplicationContext().getPackageName() + ".fileprovider", media);
        share.putExtra(Intent.EXTRA_STREAM, fileUri);
        getCurrentActivity().startActivity(Intent.createChooser(share, "Share to"));
      }
    });
    downloader.execute(videoURI, mediaPath);
  }

  @ReactMethod
  public void shareToFacebookReels(String appID, String videoURI, String imageURI,Promise promise) {
    String mediaPath = getReactApplicationContext().getCacheDir() + "/temp_1.jpg";
    String mediaVideoPath = getReactApplicationContext().getCacheDir() + "/temp_1.mp4";
    FileDownloader downloader = new FileDownloader();

    downloader.setAllDownloadsDoneCallback(new FileDownloader.AllDownloadsDoneCallback() {
      @Override
      public void onAllDownloadsDone(List<Boolean> results) {
        Intent intent = new Intent("com.facebook.reels.SHARE_TO_REEL");
        intent.putExtra("com.facebook.platform.extra.APPLICATION_ID", appID);
        File videoFile = new File(mediaVideoPath);
        File imageFile = new File(mediaPath);
        Uri imageFileUri = FileProvider.getUriForFile(getReactApplicationContext(), getReactApplicationContext().getPackageName() + ".fileprovider", imageFile);
        intent.putExtra("interactive_asset_uri", imageFileUri);

        Uri videoFileUri = FileProvider.getUriForFile(getReactApplicationContext(), getReactApplicationContext().getPackageName() + ".fileprovider", videoFile);
        intent.setDataAndType(videoFileUri, "video/mp4");
        getReactApplicationContext().grantUriPermission("com.facebook.katana", videoFileUri, Intent.FLAG_GRANT_READ_URI_PERMISSION);


        Activity activity = getCurrentActivity();
        getCurrentActivity().grantUriPermission("com.facebook.katana", imageFileUri, Intent.FLAG_GRANT_READ_URI_PERMISSION);
        intent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        if (activity.getPackageManager().resolveActivity(intent, 0) != null)
        {
          activity.startActivityForResult(intent, 0);
          promise.resolve("opened");
        }else{
          promise.reject("error","error");
        }
      }
    });
    downloader.execute(videoURI,mediaVideoPath,imageURI,mediaPath);
  }

  @ReactMethod
  public void shareToInstagramStory(String appID, ReadableMap data, Promise promise) {


    String type = "image/*";
    String mediaPath = getReactApplicationContext().getCacheDir() + "/temp_1.jpg";
    String mediaPath2 = getReactApplicationContext().getCacheDir() + "/temp_2.jpg";
    String mediaVideoPath = getReactApplicationContext().getCacheDir() + "/temp_2.mp4";
    FileDownloader downloader = new FileDownloader();

    downloader.setAllDownloadsDoneCallback(new FileDownloader.AllDownloadsDoneCallback() {
      @Override
      public void onAllDownloadsDone(List<Boolean> results) {
        Intent intent = new Intent("com.instagram.share.ADD_TO_STORY");
        intent.putExtra("source_application", appID);
        if (data.hasKey("backgroundBottomColor")) {
          intent.putExtra("bottom_background_color", data.getString("backgroundBottomColor") != null ? data.getString("backgroundBottomColor") : "#FFA500");
        }

        if (data.hasKey("backgroundTopColor")) {
          intent.putExtra("top_background_color", data.getString("backgroundTopColor") != null ? data.getString("backgroundTopColor") : "#FF0000");
        }

        intent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        if (data.getString("backgroundImageAsset") != null) {

          File media = new File(mediaPath2);
          Uri fileUri = FileProvider.getUriForFile(getReactApplicationContext(), getReactApplicationContext().getPackageName() + ".fileprovider", media);
          intent.setDataAndType(fileUri, type);
          getCurrentActivity().grantUriPermission("com.instagram.android", fileUri,
            Intent.FLAG_GRANT_READ_URI_PERMISSION);
        }
        if (data.getString("backgroundVideoAsset") != null) {
          File media = new File(mediaVideoPath);
          Uri fileUri = FileProvider.getUriForFile(getReactApplicationContext(), getReactApplicationContext().getPackageName() + ".fileprovider", media);
          intent.setDataAndType(fileUri, "video/*");

          getCurrentActivity().grantUriPermission("com.instagram.android", fileUri,
            Intent.FLAG_GRANT_READ_URI_PERMISSION);
        }
        if (data.getString("stickerImageAsset") != null) {
          File media = new File(mediaPath);
          Uri fileUri = FileProvider.getUriForFile(getReactApplicationContext(), getReactApplicationContext().getPackageName() + ".fileprovider", media);
          if (!data.hasKey("backgroundImageAsset") && !data.hasKey("backgroundVideoAsset")) {
            intent.setType("image/*");
          }

          intent.putExtra("interactive_asset_uri", fileUri);
          getCurrentActivity().grantUriPermission("com.instagram.android", fileUri,
            Intent.FLAG_GRANT_READ_URI_PERMISSION);
        }
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        getReactApplicationContext().startActivity(intent);
      }
    });
    String[] downloadArray = new String[4];

    if (data.hasKey("stickerImageAsset")) {
      downloadArray[0] = data.getString("stickerImageAsset");
      downloadArray[1] = mediaPath;
    }
    if (data.hasKey("backgroundImageAsset")) {
      downloadArray[2] = data.getString("backgroundImageAsset");
      downloadArray[3] = mediaPath2;
    }
    if (data.hasKey("backgroundVideoAsset")) {
      downloadArray[2] = data.getString("backgroundVideoAsset");
      downloadArray[3] = mediaVideoPath;
    }
    downloader.execute(downloadArray);


// Attach your App ID to the intent
    String sourceApplication = "747322446269342"; // This is your application's FB ID

// Attach your image to the intent from a URI
//    Uri backgroundAssetUri = Uri.parse("your-image-asset-uri-goes-here");
//    intent.setDataAndType(backgroundAssetUri, "image/*");

// Grant URI permissions for the image
//    intent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
//    intent.setPackage("com.instagram.android");
// Instantiate an activity
//    Activity activity = getCurrentActivity();

// Verify that the activity resolves the intent and start it
//    if (activity.getPackageManager().resolveActivity(intent, 0) != null) {
//      activity.startActivityForResult(intent, 0);
//    }
  }

  @ReactMethod
  public void shareVideo(String videoURI, Promise promise) {
    FileDownloader downloader = new FileDownloader();
    String fileName = "/temp_1.mp4";
    String mediaPath = getReactApplicationContext().getCacheDir() + fileName;
    downloader.setAllDownloadsDoneCallback(new FileDownloader.AllDownloadsDoneCallback() {
      @Override
      public void onAllDownloadsDone(List<Boolean> results) {
        File media = new File(getReactApplicationContext().getCacheDir(), fileName);
        Uri fileUri = FileProvider.getUriForFile(getReactApplicationContext(), getReactApplicationContext().getPackageName() + ".fileprovider", media);
        ShareVideo video = new ShareVideo.Builder()
          .setLocalUrl(fileUri)
          .build();
        ShareVideoContent content = new ShareVideoContent.Builder()
          .setVideo(video)
          .build();
        UiThreadUtil.runOnUiThread(new Runnable() {
          @Override
          public void run() {
            CallbackManager callbackManager = CallbackManager.Factory.create();
            ShareDialog shareDialog = new ShareDialog(getReactApplicationContext().getCurrentActivity());
            String TAG = "facebook";
            shareDialog.registerCallback(callbackManager, new FacebookCallback<Sharer.Result>() {
              @Override
              public void onSuccess(Sharer.Result result) {
                // sharing was successful
                Log.d(TAG, "Share successful: " + result.getPostId());
              }

              @Override
              public void onCancel() {
                // sharing was cancelled
                Log.d(TAG, "Share cancelled");
              }

              @Override
              public void onError(FacebookException error) {
                // an error occurred while sharing
                Log.e(TAG, "Error sharing: " + error.getMessage(), error);
              }
            });
            shareDialog.show(content, ShareDialog.Mode.AUTOMATIC);

          }
        });
      }
    });
    downloader.execute(videoURI, mediaPath);

  }

  @ReactMethod
  public void sharePhotos(ReadableArray photos, Promise promise) {
    FileDownloader downloader = new FileDownloader();

    downloader.setAllDownloadsDoneCallback(new FileDownloader.AllDownloadsDoneCallback() {
      @Override
      public void onAllDownloadsDone(List<Boolean> results) {
        List<SharePhoto> sharePhotos = new ArrayList<>();
        for (int i = 0; i < photos.size(); i++) {
          File media = new File(getReactApplicationContext().getCacheDir(), "temp_" + i + ".jpg");
          Uri fileUri = FileProvider.getUriForFile(getReactApplicationContext(), getReactApplicationContext().getPackageName() + ".fileprovider", media);
          FacebookSdk.sdkInitialize(getReactApplicationContext());
          SharePhoto photo = new SharePhoto.Builder()
            .setImageUrl(fileUri)
            .build();
          sharePhotos.add(photo);
        }
        SharePhotoContent content = new SharePhotoContent.Builder()
          .addPhotos(sharePhotos)
          .build();
        UiThreadUtil.runOnUiThread(new Runnable() {
          @Override
          public void run() {
            CallbackManager callbackManager = CallbackManager.Factory.create();
            ShareDialog shareDialog = new ShareDialog(getReactApplicationContext().getCurrentActivity());
            String TAG = "facebook";
            shareDialog.registerCallback(callbackManager, new FacebookCallback<Sharer.Result>() {
              @Override
              public void onSuccess(Sharer.Result result) {
                // sharing was successful
                Log.d(TAG, "Share successful: " + result.getPostId());
                WritableMap map = new WritableNativeMap();
                map.putString("postId", result.getPostId());
                promise.resolve(map);
              }

              @Override
              public void onCancel() {
                // sharing was cancelled
                promise.reject("onCancel", "Share cancelled");
                Log.d(TAG, "Share cancelled");
              }

              @Override
              public void onError(FacebookException error) {
                // an error occurred while sharing
                promise.reject("error", error.getMessage());
                Log.e(TAG, "Error sharing: " + error.getMessage(), error);
              }
            });
            shareDialog.show(content, ShareDialog.Mode.AUTOMATIC);

          }
        });
      }
    });
    String[] requestUri = new String[photos.size() * 2];
    for (int i = 0; i < photos.size(); i++) {
      String element = photos.getString(i);
      String mediaPath = getReactApplicationContext().getCacheDir() + "/temp_" + i + ".jpg";
      requestUri[i * 2] = element;
      requestUri[i * 2 + 1] = mediaPath;
    }
    ;
    downloader.execute(requestUri);

  }

  public void onActivityResult(int requestCode, int resultCode, Intent data) {
    Log.d("test", "test");
    if (requestCode == 0) {
      if (resultCode == Activity.RESULT_CANCELED) {
      } else if (resultCode == Activity.RESULT_OK) {
      } else {

      }
    }
  }


  @Override
  public void onActivityResult(Activity activity, int i, int i1, @Nullable Intent intent) {

  }

  @Override
  public void onNewIntent(Intent intent) {

  }
}
