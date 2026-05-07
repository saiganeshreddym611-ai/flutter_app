cmake_minimum_required(VERSION 3.10)
project(work_audiobook_clone LANGUAGES CXX)

set(BINARY_NAME "work_audiobook_clone")

find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK3 REQUIRED IMPORTED_TARGET gtk+-3.0)

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

# Add the Flutter library to the project.
add_subdirectory(flutter)

# Include the flutter directory
include(flutter/generated_plugins.cmake)

# The list of source files
add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_SOURCES}"
)

# Apply standard Flutter build settings
apply_standard_settings(${BINARY_NAME})

# Set the target properties for the binary
set_target_properties(${BINARY_NAME} PROPERTIES
  CXX_STANDARD 17
  CXX_STANDARD_REQUIRED ON
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
)

# Link dependencies
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK3)

# Install rules
install(TARGETS ${BINARY_NAME} DESTINATION "${CMAKE_INSTALL_PREFIX}" COMPONENT Runtime)
