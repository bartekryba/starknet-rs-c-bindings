use starknet_ff::FieldElement;

fn ptr_to_fe(ptr: *const u8, size: usize) -> FieldElement {
  let bytes = unsafe { std::slice::from_raw_parts(ptr, size) };

  let fe = FieldElement::from_bytes_be(bytes.try_into().unwrap()).unwrap();

  return fe;
}

fn fe_to_ptr(fe: FieldElement, ptr: *mut u8, size: usize) {
  let bytes = fe.to_bytes_be();

  unsafe {
    std::ptr::copy(bytes.as_ptr(), ptr, size);
  }
}

#[no_mangle]
pub extern "C" fn generate_k(
  p_message_hash: *const u8,
  p_private_key: *const u8,
  p_seed: *const u8,
  out_buffer: *mut u8,
) -> i32 {
  let message_hash = ptr_to_fe(p_message_hash, 32);
  let private_key = ptr_to_fe(p_private_key, 32);
  let seed = ptr_to_fe(p_seed, 32);

  let output_fe = starknet_crypto::rfc6979_generate_k(&message_hash, &private_key, Option::Some(&seed));
  fe_to_ptr(output_fe, out_buffer, 32);

  return 0;
}