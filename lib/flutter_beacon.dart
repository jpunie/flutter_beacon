//  Copyright (c) 2018 Eyro Labs.
//  Licensed under Apache License v2.0 that can be
//  found in the LICENSE file.

/// Flutter beacon library.
library flutter_beacon;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'beacon/authorization_status.dart';
part 'beacon/beacon.dart';
part 'beacon/beacon_broadcast.dart';
part 'beacon/bluetooth_state.dart';
part 'beacon/monitoring_result.dart';
part 'beacon/ranging_result.dart';
part 'beacon/region.dart';

/// Singleton instance for accessing scanning API.
final FlutterBeacon flutterBeacon = new FlutterBeacon._internal();

/// Provide iBeacon scanning API for both Android and iOS.
class FlutterBeacon {
  FlutterBeacon._internal();

  /// Method Channel used to communicate to native code.
  static const MethodChannel _methodChannel =
      const MethodChannel('flutter_beacon');

  /// Event Channel used to communicate to native code to checking
  /// for bluetooth state changed.
  static const EventChannel _bluetoothStateChangedChannel =
      EventChannel('flutter_bluetooth_state_changed');

  /// Event Channel used to communicate to native code to checking
  /// for bluetooth state changed.
  static const EventChannel _authorizationStatusChangedChannel =
      EventChannel('flutter_authorization_status_changed');

  /// This information does not change from call to call. Cache it.
  Stream<BluetoothState>? _onBluetoothState;

  /// This information does not change from call to call. Cache it.
  Stream<AuthorizationStatus>? _onAuthorizationStatus;

  /// Initialize scanning API.
  Future<bool> get initializeScanning async {
    final result = await _methodChannel.invokeMethod('initialize');

    if (result is bool) {
      return result;
    } else if (result is int) {
      return result == 1;
    }

    return result;
  }

  /// Initialize scanning API and check required permissions.
  ///
  /// For Android, it will check whether Bluetooth is enabled,
  /// allowed to access location services and check
  /// whether location services is enabled.
  /// For iOS, it will check whether Bluetooth is enabled,
  /// requestWhenInUse or requestAlways location services and check
  /// whether location services is enabled.
  Future<bool> get initializeAndCheckScanning async {
    final result = await _methodChannel.invokeMethod('initializeAndCheck');

    if (result is bool) {
      return result;
    }

    return result == 1;
  }

  /// Check for the latest [AuthorizationStatus] from device.
  ///
  /// For Android, this will return [AuthorizationStatus.allowed], [AuthorizationStatus.denied] or [AuthorizationStatus.notDetermined].
  Future<AuthorizationStatus> get authorizationStatus async {
    final status = await _methodChannel.invokeMethod('authorizationStatus');
    return AuthorizationStatus.parse(status);
  }

  /// Check for the latest [BluetoothState] from device.
  Future<BluetoothState> get bluetoothState async {
    final status = await _methodChannel.invokeMethod('bluetoothState');
    return BluetoothState.parse(status);
  }

  /// Request an authorization to the device.
  ///
  /// For Android, this will request a permission of `Manifest.permission.ACCESS_COARSE_LOCATION`.
  /// For iOS, this will send a request `CLLocationManager#requestAlwaysAuthorization`.
  Future<bool> get requestAuthorization async {
    final result = await _methodChannel.invokeMethod('requestAuthorization');

    if (result is bool) {
      return result;
    }

    return result == 1;
  }

  /// Request to open Bluetooth Settings from device.
  ///
  /// For iOS, this will does nothing because of private method.
  Future<bool> get openBluetoothSettings async {
    final result = await _methodChannel.invokeMethod('openBluetoothSettings');

    if (result is bool) {
      return result;
    }

    return result == 1;
  }

  /// Request to open Application Settings from device.
  ///
  /// For Android, this will does nothing.
  Future<bool> get openApplicationSettings async {
    final result = await _methodChannel.invokeMethod('openApplicationSettings');

    if (result is bool) {
      return result;
    }

    return result == 1;
  }

  /// Close scanning API.
  Future<bool> get close async {
    final result = await _methodChannel.invokeMethod('close');

    if (result is bool) {
      return result;
    }

    return result == 1;
  }

  /// Start checking for bluetooth state changed.
  ///
  /// This will fires [BluetoothState] whenever bluetooth state changed.
  Stream<BluetoothState> bluetoothStateChanged() {
    if (_onBluetoothState == null) {
      _onBluetoothState = _bluetoothStateChangedChannel
          .receiveBroadcastStream()
          .map((dynamic event) => BluetoothState.parse(event));
    }
    return _onBluetoothState!;
  }

  /// Start checking for location service authorization status changed.
  ///
  /// This will fires [AuthorizationStatus] whenever authorization status changed.
  Stream<AuthorizationStatus> authorizationStatusChanged() {
    if (_onAuthorizationStatus == null) {
      _onAuthorizationStatus = _authorizationStatusChangedChannel
          .receiveBroadcastStream()
          .map((dynamic event) => AuthorizationStatus.parse(event));
    }
    return _onAuthorizationStatus!;
  }

  Future<void> startBroadcast(BeaconBroadcast params) async {
    await _methodChannel.invokeMethod('startBroadcast', params.toJson);
  }

  Future<void> stopBroadcast() async {
    await _methodChannel.invokeMethod('stopBroadcast');
  }

  Future<bool> isBroadcasting() async {
    final flag = await _methodChannel.invokeMethod('isBroadcasting');
    return flag == true || flag == 1;
  }

  Future<bool> isBroadcastSupported() async {
    final flag = await _methodChannel.invokeMethod('isBroadcastSupported');
    return flag == true || flag == 1;
  }
}
