package com.flutterbeacon;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.provider.Settings;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.flutterbeacon.custom.CustomBeaconTransmitter;

import java.lang.ref.WeakReference;

class FlutterPlatform {
  private final WeakReference<Activity> activityWeakReference;
  
  FlutterPlatform(Activity activity) {
    activityWeakReference = new WeakReference<>(activity);
  }
  
  private Activity getActivity() {
    return activityWeakReference.get();
  }
  
  void openBluetoothSettings() {
    Intent intent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
    getActivity().startActivityForResult(intent, FlutterBeaconPlugin.REQUEST_CODE_BLUETOOTH);
  }

  void requestAuthorization() {
    ActivityCompat.requestPermissions(getActivity(), new String[]{
        Manifest.permission.BLUETOOTH_ADVERTISE,
    }, FlutterBeaconPlugin.REQUEST_CODE_BLUETOOTH);
  }

  boolean checkBluetoothServicesPermission() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      return ContextCompat.checkSelfPermission(getActivity(),
          Manifest.permission.BLUETOOTH_ADVERTISE) == PackageManager.PERMISSION_GRANTED;
    }

    return true;
  }


  @SuppressLint("MissingPermission")
  boolean checkBluetoothIfEnabled() {
    BluetoothManager bluetoothManager = (BluetoothManager)
        getActivity().getSystemService(Context.BLUETOOTH_SERVICE);
    if (bluetoothManager == null) {
      throw new RuntimeException("No bluetooth service");
    }

    BluetoothAdapter adapter = bluetoothManager.getAdapter();

    return (adapter != null) && (adapter.isEnabled());
  }
  
  boolean isBroadcastSupported() {
    return CustomBeaconTransmitter.checkTransmissionSupported(getActivity()) == 0;
  }
  
  boolean shouldShowRequestPermissionRationale(String permission) {
    return ActivityCompat.shouldShowRequestPermissionRationale(getActivity(), permission);
  }
}
