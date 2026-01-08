# ========================================================
#  TERMINAL PRESENTER TOOL
# ========================================================
# Usage: .\present.ps1
# Controls: Press Enter to go to next slide. 'q' to quit.

$SlideFile = "idea.md"

if (-not (Test-Path $SlideFile)) {
    Write-Host "Error: $SlideFile not found." -ForegroundColor Red
    exit
}

# Read content and split by "### Slide" header
$Content = Get-Content $SlideFile -Raw
$Slides = $Content -split "(?=### Slide)"

# Filter out empty entries (often the first one before the first header)
$Slides = $Slides | Where-Object { $_.Trim().Length -gt 0 }

# Helper: Convert Markdown to ANSI
function Format-Markdown {
    param($Text)

    # ANSI Codes
    $ESC = [char]27
    $Reset = "$ESC[0m"
    $Bold = "$ESC[1m"
    $Italic = "$ESC[3m"
    $Cyan = "$ESC[36m"
    $Yellow = "$ESC[33m"
    $Green = "$ESC[32m"
    $Gray = "$ESC[90m"
    $White = "$ESC[37m"
    $Magenta = "$ESC[35m"
    $BgDark = "$ESC[40m"

    # 1. Headers (### ...)
    if ($Text -match "^#\s+(.*)") { return "${Bold}${Cyan}$($Matches[1].ToUpper())${Reset}" }
    if ($Text -match "^##\s+(.*)") { return "${Bold}${Green}$($Matches[1])${Reset}" }
    if ($Text -match "^###\s+(.*)") { return "${Bold}${Yellow}$($Matches[1])${Reset}" }

    # 2. Blockquotes (> ...)
    if ($Text -match "^>\s+(.*)") { return "${Gray}  ▎ $($Matches[1])${Reset}" }

    # 3. Code Blocks (```) - Warning: Simplistic handling
    if ($Text -match "^```") { return "${Gray}----------------------------------------${Reset}" }

    # 4. Bold (**text**)
    $Text = $Text -replace "\*\*(.*?)\*\*", "${Bold}`$1${Reset}"

    # 5. Italic (*text*)
    $Text = $Text -replace "\*(.*?)\*", "${Italic}`$1${Reset}"

    # 6. Inline Code (`text`)
    $Text = $Text -replace "`([^`]*)`", "${Magenta}`$1${Reset}"

    # 7. Lists
    if ($Text -match "^\*\s+(.*)") { return "  ${Yellow}•${Reset} $($Matches[1])" }
    if ($Text -match "^\s+\*\s+(.*)") { return "    ${Gray}-${Reset} $($Matches[1])" }

    return $Text
}

$TotalSlides = $Slides.Count
$CurrentSlideIndex = 0

while ($CurrentSlideIndex -lt $TotalSlides) {
    Clear-Host
    $SlideContent = $Slides[$CurrentSlideIndex]
    $Lines = $SlideContent -split "`n"
    
    # Render Slide
    Write-Host "`n" # Top Margin
    foreach ($Line in $Lines) {
        $Formatted = Format-Markdown -Text $Line
        # PowerShell Write-Host doesn't interpret ANSI on older versions easily, 
        # so we rely on the string containing the codes and Host supporting it (Win10+).
        Write-Host $Formatted
    }

    # Footer
    $Progress = "[$($CurrentSlideIndex + 1) / $TotalSlides]"
    $FooterLine = "=" * 60
    Write-Host "`n${FooterLine}" -ForegroundColor DarkGray
    Write-Host "$Progress   (Arrows/Enter: Navigate, Q: Quit)" -ForegroundColor DarkGreen
    
    $Input = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    if ($Input.Character -eq 'q') { break }
    
    # Navigation
    if ($Input.VirtualKeyCode -eq 37 -or $Input.Character -eq 'p') { 
        if ($CurrentSlideIndex -gt 0) { $CurrentSlideIndex-- }
    } elseif ($Input.VirtualKeyCode -eq 39 -or $Input.VirtualKeyCode -eq 13) { 
        # Right Arrow or Enter
        if ($CurrentSlideIndex -lt $TotalSlides - 1) { $CurrentSlideIndex++ }
    }
}

Clear-Host
Write-Host "End of Presentation." -ForegroundColor Cyan
