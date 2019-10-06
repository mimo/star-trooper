
# Récupération du nom du projet
$name = Get-Location | Split-Path -Leaf
$releasedir = "release"
$archive    = "$releasedir\${name}.zip"
$lovefile   = "$releasedir\${name}.love"
$executable = "$releasedir\$name\${name}.exe"
$love = "$releasedir\$name\love.exe"

# Création de l'archive .love
mkdir -Force $releasedir
Get-ChildItem -Path ".\*" -Include *.lua | Compress-Archive -DestinationPath "$archive" -CompressionLevel Optimal -Force
Start-Sleep 1
Get-ChildItem -Directory -Exclude bin | Compress-Archive -DestinationPath "$archive" -CompressionLevel Optimal -Update
Move-Item "$archive" "$lovefile"

# Copie des binaires Love2d
mkdir -Force "$releasedir\$name"
Get-Command love.exe | Split-Path | Get-ChildItem -Exclude "Uninstall.exe","lovec.exe" | Copy-Item -Destination "$releasedir\$name"

# copie executable
Get-Content "$love",$lovefile -Enc Byte -Read 512 | Set-Content $executable -Enc Byte -Force
