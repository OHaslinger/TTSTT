<#
.SYNOPSIS
    Interactive Text-to-Speech (TTS) script using Windows SSML and System.Speech.
    TTSTT (Text-to-Speech-Test-Tool)

.DESCRIPTION
    This script enables interactive text-to-speech functionality using the 
    built-in Windows SpeechSynthesizer. Users can select from all installed 
    voices and languages, input text dynamically, and have it spoken aloud. 
    The script automatically validates user voice selection and applies a 
    default if the input is invalid.

.PARAMETER None
    All interaction is via console prompts; no script parameters are required.

.PARAMETER logging
    The script doesn't log by default, only if the parameter -logging is used.

.EXAMPLE
    PS C:\> .\ttstt.ps1
    Runs the script interactively. Prompts the user to select a voice from 
    all installed voices and enter text to be spoken aloud. Type 'voice' 
    to change the current voice or 'exit' to end the session gracefully.

.NOTES
    Author      : Oliver Haslinger
    Version     : 2.1.0
    Date        : 2025-11-06
    Requires    : Windows PowerShell 5.1 or later
    Dependencies: System.Speech .NET assembly (built-in)
    License     : MIT. Free to use, modify, and distribute. No warranty.

    Features    :
        - Interactive Text-to-Speech with SSML support
        - Dynamic discovery of all installed Windows voices
        - Voice selection with numeric input validation and default fallback
        - Mid-session voice switching without restarting the script
        - Automatic handling of SSML tags (<p><s> ... </s></p>) if missing
        - Execution time measurement for each speech output
        - Structured logging of user input, chosen voice, and errors
        - Graceful exit with timestamped log entries
#>

param (
    [switch]$logging
)

if ($logging) {
    $date = Get-Date
    $timeStamp = $date.ToString("dd.MM.yyyy HH:mm:ss.fff")
    $logFile = $date.ToString("yyyyMMdd") + "_TTSTT_log.txt"
    $logFilePath = Join-Path -Path $PSScriptRoot -ChildPath $logFile
    Add-Content -Path $logFilePath -Value "`n--------------------------------" -Encoding UTF8
    Add-Content -Path $logFilePath -Value "[$timeStamp] TTSTT starting ...`n" -Encoding UTF8
}

# Function to prompt user for voice selection
function Select-Voice {
    # List available voices
    Write-LogMessage "Select a voice option:"
    $counter = 1
    $voices | ForEach-Object { 
        Write-LogMessage "$counter) $($_.voice) [$($_.language)]"
        $counter++
    }

    $voiceChoice = Read-Host "Enter the number corresponding to your choice (1-n)"

    # Verify if input is numeric
    if ($voiceChoice -match '^\d+$') {
        $voiceChoice = [int]$voiceChoice
        
        # Check if within valid range
        if ($voiceChoice -ge 1 -and $voiceChoice -le $voices.Count) {
            $selectedVoice = $voices.voice[$voiceChoice - 1]
            $selectedLang = $voices.language[$voiceChoice - 1]
        } else {
            Write-LogMessage "Invalid number entered. Using default voice (first voice)."
            $selectedVoice = $voices.voice[0]
            $selectedLang = $voices.language[0]
        }
    } else {
        Write-LogMessage "Invalid input. Using default voice (first voice)."
        $selectedVoice = $voices.voice[0]
        $selectedLang = $voices.language[0]
    }

    Write-LogMessage "`nChosen voice: $selectedVoice [$selectedLang]" -OnlyLog

    # Return selected voice and language as a hashtable
    return @{ voice = $selectedVoice; lang = $selectedLang }
}

# Function to write to host and log file at the same time (if logging switch is active)
function Write-LogMessage {
    param(
        [string]$Message,
        [switch]$OnlyLog
    )
    if (-not $OnlyLog) {
        Write-Host $Message
    }
    if ($logging) {
        Add-Content -Path $logFilePath -Value $Message -Encoding UTF8
    }
}

# Load speech synthesizer
Add-Type -AssemblyName System.Speech
$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer

# Retrieve installed voices
Write-LogMessage "Fetching installed voices ...`n" -OnlyLog

$voices = $synth.GetInstalledVoices() | ForEach-Object {

    $info = $_.VoiceInfo
    $fullName = $info.Name
    $language = $info.Culture.Name

    [PSCustomObject]@{
        voice    = $fullName
        language = $language
    }
}

# Initial voice selection
$selection = Select-Voice
$voice = $selection.voice
$lang  = $selection.lang

while ($true) {
    # Prompt user for text input
    $inputText = Read-Host "Enter the text you want to use (with or without <p><s> ... </s></p>) (type 'exit' to quit or 'voice' to change voice)"
    # Exit condition
    if ($inputText -match '^(exit|quit)$') {
        $date = Get-Date
        $timeStamp = $date.ToString("dd.MM.yyyy HH:mm:ss.fff")
        Write-LogMessage "[$timeStamp] Exiting... Goodbye!"
        break
    }
    # Switch voice mid-session
    if ($inputText -match '^(voice)$') {
        $selection = Select-Voice
        $voice = $selection.voice
        $lang  = $selection.lang
        continue
    }
    # Trim whitespace
    $ttsText = $inputText.Trim()
    # Add missing start tags if needed
    if ($ttsText -notmatch '^\s*<p><s>') {
        $ttsText = "<p><s>$ttsText"
    }
    # Add missing end tags if needed
    if ($ttsText -notmatch '</s></p>\s*$') {
        $ttsText = "$ttsText</s></p>"
    }
    # Generate SSML text
    $finalText = "<speak version='1.0' xmlns='http://www.w3.org/2001/10/synthesis' xml:lang='$lang'><voice name='$voice'>$ttsText</voice></speak>"
    # Speak synchronously
    $startTime = Get-Date
    $formattedTime = $startTime.ToString("dd.MM.yyyy HH:mm:ss.fff")
    Write-LogMessage "Chosen text: $inputText" -OnlyLog
    Write-LogMessage "`n[$formattedTime] Speaking with voice: $voice [$lang]..."
    try {
        $synth.SpeakSsml($finalText)
        $endTime = Get-Date
        $formattedTime = $endTime.ToString("dd.MM.yyyy HH:mm:ss.fff")
        # Calculate duration
        $duration = $endTime - $startTime
        # Output in seconds + milliseconds
        $totalSeconds = [math]::Round($duration.TotalSeconds, 3)
        Write-LogMessage "[$formattedTime] Speech finished within $totalSeconds seconds.`n"
    }
    catch {
        # Generate error message output
        Write-LogMessage "Error: Unable to play the speech. Check your SSML or input text."
        Write-LogMessage "----------------------------------------"
        Write-LogMessage "Exception Message:"
        Write-LogMessage $_.Exception.Message
        Write-LogMessage "----------------------------------------"
        Write-LogMessage "Full Exception Details:"
        Write-LogMessage $_.Exception | Format-List -Force
        Write-LogMessage "----------------------------------------"
        Write-LogMessage "Stack Trace:"
        Write-LogMessage $_.ScriptStackTrace
    }
}
