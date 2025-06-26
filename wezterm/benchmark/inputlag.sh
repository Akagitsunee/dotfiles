#!/bin/bash

echo "Input Latency Test for WezTerm"
echo "=============================="
echo "This test measures how quickly WezTerm responds to input"
echo ""

# Test rapid character input
echo "Test 1: Character input responsiveness"
echo "Type 'jjjjjjjjjj' as fast as possible and observe lag"
echo "Press Enter when ready..."
read -r

# Measure time for 1000 character inputs
echo "Test 2: Automated input timing"
if command -v gdate > /dev/null; then
    start_time=$(gdate +%s.%3N)
    for i in {1..1000}; do
        echo -n "j"
    done
    end_time=$(gdate +%s.%3N)
    duration=$(echo "$end_time - $start_time" | bc)
    avg_per_char=$(echo "scale=3; $duration / 1000" | bc)
    echo ""
    echo "1000 characters took: ${duration}s"
    echo "Average per character: ${avg_per_char}ms"
else
    echo "Using basic timing (install coreutils with 'brew install coreutils' for precise timing)"
    start_time=$(date +%s)
    for i in {1..1000}; do
        echo -n "j"
    done
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    echo ""
    echo "1000 characters took: ${duration}s (rough estimate)"
fi

echo ""
echo "Test 3: Visual latency test"
echo "Watch for lag when rapidly pressing j in this loop:"
echo "Press q to quit the test"

echo "Press j repeatedly, then press Enter followed by q to quit"
while IFS= read -r line; do
    if [[ $line == "q" ]]; then
        break
    else
        echo "Input received: $line"
    fi
done

echo ""
echo "Input latency test complete!"