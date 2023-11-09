import sys

def removeunchangedLines(filePath: str, outfile: str):
    startString = "addr_A="
    stringSize = "0x00000000"
    start = len(startString)
    middle = start + len(stringSize)
    endString = "addr_A=0x00000004: data_A=0x1920006f addr_B="
    endStart = len(endString)
    endMiddle = endStart + len(stringSize)
    
    with open(filePath, "r") as f:
        with open(outfile, "w") as out:
            line = f.readline()
            prevString = ""
            prevAddr_A = ""
            prevAddr_B = ""
            while line:
                if prevAddr_A != line[start:middle] or prevAddr_B != line[endStart:endMiddle]:
                    out.write(prevString)
                    prevAddr_A = line[start:middle]
                    prevAddr_B = line[endStart:endMiddle]
                
                prevString = line
                line = f.readline()
                
def checkDiff(file1: str, file2: str, outFile: str):
    with open(file1, "r") as f1:
        with open(file2, "r") as f2:
            with open(outFile, "w") as out:
                line1 = f1.readline()
                line2 = f2.readline()
                out.write(f"                               {file1}                                      ||                                 {file2}                                        \n")
                lineNumbr = 1
                
                startWord = "reset"
                while not line2.startswith(startWord):
                    line2 = f2.readline()
                while not line1.startswith(startWord):
                    line1 = f1.readline()
                
                while line1 and line2:
                    
                    if line1 != line2:
                        line1 = line1.replace("\n", "")
                        line2 = line2.replace("\n", "")
                        out.write(f"InLines {lineNumbr}: " + line1 + " || " + line2 + "\n")
                    lineNumbr += 1
                    line1 = f1.readline()
                    line2 = f2.readline()
                    
def removeExes(file1: str, file2: str):
    with open(file1, "r") as f1:
        with open(file2, "w") as f2:
            line = f1.readline()
            remove = "0xxxxxxxxx"
            replace = "0x00000000"
            while line:
                if remove in line:
                    line = line.replace(remove, replace)
                f2.write(line)
                line = f1.readline()



name1 = "normal"
name2 = "test"

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 compare.py <input_file1> <input_file1>")
    else:
        name1 = sys.argv[1]
        name1Light = name1.replace(".log", "Light.log")
        removeunchangedLines(name1, name1Light)
        name2 = sys.argv[2]
        name2Light = name2.replace(".log", "Light.log")
        removeunchangedLines(name2, name2Light)
        
        name1Light1 = name1.replace(".log", "Light1.log")
        removeExes(name1Light, name1Light1)
        name2Light1 = name2.replace(".log", "Light1.log")
        removeExes(name2Light, name2Light1)
        
        checkDiff(name1Light1, name2Light, "diff.log")

