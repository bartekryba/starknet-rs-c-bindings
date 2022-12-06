#!/bin/sh

cbindgen --lang c --output include/crypto-rs.h

targets=(
  "aarch64-apple-ios"
  "aarch64-apple-ios-sim"
  "x86_64-apple-ios"
)

mkdir -p binaries
mkdir -p frameworks

for target in "${targets[@]}"; do
  rustup target add ${target}
  cargo +nightly build -Z build-std=std,panic_abort --release --target ${target}
done

lipo -create \
  ../target/x86_64-apple-ios/release/libstarknet_c_bindings.a \
  ../target/aarch64-apple-ios-sim/release/libstarknet_c_bindings.a \
  -output binaries/libstarknet_c_bindings_iossimulator.a

lipo -create \
  ../target/aarch64-apple-ios/release/libstarknet_c_bindings.a \
  -output binaries/libstarknet_c_bindings_ios.a

rm -r frameworks/CryptoRs.xcframework

xcodebuild -create-xcframework \
  -library ./binaries/libstarknet_c_bindings_iossimulator.a \
  -headers include/ \
  -library ./binaries/libstarknet_c_bindings_ios.a \
  -headers include/ \
  -output frameworks/CryptoRs.xcframework
