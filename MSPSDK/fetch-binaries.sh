#!/usr/bin/env bash
# Downloads the MSP iOS SDK 3.5.2 release binaries into Binaries/ for the local Swift package.
set -euo pipefail

VERSION="3.5.2"
BASE_URL="https://github.com/ParticleMedia/msp-ios-sdk-public/releases/download/${VERSION}"
ROOT="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="${ROOT}/Binaries"

# Release zip -> SHA-256 (from `swift package compute-checksum`).
ZIPS="
MSPCore 2193d2e47eaa034abdf3a6d3f02892a6b4769e85cc58f841338fe76642fe6b37
MSPiOSCore fc05ec55fd7db011e2e51b86e9f29982bcc6f316a9964af865acda8b9e8f1590
MSPSharedLibraries 279d018f2464bb966289c275ef1bca2cfe9ea0650c2da7c537e1f708e49f5229
MSPPrebidAdapter f466d7a1af45f8bc9be287a8137fc13a1769b979a727a357ce6e26d27e8c1dc4
MSPNovaAdapter 5f9224b1fc15dcd2ad93a7ace7065981ec5474383ea7936a67a344a64d3d061b
MSPGoogleAdapter f63f5a2a834ff254be4e9431309913954ccd7687d7f26797da52a729c739b4f9
MSPGoogleAdsTypes c8dc05f59d0ad7b7f6d74b696087236e8e5c5cf916742f9c687c1bcd37310e95
MSPFacebookAdapter 7a456a38bdc36cc06642fe92f56ef65c6293a9355f65a85ca3bc556f0680a4ee
"

# Every xcframework Package.swift references. MSPSnapKit.xcframework is left out on purpose:
# its code is already inside MSPCore and NovaCore, and linking the standalone copy fails under SPM.
EXPECTED="MSPCore MSPiOSCore MSPSharedLibraries MSPPrebidAdapter PrebidMobile OMSDK_Newsbreak1
NovaCore MSPNovaAdapter MSPGoogleAdsTypes MSPGoogleAdapter MSPFacebookAdapter"

all_present() {
  local name
  for name in ${EXPECTED}; do
    [ -d "${BIN_DIR}/${name}.xcframework" ] || return 1
  done
}

if all_present && [ "${1:-}" != "--force" ]; then
  echo "MSP ${VERSION} binaries already in ${BIN_DIR} (use --force to download again)."
  exit 0
fi

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

echo "${ZIPS}" | while read -r name checksum; do
  [ -n "${name}" ] || continue
  zip_path="${WORK_DIR}/${name}.zip"
  echo "Downloading ${name}-${VERSION}.zip"
  curl -fsSL -o "${zip_path}" "${BASE_URL}/${name}-${VERSION}.zip"
  actual="$(shasum -a 256 "${zip_path}" | awk '{print $1}')"
  if [ "${actual}" != "${checksum}" ]; then
    echo "error: checksum mismatch for ${name}-${VERSION}.zip (expected ${checksum}, got ${actual})" >&2
    exit 1
  fi
  unzip -q -o "${zip_path}" -d "${WORK_DIR}/unzipped"
done

rm -rf "${BIN_DIR}"
mkdir -p "${BIN_DIR}"
for name in ${EXPECTED}; do
  # Some zips carry the same xcframework (e.g. OMSDK_Newsbreak1); take the first copy found.
  src="$(find "${WORK_DIR}/unzipped" -type d -name "${name}.xcframework" -prune | head -n 1)"
  if [ -z "${src}" ]; then
    echo "error: ${name}.xcframework not found in the ${VERSION} release zips" >&2
    exit 1
  fi
  cp -R "${src}" "${BIN_DIR}/"
done

echo "MSP ${VERSION} binaries are in ${BIN_DIR}."
