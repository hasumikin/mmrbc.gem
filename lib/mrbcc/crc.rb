# frozen_string_literal: true

require "ffi"

module Mrbcc
  module CRC
    extend FFI::Library
    ffi_lib File.expand_path("../../../ext/mrbcc/libcrc.so", __FILE__)
    attach_function :calc_crc_16_ccitt, [:pointer, :int, :int], :int
  end
end

__END__

USAGE:
data should be binarydata
data = "RITE0006xx..."[10..] # xx will be CRC
memBuf = FFI::MemoryPointer.new(:char, data.bytesize)
memBuf.put_bytes(0, data)
crc = Mrbcc::CRC.calc_crc_16_ccitt(memBuf, data.size, 0).to_s(16)
