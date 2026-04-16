# plantumldiagrams
a list of planuml diagrams i use for my proyects

# How to generate images
```

# Default (PNG)
.\generate.ps1

# Custom format or jar path
.\generate.ps1 -Format svg
.\generate.ps1 -PlantUmlJar "C:\tools\plantuml.jar"

```

# if want to executed on cdm
```
# Option 1 – bypass policy for this one call (recommended, no permanent changes)
powershell -ExecutionPolicy Bypass -File .\generate.ps1

# Option 2 – dot-source after unblocking the file
Unblock-File .\generate.ps1
.\generate.ps1

```