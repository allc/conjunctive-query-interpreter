#!/bin/bash

total=0;
pass=0;
fail=0;
echo "--------------------";
for problem in pr*; do
    for test in $problem/test*/; do
        cp ../myinterpreter $test;
        cd $test;
        output=$(./myinterpreter ../../../programs/$problem.cql | sed -E 's/,[[:space:]]+/,/g');
        expected=$(cat out.csv | sed -E 's/,[[:space:]]+/,/g');
        if [ "$output" = "$expected" ]; then
            echo "Test $test passed.";
            echo "Output:"
            echo $output
            ((pass++))
        else
            echo "Test $test failed."
            echo "Output:"
            echo $output
            echo "Expected:"
            echo $expected
            ((fail++))
        fi
        echo "";
        # clean up
        rm myinterpreter;
        cd ../../;
        #count
        ((total++));
    done
    echo "--------------------";
done
echo "$total tests in total, $pass passed, $fail failed."
