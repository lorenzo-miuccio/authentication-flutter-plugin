#import "SalamiUnlockPlugin.h"
#if __has_include(<salami_unlock/salami_unlock-Swift.h>)
#import <salami_unlock/salami_unlock-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "salami_unlock-Swift.h"
#endif

@implementation SalamiUnlockPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSalamiUnlockPlugin registerWithRegistrar:registrar];
}
@end
