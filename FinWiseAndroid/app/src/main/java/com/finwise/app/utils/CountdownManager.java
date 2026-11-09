package com.finwise.app.utils;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Handler;
import android.os.Looper;

import java.util.Locale;

/**
 * Countdown Manager
 * Manages 60-second OTP resend throttling using an Android Java Handler.
 * Persists timestamp to ensure app restarts or screen rotations do not bypass the countdown.
 */
public class CountdownManager {
    public interface CountdownListener {
        void onTick(long secondsRemaining, String formatted);
        void onFinish();
    }

    private static final String PREF_NAME = "finwise_countdown_prefs";
    private static final String KEY_EXPIRY_PREFIX = "resend_expiry_";
    public static final int DEFAULT_SECONDS = 60;

    private final SharedPreferences prefs;
    private final Handler handler;
    private Runnable runnable;
    private CountdownListener listener;
    private String currentKey;
    private boolean isRunning = false;

    public CountdownManager(Context context) {
        this.prefs = context.getApplicationContext().getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
        this.handler = new Handler(Looper.getMainLooper());
    }

    public void startCountdown(String emailKey, int totalSeconds, CountdownListener listener) {
        stop();
        this.currentKey = KEY_EXPIRY_PREFIX + emailKey.toLowerCase().trim();
        this.listener = listener;

        long now = System.currentTimeMillis();
        long targetExpiry = now + (totalSeconds * 1000L);
        prefs.edit().putLong(currentKey, targetExpiry).apply();

        runTimer();
    }

    public void resumeCountdownIfActive(String emailKey, CountdownListener listener) {
        this.currentKey = KEY_EXPIRY_PREFIX + emailKey.toLowerCase().trim();
        this.listener = listener;

        long targetExpiry = prefs.getLong(currentKey, 0L);
        long now = System.currentTimeMillis();
        long diffMs = targetExpiry - now;

        if (diffMs > 0) {
            runTimer();
        } else {
            if (listener != null) {
                listener.onFinish();
            }
        }
    }

    private void runTimer() {
        isRunning = true;
        runnable = new Runnable() {
            @Override
            public void run() {
                long targetExpiry = prefs.getLong(currentKey, 0L);
                long now = System.currentTimeMillis();
                long diffMs = targetExpiry - now;

                if (diffMs <= 0) {
                    isRunning = false;
                    prefs.edit().remove(currentKey).apply();
                    if (listener != null) {
                        listener.onFinish();
                    }
                } else {
                    long secRemaining = (diffMs + 999) / 1000L;
                    String formatted = String.format(Locale.getDefault(), "00:%02d", secRemaining);
                    if (listener != null) {
                        listener.onTick(secRemaining, formatted);
                    }
                    handler.postDelayed(this, 1000);
                }
            }
        };
        handler.post(runnable);
    }

    public void stop() {
        if (runnable != null) {
            handler.removeCallbacks(runnable);
            runnable = null;
        }
        isRunning = false;
    }

    public boolean isRunning() {
        return isRunning;
    }

    public long getRemainingSeconds(String emailKey) {
        String key = KEY_EXPIRY_PREFIX + emailKey.toLowerCase().trim();
        long targetExpiry = prefs.getLong(key, 0L);
        long diffMs = targetExpiry - System.currentTimeMillis();
        return diffMs > 0 ? (diffMs + 999) / 1000L : 0;
    }
}
