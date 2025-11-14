# TTSTT – Text-to-Speech Test Tool (PowerShell)

TTSTT is an interactive **Text-to-Speech (TTS)** utility for Windows PowerShell, using the built-in  
`System.Speech` .NET assembly with optional SSML support and structured logging.

This tool allows you to:
- Select from all installed Windows TTS voices
- Provide text interactively and have it spoken aloud
- Switch voices at any time
- Automatically wrap missing `<p><s>` SSML tags
- Log execution details (if `-logging` is used)
- Measure execution time for each speech output

Intended Uses:
- Quickly preview your SSML snippets to verify pacing/pronunciation/etc...
- Get an idea of how long it takes until the SSML snippet is processed (overlapping with timeouts, etc...)
- Indirectly talk to people you don't want to talk to

---

## Features

- Interactive TTS playback using Windows SpeechSynthesizer  
- Voice discovery (language + voice name)  
- Numeric input validation with fallback to a safe default  
- Mid-session voice changes without restarting  
- Automatic SSML tag handling  
- Execution time measurement  
- Optional timestamped logging  
- Clear error messages and structured exception logging  

---

## Requirements

- **Windows PowerShell 5.1** or **PowerShell 7 with Windows Compatibility Pack**
- Windows **System.Speech** (included with Windows)

---

## Installation

Clone the repository:

```powershell
git clone https://github.com/OHaslinger/TTSTT
cd TTSTT
```
or download ttstt.ps1 directly from GitHub.

---

## Usage

### Basic run

```powershell
PS C:\> .\ttstt.ps1
```

### With logging enabled

```powershell
PS C:\> .\ttstt.ps1 -logging
```

### In-session Commands

| Command      | Action                                 |
|-------------|----------------------------------------|
| `voice`     | Change the currently selected voice.   |
| `exit`      | Exit the program gracefully.           |
| `quit`      | Exit the program gracefully.           |

---

## Example Session

```
Select a voice option:
1) Microsoft David Desktop [en-US]
2) Microsoft Hedda Desktop [de-DE]
3) Microsoft Zira Desktop [en-US]
Enter the number corresponding to your choice (1-n): 2
Enter the text you want to use (with or without <p><s> ... </s></p>) (type 'exit' to quit or 'voice' to change voice): Test

[14.11.2025 13:11:36.695] Speaking with voice: Microsoft Hedda Desktop [de-DE]...
[14.11.2025 13:11:39.202] Speech finished within 2.507 seconds.

Enter the text you want to use (with or without <p><s> ... </s></p>) (type 'exit' to quit or 'voice' to change voice): exit
[14.11.2025 13:11:49.135] Exiting... Goodbye!
```

---

## Project Structure

```
TTSTT/
│── ttstt.ps1         # Main script
│── README.md
│── CHANGELOG.md
│── LICENSE
│── .gitignore
```

---

## License

This project is available under the MIT License.  
See the LICENSE file for details.

---

## Author

**Oliver Haslinger**  
Created: 2025-11-06  
Version: 2.1.0

Contributions and pull requests are welcome!
