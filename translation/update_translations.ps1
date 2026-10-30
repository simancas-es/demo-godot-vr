# Put update_translations.ps1 in project\translation, beside update_po.cmd.
# See translation_guide.txt in the same folder for the complete workflow.
# The parent of translation is the Godot project root, regardless of its name.
# When running a copy stored elsewhere, pass -RootFolder "path\to\project".
param(
    [string] $RootFolder = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"
$RootFolder = (Resolve-Path -LiteralPath $RootFolder).Path.TrimEnd('\', '/')
$TranslationFolder = Join-Path $RootFolder "translation"
$TemporaryFolder = Join-Path $TranslationFolder ".tmp"
$GodotProjectFile = Join-Path $RootFolder "project.godot"
$JsonFile = Join-Path $RootFolder "content\tasks\task_database_demo.json"
$GodotTranslationUpdateUtil = Join-Path $TranslationFolder "update_po.cmd"

# Check inputs before creating or changing any output files.
foreach ($RequiredFile in @($GodotProjectFile, $JsonFile, $GodotTranslationUpdateUtil)) {
    if (-not (Test-Path -LiteralPath $RequiredFile -PathType Leaf)) {
        throw "Missing file: $RequiredFile. Put the script in the project's translation folder, or pass -RootFolder with the Godot project directory."
    }
}
[System.IO.Directory]::CreateDirectory($TemporaryFolder) | Out-Null

########## Extraction from JSON: intermediate text and POT fragment
$JsonData = Get-Content -LiteralPath $JsonFile -Raw -Encoding UTF8 | ConvertFrom-Json
$OutputFile1 = Join-Path $TemporaryFolder "translation-temporary-tasks_text.txt"
$OutputFileTasksPot = Join-Path $TemporaryFolder "translation-tasks_text.pot"

########## Extraction from scenes: intermediate POT fragment
$ExcludeFolders = @("addons", "android", ".godot", ".git", ".tmp")
$OutputFileEmbedPot = Join-Path $TemporaryFolder "translation-embedded_scene_text.txt"

########## Scene list: intermediate files used to update project.godot
$OutputSceneFiles1 = Join-Path $TemporaryFolder "translation-temporary-scene_list.txt"
$OutputSceneFiles2 = Join-Path $TemporaryFolder "translation-godot-project_scene_list.txt"

########## Final template: kept beside the PO files and update_po.cmd
$OutputTemplatePOT = Join-Path $TranslationFolder "base_template.pot"

function Get-TextValues {
    param([Parameter(Mandatory)] $Object)

    $values = @()

    if ($Object -is [PSCustomObject] -or $Object -is [hashtable]) {
        foreach ($key in $Object.PSObject.Properties.Name) {
            if ($key -eq "text" -or $key -like "*_text") {
                $values += $Object.$key
            }
            $values += Get-TextValues $Object.$key
        }
    }
    elseif ($Object -is [System.Collections.IEnumerable] -and -not ($Object -is [string])) {
        foreach ($item in $Object) {
            $values += Get-TextValues $item
        }
    }

    return $values
}

# Extract text values
$TextValues = Get-TextValues $JsonData

# Convert everything to string, filter out nulls
$TextValues = $TextValues | Where-Object { $_ -ne $null } | ForEach-Object { $_.ToString() }

# Save to UTF-8 file
Set-Content -Path $OutputFile1 -Value $TextValues -Encoding UTF8

Write-Host "Done."



# Path to your input and output files
$InputFile = $OutputFile1

# Read all lines from the input file and split into an array
$Lines = (Get-Content -LiteralPath $InputFile -Raw -Encoding UTF8) -split "`r?`n"

# Create or clear the output file
Set-Content -Path $OutputFileTasksPot -Value "" -Encoding UTF8

foreach ($line in $Lines) {
    # Skip empty lines
    if ([string]::IsNullOrWhiteSpace($line)) { continue }

    # Write the msgid/msgstr block
    Add-Content -LiteralPath $OutputFileTasksPot -Encoding UTF8 -Value ("msgid """ + $line + """")
    Add-Content -LiteralPath $OutputFileTasksPot -Encoding UTF8 -Value "msgstr """"`n"  # extra newline after each block
}

Write-Host "Done. Saved $($Lines.Count) lines."





################ extraction from tscn----------------

# Clear output file if it exists
if (Test-Path $OutputFileEmbedPot) { Remove-Item $OutputFileEmbedPot }

# Recursively list project source files, skipping generated and third-party folders.
function Get-ProjectFiles {
    param(
        [string] $Folder,
        [string[]] $Extensions = @(".tscn")
    )
    foreach ($SubFolder in Get-ChildItem -LiteralPath $Folder -Directory) {
        if ($ExcludeFolders -contains $SubFolder.Name) { continue }
        Get-ProjectFiles -Folder $SubFolder.FullName -Extensions $Extensions
    }
    foreach ($File in Get-ChildItem -LiteralPath $Folder -File) {
        if ($Extensions -contains $File.Extension) { Write-Output $File }
    }
}

# Regex pattern for lines containing _text = "..."
$Pattern = '_text\s*=\s*"(.*?)"'

foreach ($File in Get-ProjectFiles -Folder $RootFolder) {
    # Read entire file for speed
    $content = Get-Content -LiteralPath $File.FullName -Raw -Encoding UTF8

    foreach ($match in [regex]::Matches($content, $Pattern)) {
        $Text = $match.Groups[1].Value
        Add-Content -LiteralPath $OutputFileEmbedPot -Encoding UTF8 -Value "msgid `"$Text`""
        Add-Content -LiteralPath $OutputFileEmbedPot -Encoding UTF8 -Value 'msgstr ""'
        Add-Content -LiteralPath $OutputFileEmbedPot -Encoding UTF8 -Value ""
    }
}

Write-Host "Extraction complete. Output saved to $OutputFileEmbedPot"




######## scene-list for godot template generator

# Clear output file
"" | Out-File $OutputSceneFiles1 -Encoding UTF8

# List sources relative to the Godot project root, using the same exclusions.
Get-ProjectFiles -Folder $RootFolder -Extensions @(".gd", ".json", ".tscn") |
Sort-Object FullName |
ForEach-Object {
    $relPath = $_.FullName.Substring($RootFolder.Length).TrimStart("\")
    $resPath = "res://$($relPath -replace '\\','/')"
    $resPath | Out-File $OutputSceneFiles1 -Append -Encoding UTF8
}

# Read all lines, wrap each in quotes, join with commas
$allLines = Get-Content -LiteralPath $OutputSceneFiles1 -Encoding UTF8 | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
$joinedLines = ($allLines | ForEach-Object { '"' + $_ + '"' }) -join ','

# Wrap in Godot PackedStringArray syntax
$singleLine = "locale/translations_pot_files=PackedStringArray($joinedLines)"

# Save to output file with UTF-8 encoding
Set-Content -Path $OutputSceneFiles2 -Value $singleLine -Encoding UTF8

Write-Host "Done! Output saved to $OutputSceneFiles2"




############### Append everything
##Append to godot project file.
# Read replacement line (first line only)
$replacement = (Get-Content -LiteralPath $OutputSceneFiles2 -Encoding UTF8 | Select-Object -First 1)

# Read full file
$content = Get-Content -LiteralPath $GodotProjectFile -Encoding UTF8

# Replace matching line
$updated = $content | ForEach-Object {
    if ($_ -like "locale/translations_pot_files=PackedStringArray*") {
        $replacement
    } else {
        $_
    }
}

# Write back to file
$updated | Set-Content $GodotProjectFile -Encoding UTF8


$confirmation = Read-Host "Create the res://translation/base_template.pot manually (Project Settings -> Localization -> generate template, then type Y to continue"

if ($confirmation -ne "Y") {
    throw "User aborted"
}

# Append A then B into C
Get-Content -LiteralPath $OutputFileTasksPot -Raw -Encoding UTF8 | Add-Content -LiteralPath $OutputTemplatePOT -Encoding UTF8
Get-Content -LiteralPath $OutputFileEmbedPot -Raw -Encoding UTF8 | Add-Content -LiteralPath $OutputTemplatePOT -Encoding UTF8


& $GodotTranslationUpdateUtil
if ($LASTEXITCODE -ne 0) { throw "update_po.cmd failed with exit code $LASTEXITCODE" }
