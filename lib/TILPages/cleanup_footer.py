
path = r"C:\Users\LENOVO\StudioProjects\untitled5\lib\TILPages\TILPracticeExamTestingPage.dart"
with open(path, "r", encoding="utf-8") as f:
    lines = f.readlines()

# Lines 873 to 960 are 0-indexed as 872 to 959
# But wait, let's verify the content first to be sure
start_marker = "// Floating Bottom Buttons (Persistent)"
end_marker = "Positioned("

start_idx = -1
for i, line in enumerate(lines):
    if start_marker in line:
        start_idx = i
        break

if start_idx != -1:
    # Find the matching closing bracket for the Positioned widget
    # This is safer than hardcoding line numbers
    brace_count = 0
    found_positioned = False
    remove_until = -1
    
    for i in range(start_idx, len(lines)):
        if "Positioned(" in lines[i]:
            found_positioned = True
        
        if found_positioned:
            brace_count += lines[i].count("(")
            brace_count -= lines[i].count(")")
            if brace_count == 0:
                remove_until = i
                break
    
    if remove_until != -1:
        print(f"Removing lines {start_idx+1} to {remove_until+1}")
        new_lines = lines[:start_idx] + lines[remove_until+1:]
        with open(path, "w", encoding="utf-8") as f:
            f.writelines(new_lines)
        print("Done.")
    else:
        print("Could not find end of Positioned widget.")
else:
    print("Could not find start marker.")
