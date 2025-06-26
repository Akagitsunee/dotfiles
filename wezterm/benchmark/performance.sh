#!/bin/bash

echo "WezTerm Performance Benchmark"
echo "============================="

# Test 1: Rapid text output
echo "Test 1: Rapid text output (10,000 lines)"
time for i in {1..10000}; do
    echo "This is line $i with some text to render"
done > /dev/null

echo ""

# Test 2: Color rendering
echo "Test 2: Color rendering (1,000 colored lines)"
time for i in {1..1000}; do
    color=$((i % 8 + 30))
    echo -e "\033[${color}mColored line $i with formatting\033[0m"
done > /dev/null

echo ""

# Test 3: Cursor movement stress test
echo "Test 3: Cursor movement stress test"
time for i in {1..500}; do
    echo -ne "\033[${i}H\033[2KLine at position $i"
done
echo ""

echo ""

# Test 4: Scrolling performance
echo "Test 4: Scrolling performance (large output)"
time seq 1 50000 | head -1000

echo ""

# Test 5: Input responsiveness simulation
echo "Test 5: Input responsiveness (simulate rapid keystrokes)"
time for i in {1..1000}; do
    echo -n "."
    sleep 0.001  # Simulate 1ms between keystrokes
done
echo ""

echo ""
echo "Benchmark complete!"
echo "Compare these times between different WezTerm configurations."
