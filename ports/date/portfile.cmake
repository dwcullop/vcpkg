include(vcpkg_common_functions)

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  message(WARNING
    "You will need to also install http://unicode.org/repos/cldr/trunk/common/supplemental/windowsZones.xml into your install location.\n"
    "See https://howardhinnant.github.io/date/tz.html"
  )
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO HowardHinnant/date
  REF 081e9af55b56b8f0a8a43598f5be5469d585e212
  SHA512 2f02ffa8f523acedb34e414b4d82a50561f060366ab237154d84c68bc3f6df7541a8d0a6f655f83a72e8a0e5036f995b28413ed7a3ec607d3d1cf83dd92fa897
  HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

set(HAS_REMOTE_API 0)
if("remote-api" IN_LIST FEATURES)
  set(HAS_REMOTE_API 1)
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS -DHAS_REMOTE_API=${HAS_REMOTE_API}
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-date TARGET_PATH share/unofficial-date)

vcpkg_copy_pdbs()

set(HEADER "${CURRENT_PACKAGES_DIR}/include/date/tz.h")
file(READ "${HEADER}" _contents)
string(REPLACE "#define TZ_H" "#define TZ_H\n#undef HAS_REMOTE_API\n#define HAS_REMOTE_API ${HAS_REMOTE_API}" _contents "${_contents}")
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  string(REPLACE "ifdef DATE_BUILD_DLL" "if 1" _contents "${_contents}")
endif()
file(WRITE "${HEADER}" "${_contents}")

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/date RENAME copyright)
