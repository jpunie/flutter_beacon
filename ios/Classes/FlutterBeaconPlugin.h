#import <Flutter/Flutter.h>

@class CBCentralManager;
@class CBCentralManagerDelegate;
@interface FlutterBeaconPlugin : NSObject<FlutterPlugin>

@property FlutterEventSink flutterEventSinkBluetooth;
@property FlutterEventSink flutterEventSinkAuthorization;

- (void) initializeCentralManager;

@end
