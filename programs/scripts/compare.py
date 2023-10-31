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
                
                while not line2.startswith("reset"):
                    line2 = f2.readline()
                while not line1.startswith("reset"):
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
    
removeunchangedLines("programs/bram.log", "programs/bramLight.log")
removeunchangedLines("programs/dist.log", "programs/distLight.log")
removeunchangedLines("programs/ipgen.log", "programs/ipgenLight.log")

removeExes("programs/bramLight.log", "programs/bramLight1.log")

checkDiff("programs/bramLight.log", "programs/distLight.log", "programs/diff.log")
checkDiff("programs/bramLight1.log", "programs/ipgenLight.log", "programs/diff2.log")
