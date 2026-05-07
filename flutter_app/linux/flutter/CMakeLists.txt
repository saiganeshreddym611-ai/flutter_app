set(FLUTTER_MANAGED_SOURCES
  "generated_plugin_registrant.cc"
  "generated_plugin_registrant.h"
)

# This file is usually managed by Flutter.
# In a real environment, Flutter generates common build rules here.
# We add a stub to ensure CMake doesn't fail during the configuration phase.

macro(apply_standard_settings TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE -Wall -Werror)
endmacro()
