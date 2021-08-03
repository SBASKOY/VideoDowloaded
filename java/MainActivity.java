package com.sbaskoy.videodownloaded;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Parcelable;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.io.File;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private  static final String CHANNEL="com.sbaskoy.videodownloaded/channel";
    private  static final String STREAM="com.sbaskoy.videodownloaded/stream";
    static EventChannel.EventSink events;
    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        new EventChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(),STREAM).setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        MainActivity.events=events;
                        listen();
                    }

                    @Override
                    public void onCancel(Object arguments) {
                            stop_listen();
                    }
                }
        );

        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(),CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                if(call.method.equals("getDownlandDirectory")){
                    File path= getDownlandDirectory();
                    result.success(path.getPath());
                }else if(call.method.equals("getMusicDirectory")){
                    File path=getMusicDirectory();
                    result.success(path.getPath());
                }
                else if(call.method.equals("startMusic")){
                    String path = call.argument("path");
                    startMusic(path);
                    result.success(true);
                }
                else if(call.method.equals("stopMusic")){
                    stopMusic();
                    result.success(true);
                }  else if(call.method.equals("pauseMusic")){
                    pauseMusic();
                    result.success(true);
                }
                else if(call.method.equals("resumeMusic")){
                    resumeMusic();
                    result.success(true);
                }
                else{
                    result.error("404","not found","your method not found");
                }
            }
        });
        GeneratedPluginRegistrant.registerWith(getFlutterEngine());
    }
    private  void stop_listen(){
        Intent serviceIntent = new Intent(this,ISoundService.class);
        serviceIntent.setAction(ISoundService.STOP_LISTEN);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startService(serviceIntent);
            Log.d("SDK IND > VERSION","startForegroundService");
        } else {
            startService(serviceIntent);
            Log.d("SDK IND < VERSION","startService");
        }
    }
    private  void listen(){
        Intent serviceIntent = new Intent(this,ISoundService.class);
        serviceIntent.setAction(ISoundService.LISTEN);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startService(serviceIntent);
            Log.d("SDK IND > VERSION","startForegroundService");
        } else {
            startService(serviceIntent);
            Log.d("SDK IND < VERSION","startService");
        }
    }
    private void startMusic(String path){
        Intent serviceIntent = new Intent(this,ISoundService.class);
        serviceIntent.putExtra("path", path);
        Log.d("SENDING PATH",path);
        serviceIntent.setAction(ISoundService.ACTION_START_FOREGROUND_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startService(serviceIntent);
            Log.d("SDK IND > VERSION","startForegroundService");
        } else {
            startService(serviceIntent);
            Log.d("SDK IND < VERSION","startService");
        }
    }
    private  void stopMusic(){
        Intent intent = new Intent(this, ISoundService.class);
        intent.setAction(ISoundService.ACTION_STOP_FOREGROUND_SERVICE);
        startService(intent);

    }
    private void pauseMusic(){
        Intent intent = new Intent(this, ISoundService.class);
        intent.setAction(ISoundService.ACTION_PAUSE);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startService(intent);
        } else {
            startService(intent);
        }
    }
    private void resumeMusic(){
        Intent intent = new Intent(this, ISoundService.class);
        intent.setAction(ISoundService.ACTION_PLAY);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startService(intent);
        } else {
            startService(intent);
        }
    }
    public File getDownlandDirectory(){
        return Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
    }
    public File getMusicDirectory(){
        return Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MUSIC);
    }
}
