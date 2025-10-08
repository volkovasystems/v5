# Warp Terminal Control API

**Simple, focused API for basic Warp terminal GUI control**

## Goals
1. **Control Warp GUI programmatically** (open/close window, add/remove tabs)  
2. **Suspend human interaction during control** (xtrlock)
3. **Analyze each action** with screenshots + process verification  
4. **Generate comprehensive per-action reports** (JSON)
5. **Test in lean VirtualBox environment**

## 🚀 Quick Start

**VirtualBox Testing (Recommended)**
```bash
./quick_start.sh full    # Complete: setup + test + results
```

**Direct Host Testing**  
```bash
python3 warp_api.py test    # Run basic test suite
python3 warp_api.py report  # Show results
```

## 📋 Basic Operations

```bash
python3 warp_api.py launch     # Launch Warp window
python3 warp_api.py new-tab    # Add new tab
python3 warp_api.py close-tab  # Close current tab
python3 warp_api.py close      # Close Warp window
python3 warp_api.py test       # Run test suite
python3 warp_api.py report     # Show latest report
```

## 🔧 API Usage

```python
from warp_api import WarpAPI

api = WarpAPI()
api.launch_warp()      # Launch Warp
api.new_tab()          # Add tab  
api.close_tab()        # Close tab
api.run_basic_test()   # Run tests
```

## 📊 What You Get

**Test Results:**
- JSON reports with timestamps and success rates
- Before/after screenshots for visual verification
- Process verification (confirms Warp is running)
- Human input locking during automation

**Example Output:**
```json
{
  "session": {
    "total_actions": 4,
    "successful_actions": 4,
    "success_rate": "100.0%"
  },
  "actions": [
    {
      "action": "launch_warp",
      "success": true,
      "before_screenshot": "screenshots/before_launch_20251008_141530.png",
      "after_screenshot": "screenshots/after_launch_20251008_141533.png"
    }
  ]
}
```

## 🛡️ Safety Features

- **Input Locking**: `xtrlock` prevents human interference during automation
- **Screenshots**: Visual verification of each action
- **Process Checks**: Confirms Warp is running
- **Emergency Unlock**: `Ctrl+Alt+F3` then `pkill -f xtrlock`

## ⚠️ Requirements

**Host System:**
- Linux with X11 (Ubuntu 20.04+)
- Python 3.7+ 
- VirtualBox + Vagrant (for VM testing)

**Auto-installed:**
- Warp Terminal
- xdotool, wmctrl, xtrlock
- pyautogui (Python automation)

## 📁 Files

```
warp-api/
├── warp_api.py          # Main API (single file)
├── quick_start.sh       # VirtualBox automation  
├── Vagrantfile          # VM configuration
└── README.md            # This file
```

## 🎯 Use Cases

- **Development workflows** - Automated environment setup
- **Testing** - GUI automation for Warp terminal  
- **Demos** - Reproducible terminal demonstrations
- **Research** - Analyze Warp GUI behavior programmatically

---

**Ready!** Run `./quick_start.sh full` or `python3 warp_api.py test` to get started.