vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO librats/librats
    REF "${VERSION}"
    SHA512 403fe3a213b1620a8d5bf9b2c01a8e0a5144e1bf1aca4d0969b1c75446b545f025afc1d426eeae9a5a4b4228f457bc5e14e46f30f74da092c1e23a8db03bafb9
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bindings         RATS_BINDINGS
        search-features  RATS_SEARCH_FEATURES
        storage          RATS_STORAGE
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" RATS_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" RATS_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DRATS_SHARED_LIBRARY=${RATS_SHARED}
        -DRATS_STATIC_LIBRARY=${RATS_STATIC}
        -DRATS_BUILD_TESTS=OFF
        -DRATS_BUILD_CLIENT=OFF
        -DRATS_BUILD_EXAMPLES=OFF
        -DRATS_INSTALL=ON
        -DRATS_VERSION_OVERRIDE=${VERSION}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME rats CONFIG_PATH lib/cmake/rats)

if("search-features" IN_LIST FEATURES)
    file(APPEND "${CURRENT_PACKAGES_DIR}/include/librats/util/rats_export.h" [[

#ifndef RATS_SEARCH_FEATURES
#define RATS_SEARCH_FEATURES
#endif
]])
endif()

# Headers only — drop debug copy and any binaries that landed under share/.
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

# librats is MIT, but it embeds adapted single-primitive crypto sources and, for
# Android API < 24, a getifaddrs() shim. Each keeps its own notice; see
# THIRD_PARTY_NOTICES.md upstream for provenance and the list of modifications.
vcpkg_install_copyright(
    COMMENT [[
librats is licensed under the MIT license. It additionally embeds adapted
third-party sources that carry their own notices, reproduced below:

  * src/librats/crypto/curve25519.*  curve25519-donna     BSD-3-Clause
  * src/librats/crypto/poly1305.*    poly1305-donna       MIT
  * src/librats/crypto/{chacha,sha256,sha512,blake2*}.*
                                   noise-c                MIT
  * 3rdparty/android/ifaddrs-*     ifaddrs-android        BSD-2-Clause AND
                                   (Android API < 24)     BSD-1-Clause
]]
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/licenses/curve25519-donna.LICENSE"
        "${SOURCE_PATH}/licenses/poly1305-donna.LICENSE"
        "${SOURCE_PATH}/licenses/noise-c.LICENSE"
        "${SOURCE_PATH}/licenses/ifaddrs-android.LICENSE"
)
