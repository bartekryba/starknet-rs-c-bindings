#!/bin/sh

cbindgen --lang c --output include/crypto-rs.h

ios_targets=(
  "aarch64-apple-ios"
)

iossimulator_targets=(
  "aarch64-apple-ios-sim"
  "x86_64-apple-ios"
)

targets+=( "${ios_targets[@]}" "${iossimulator_targets[@]}" )

for target in "${targets[@]}"; do
  rustup target add ${target}
  cargo build --release --target ${target}
done

lipo -create \
  ../target/x86_64-apple-ios/release/libstarknet_c_bindings.a \
  ../target/aarch64-apple-ios-sim/release/libstarknet_c_bindings.a \
  -output libstarknet_c_bindings_iossimulator.a

lipo -create \
  ../target/aarch64-apple-ios/release/libstarknet_c_bindings.a \
  -output libstrarknet_c_bindings_ios.a

rm -r CryptoRs.xcframework

xcodebuild -create-xcframework \
  -library ./libstarknet_c_bindings_iossimulator.a \
  -headers include/ \
  -library ./libstrarknet_c_bindings_ios.a \
  -headers include/ \
  -output CryptoRs.xcframework
