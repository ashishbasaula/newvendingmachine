//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <in_app_idle_detector/in_app_idle_detector_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) in_app_idle_detector_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "InAppIdleDetectorPlugin");
  in_app_idle_detector_plugin_register_with_registrar(in_app_idle_detector_registrar);
}
