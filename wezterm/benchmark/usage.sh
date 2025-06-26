#!/bin/bash

echo "WezTerm Resource Usage Monitor"
echo "============================="
echo "Run this while using WezTerm to monitor resource usage"
echo "Press Ctrl+C to stop"
echo ""

# Create header
printf "%-10s %-8s %-8s %-8s %-10s %-10s\n" "TIME" "CPU%" "MEM(MB)" "GPU%" "TEMP(°C)" "ENERGY"

while true; do
    # Get current time
    TIME=$(date +"%H:%M:%S")
    
    # Get WezTerm process info
    WEZTERM_PID=$(pgrep -f "wezterm-gui" | head -1)
    
    if [ ! -z "$WEZTERM_PID" ]; then
        # CPU and Memory usage (macOS compatible)
        CPU_MEM=$(ps -p $WEZTERM_PID -o pcpu,pmem | tail -1)
        CPU=$(echo $CPU_MEM | awk '{print $1}')
        MEM_PERCENT=$(echo $CPU_MEM | awk '{print $2}')
        
        # Convert memory percentage to MB (rough estimate)
        MEM_MB=$(echo "$MEM_PERCENT * 160 / 1" | bc 2>/dev/null || echo "N/A")
        
        # Simplified output for macOS
        GPU="N/A"
        TEMP="N/A"
        ENERGY="N/A"
        
        printf "%-10s %-8s %-8s %-8s %-10s %-10s\n" "$TIME" "$CPU%" "$MEM_MB" "$GPU" "$TEMP" "$ENERGY"
    else
        printf "%-10s %-8s %-8s %-8s %-10s %-10s\n" "$TIME" "N/A" "N/A" "N/A" "N/A" "N/A"
    fi
    
    sleep 2
done