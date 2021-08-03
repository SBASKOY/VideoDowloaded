package com.example.dowloandvideo;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;
import android.widget.Toast;

import androidx.core.app.NotificationCompat;

import java.io.IOException;
import java.util.Timer;
import java.util.TimerTask;

import io.flutter.plugin.common.EventChannel;


public class ISoundService extends Service {

    private static final String TAG_FOREGROUND_SERVICE = "FOREGROUND_SERVICE";

    public static final String ACTION_START_FOREGROUND_SERVICE = "ACTION_START_FOREGROUND_SERVICE";

    public static final String ACTION_STOP_FOREGROUND_SERVICE = "ACTION_STOP_FOREGROUND_SERVICE";

    public static final String ACTION_PAUSE = "ACTION_PAUSE";

    public static final String ACTION_PLAY = "ACTION_PLAY";
    public static final String LISTEN = "LISTEN";
    public static final String STOP_LISTEN = "STOP_LISTEN";
    public static final String CHANNEL_ID = "ForegroundServiceChannel";
    private MediaPlayer player;
    private int length = 0;
    private Timer timer=new Timer();
    @Override
    public IBinder onBind(Intent intent) {
        throw new UnsupportedOperationException("Not yet implemented");
    }

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(TAG_FOREGROUND_SERVICE, "My foreground service onCreate().");
    }

    public int getLength() {
        return length;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        super.onStartCommand(intent, flags, startId);
        if(intent != null)
        {
            String action = intent.getAction();
            switch (action)
            {
                case ACTION_START_FOREGROUND_SERVICE:
                    Bundle extras = intent.getExtras();
                    String path = (String) extras.get("path");

                    createNotificationChannel();

                    Intent playIntent = new Intent(this, ISoundService.class);
                    playIntent.setAction(ACTION_PLAY);
                    PendingIntent pendingPlayIntent = PendingIntent.getService(this, 0, playIntent, 0);

                    Intent pauseIntent = new Intent(this, ISoundService.class);
                    pauseIntent.setAction(ACTION_PAUSE);
                    PendingIntent pendingPauseIntent = PendingIntent.getService(this, 0, pauseIntent, 0);

                    Intent closeIntent = new Intent(this, ISoundService.class);
                    closeIntent.setAction(ISoundService.ACTION_STOP_FOREGROUND_SERVICE);
                    PendingIntent pendingCloseIntent = PendingIntent.getService(this, 0, closeIntent, 0);

                    Intent notificationIntent = new Intent(this, MainActivity.class);
                    PendingIntent pendingIntent = PendingIntent.getActivity(this,
                            0, notificationIntent, 0);
                    Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                            .setContentTitle("Music Player")
                            .setContentText(path)
                            .setSmallIcon(R.mipmap.ic_launcher)
                            .setContentIntent(pendingIntent)
                            .addAction(android.R.drawable.ic_media_play,"play",pendingPlayIntent)
                            .addAction(android.R.drawable.ic_media_pause,"pause",pendingPauseIntent)
                            .addAction(android.R.drawable.ic_delete,"close",pendingCloseIntent)

                            .build();
                    startForeground(1, notification);

                    if(player!=null){
                        if(player.isPlaying()){
                            player.stop();
                        }
                    }
                    player=MediaPlayer.create(this, Uri.parse(path));
                    player.setLooping(true);
                    player.setVolume(100,100);
                    player.start();
                   // Toast.makeText(getApplicationContext(), "Foreground service is started.", Toast.LENGTH_LONG).show();
                    break;
                case ACTION_STOP_FOREGROUND_SERVICE:
                   if(player!=null){
                       if(player.isPlaying()){
                           player.stop();
                           player.release();
                       }
                   }
                    stopForegroundService();

                    break;
                case ACTION_PLAY:
                    if(player!=null){
                        if(!player.isPlaying()){
                            player.start();
                        }
                    }
                    break;
                case ACTION_PAUSE:
                    if(player!=null){
                        if(player.isPlaying()){
                            player.pause();
                            length=player.getCurrentPosition();
                        }
                    }
                    break;
                case LISTEN:
                    if(player!=null){
                        if(player.isPlaying()){

                            timer.scheduleAtFixedRate(new TimerTask() {
                                @Override
                                public void run() {
                                    if(MainActivity.events!=null){
                                        MainActivity.events.success(player.getCurrentPosition());
                                    }else {
                                        Log.i("JAVA MESSAGE","events is null");
                                    }


                                }
                            },1000,1000);
                        }
                    }
                    break;
                case STOP_LISTEN:
                    if( timer !=null)timer.cancel();
                    break;
            }
        }
        return START_STICKY;
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel serviceChannel = new NotificationChannel(
                    CHANNEL_ID,
                    "Music Player Channel",
                    NotificationManager.IMPORTANCE_DEFAULT
            );
            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(serviceChannel);
        }
    }
    private void stopForegroundService()
    {
        Log.d(TAG_FOREGROUND_SERVICE, "Stop foreground service.");


        stopForeground(true);


        stopSelf();
    }
}