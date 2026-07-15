Output assets/demo.gif

Require spm

Set Shell "zsh"
Set FontSize 14
Set FontFamily "FiraCode Nerd Font"
Set Width 1280
Set Height 720
Set TypingSpeed 50ms
Set Theme "GitHub Dark"
Set WindowBar Colorful

# 0. Help output — context setting
Type "spm --help" Sleep 500ms Enter
Sleep 4s

# Clear screen for clean transition
Type "clear" Sleep 200ms Enter
Sleep 500ms

# 1. Create new demo_project from the spm CLI
Type "spm new python demo_project" Sleep 500ms Enter
Sleep 4s
 
# Clear screen for clean transition
Type "clear" Sleep 200ms Enter
Sleep 500ms

# 2. Show the content of the project using eza for better legibility
Type "eza --icons --group-directories-first --color=auto ~/projects/demo_project" Sleep 500ms Enter
Sleep 4s

# Clear screen
Type "clear" Sleep 200ms Enter
Sleep 500ms

# 3. Inspect the new project in the list of projects created
Type "spm list" Sleep 500ms Enter
Sleep 4s

# Clear screen
Type "clear" Sleep 200ms Enter
Sleep 500ms

# 4. Show info about the project
Type "spm info demo_project" Sleep 500ms Enter
Sleep 3s