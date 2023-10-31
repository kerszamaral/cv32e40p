
from io import TextIOWrapper


def place_in_file(file: TextIOWrapper, offset: int, lineWidth: int) -> int:
    current_pos = file.tell()
    actual_pos = current_pos - offset
    return actual_pos // lineWidth

def hex_to_coe(in_file: str, out_file: str):
    with open(out_file, "w") as out:
        with open(in_file, "r") as inF:
            start_string = "memory_initialization_radix=16;\nmemory_initialization_vector=\n"
            out.write(start_string)
            
            separator = "00000000,\n"
            start_index = out.tell()
            
            line = inF.readline()
            
            while line:
                if line.startswith("@"):
                    next_offset = eval("0x"+line[1:])
                    
                    while place_in_file(out, start_index, len(separator)+1) < next_offset:
                        out.write(separator)
                    
                    line = inF.readline()
                    continue
                
                bytes = line.replace("\n", "").split(" ")
                
                outLine = ",\n".join(bytes) + ",\n"
                out.write(outLine)
                line = inF.readline()

            out.seek(out.tell()-2)
            out.write(";")
    
hex_to_coe("programs/prog.hex", "programs/prog.coe")
