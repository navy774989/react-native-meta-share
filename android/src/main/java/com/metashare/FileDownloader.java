package com.metashare;

import android.os.AsyncTask;

import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

public class FileDownloader extends AsyncTask<String, Integer, List<Boolean>> {
  private DownloadProgressCallback mProgressCallback;
  private AllDownloadsDoneCallback mDoneCallback;

  public void setDownloadProgressCallback(DownloadProgressCallback callback) {
    mProgressCallback = callback;
  }

  public void setAllDownloadsDoneCallback(AllDownloadsDoneCallback callback) {
    mDoneCallback = callback;
  }

  @Override
  protected List<Boolean> doInBackground(String... params) {
    int count = params.length / 2;
    List<Boolean> results = new ArrayList<>();

    for (int i = 0; i < count; i++) {
      String url = params[i * 2];
      String path = params[i * 2 + 1];

      try {
        URL u = new URL(url);
        HttpURLConnection conn = (HttpURLConnection) u.openConnection();
        conn.setRequestMethod("GET");
        conn.connect();

        InputStream in = conn.getInputStream();
        OutputStream out = new FileOutputStream(path);

        byte[] buffer = new byte[1024];
        int len;
        int total = 0;
        while ((len = in.read(buffer)) > 0) {
          total += len;
          out.write(buffer, 0, len);

          // Publish progress for this file
          publishProgress(total * 100 / conn.getContentLength(), i);
        }

        in.close();
        out.close();
        conn.disconnect();
        results.add(true);
      } catch (Exception e) {
        e.printStackTrace();
        results.add(false);
      }
    }

    return results;
  }

  @Override
  protected void onProgressUpdate(Integer... values) {
    if (mProgressCallback != null) {
      mProgressCallback.onProgressUpdate(values[0], values[1]);
    }
  }

  @Override
  protected void onPostExecute(List<Boolean> results) {
    if (mDoneCallback != null) {
      mDoneCallback.onAllDownloadsDone(results);
    }
  }

  public interface DownloadProgressCallback {
    void onProgressUpdate(int progress, int index);
  }

  public interface AllDownloadsDoneCallback {
    void onAllDownloadsDone(List<Boolean> results);
  }
}
