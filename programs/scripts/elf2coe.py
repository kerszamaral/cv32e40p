

def byte_to_word():
    outName = "programs/prog.coe"
    with open(outName, "w") as out:
        with open("programs/prog.hex", "r") as f:
            startString = "memory_initialization_radix=16;\nmemory_initialization_vector=\n"
            out.write(startString)
            startIndex = out.tell()
            line = f.readline()
            while line:
                if line.startswith("@"):
                    nextoffset = eval("0x"+line[1:])
                    separator = "00000000,\n"
                    while int((out.tell() - startIndex) / (len(separator)+1)) < nextoffset:
                        out.write(separator)
                    
                    line = f.readline()
                    continue
                
                bytes = line.replace("\n", "").split(" ")
                
                outLine = ",\n".join(bytes)
                out.write(outLine)
                out.write(",\n")
                line = f.readline()
            out.seek(out.tell()-2)
            out.write(";")
    
byte_to_word()