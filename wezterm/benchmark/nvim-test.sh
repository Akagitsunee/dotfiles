#!/bin/bash

echo "Neovim + WezTerm Performance Test"
echo "================================="

# Create a test file with lots of content
echo "Creating test file..."
cat > test_large_file.txt << 'EOF'
# This is a test file for measuring Neovim performance
# It contains various types of content to stress test rendering

import { create } from 'zustand';

interface Preset {
  label: string;
  work: number;
  shortBreak: number;
  longBreak: number;
}

enum Phases {
  WORK,
  SHORTBREAK,
  LONGBREAK,
}

interface Pomodoro {
  phase: Phases;
  timeLeft: number;
  isRunning: boolean;
  sessionCount: number;
  selectedPreset: Preset;
  presets: Preset[];

  // Critical: Store when the current phase started (not when start() was called)
  phaseStartTime: number | null;
  // Store the original duration of the current phase
  phaseDuration: number;

  intervalId: NodeJS.Timeout | null;

  setPreset: (label: string) => void;
  cyclePresets: () => void;
  start: () => void;
  stop: () => void;
  reset: () => void;
  tick: () => void;
  handlePhaseComplete: () => void;
}

const defaultPresets = [
  { label: 'default', work: 25 * 60, shortBreak: 5 * 60, longBreak: 15 * 60 },
  { label: 'deep', work: 15 * 60, shortBreak: 15 * 60, longBreak: 20 * 60 },
  { label: 'ultra', work: 50 * 60, shortBreak: 10 * 60, longBreak: 30 * 60 },
];

// Helper function to send state to Electron (if available)
const sendStateToElectron = (state: Partial<Pomodoro>) => {
  if (typeof window !== 'undefined' && window.electron?.timer?.updateState) {
    const electronState = {
      timeLeft: state.timeLeft,
      isRunning: state.isRunning,
      phase: getPhaseString(state.phase),
      sessionCount: state.sessionCount,
    };
    window.electron.timer.updateState(electronState);
  }
};

const getPhaseString = (phase: Phases): string => {
  switch (phase) {
    case Phases.WORK:
      return 'WORK';
    case Phases.SHORTBREAK:
      return 'SHORT BREAK';
    case Phases.LONGBREAK:
      return 'LONG BREAK';
    default:
      return 'WORK';
  }
};

const usePomodoroStore = create<Pomodoro>((set, get) => ({
  presets: defaultPresets,
  selectedPreset: defaultPresets[0],
  phaseDuration: defaultPresets[0].work,
  timeLeft: defaultPresets[0].work,
  isRunning: false,
  sessionCount: 0,
  phase: Phases.WORK,
  intervalId: null,
  phaseStartTime: null,

  cyclePresets: () => {
    const currentIndex = get().presets.findIndex(
      (selectedPreset) => selectedPreset.label === get().selectedPreset.label,
    );
    const nextIndex = (currentIndex + 1) % get().presets.length;
    const nextPresetName = defaultPresets[nextIndex].label;
    get().setPreset(nextPresetName);
  },

  setPreset: (label: string) => {
    const preset = get().presets.find((p) => p.label === label);
    const { intervalId } = get();
    if (intervalId) {
      clearInterval(intervalId);
    }
    const newState = {
      phaseDuration: preset.work,
      timeLeft: preset.work,
      selectedPreset: preset,
      phase: Phases.WORK,
      isRunning: false,
      sessionCount: 0,
      intervalId: null,
      phaseStartTime: null,
    };
    set(newState);
    sendStateToElectron(newState);
  },

  tick: () => {
    const { isRunning, phaseStartTime, phaseDuration } = get();

    if (!isRunning || !phaseStartTime) {
      return;
    }

    // Calculate how much time should be left based on real elapsed time
    const now = Date.now();
    const elapsedMs = now - phaseStartTime;
    const elapsedSeconds = Math.floor(elapsedMs / 1000);
    const newTimeLeft = Math.max(0, phaseDuration - elapsedSeconds);

    // Update the display
    const newState = { timeLeft: newTimeLeft };
    set(newState);

    // Send updated time to Electron tray
    sendStateToElectron({ ...get(), ...newState });

    // If we've reached zero, handle phase transition
    if (newTimeLeft === 0) {
      get().handlePhaseComplete();
    }
  },

  reset: () => {
    get().stop();
    get().setPreset(get().selectedPreset.label);
  },
}));
export default usePomodoroStore;
EOF

# Duplicate the content to make it larger (safer approach)
echo "Expanding test file..."
cp test_large_file.txt temp_file.txt
for i in {1..10}; do
    cat temp_file.txt >> test_large_file.txt
done
rm temp_file.txt

echo "Test 1: Opening large file in Neovim"
time nvim -c 'set noswapfile' -c 'q!' test_large_file.txt

echo ""
echo "Test 2: Rapid navigation in Neovim"
# Test rapid j/k movements
time nvim -c 'set noswapfile' -c 'normal! 1000j' -c 'normal! 1000k' -c 'q!' test_large_file.txt

echo ""
echo "Test 3: Syntax highlighting performance"
time nvim -c 'set noswapfile' -c 'syntax on' -c 'filetype plugin indent on' -c 'q!' test_large_file.txt

echo ""
echo "Test 4: Search and replace performance"
time nvim -c 'set noswapfile' -c '%s/function/FUNCTION/g' -c 'q!' test_large_file.txt

# Cleanup
rm test_large_file.txt

echo ""
echo "Neovim benchmark complete!"
