
print("Reading file...")
with open(r"c:\Users\LENOVO\StudioProjects\untitled5\lib\TILPages\TILPracticeExamTestingPage.dart", "r", encoding="utf-8") as f:
    lines = f.readlines()

print("Printing lines 870 to 970:")
for i in range(870, 970):
    if i < len(lines):
        print(f"{i+1}: {lines[i].rstrip()}")
