

def byte_to_word(coe: bool = False):
    outName = "programs/prog.coe" if coe else "programs/prog.mem"
    with open(outName, "w") as out:
        with open("programs/prog.hex", "r") as f:
            startString = "memory_initialization_radix=16;\nmemory_initialization_vector=\n"
            if coe:
                out.write(startString)
            startIndex = out.tell()
            line = f.readline()
            while line:
                if line.startswith("@"):
                    if not coe:
                        out.write(line)
                    else:
                        nextoffset = eval("0x"+line[1:])
                        separator = "00000000,\n"
                        while int((out.tell() - startIndex) / (len(separator)+1)) < nextoffset:
                            out.write(separator)
                    
                    line = f.readline()
                    continue
                
                bytes = line.replace("\n", "").split(" ")
                
                for word in range(int(len(bytes) / 4)):
                    outLine = "".join(bytes[word*4:word*4+4][::-1])
                    outLine += ",\n" if coe else " 00000000 00000000 00000000\n"
                    out.write(outLine)
            
                line = f.readline()
    
byte_to_word(True)