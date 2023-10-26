from pathlib import Path

p = Path("programs/test.coe")

def getWord(data: str) -> str:
    for i in range(0, len(data), 2):
        op, code = s[i:i+2]
        print op, code
    
    

def writeFile(path: Path, data: str):
    with open(path, "w") as f:
        f.write("MEMORY_INITIALIZATION_RADIX=16;")
        f.write("MEMORY_INITIALIZATION_VECTOR=")
        
        
            

        f.write(";")
    
    
writeFile(p)