package com.techmaven.USFS;

import android.content.Context;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.fragment.app.FragmentManager;

import io.flutter.plugin.platform.PlatformView;
import java.util.Map;

class NativeView implements PlatformView {

    ConstraintLayout cl;
    NativeView(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams) {
        cl = (ConstraintLayout) LayoutInflater.from(context).inflate(R.layout.activity_test, null);
        FragmentManager mm = ((AppCompatActivity)context).getSupportFragmentManager();

    }

    @NonNull
    @Override
    public View getView() {
        return cl;
    }

    @Override
    public void dispose() {}
}