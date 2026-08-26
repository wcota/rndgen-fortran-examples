#!/bin/bash

# Compilers and optimization levels to be tested
COMPILERS=("gfortran" "ifx")
OPTIMIZATIONS=("-O0" "-O1" "-O2" "-O3")

# Iterate over each compiler
for compiler in "${COMPILERS[@]}"; do
    # Iterate over each optimization level
    for opt in "${OPTIMIZATIONS[@]}"; do

        # Create the required output directory tree
        out_dir="test/output/${compiler}/${opt}"
        mkdir -p "$out_dir"

        echo "=================================================="
        echo "Starting test suite: Compiler = $compiler | Optimization = $opt"
        echo "=================================================="

        # Iterate over all .f90 files inside the test/ folder
        for test_file in test/*.f90; do

            # Check if the file actually exists (avoids failure if the folder is empty)
            [ -e "$test_file" ] || continue

            # Strip the .f90 extension and the test/ directory prefix
            test_name=$(basename "$test_file" .f90)

            # Define the output file path
            output_file="${out_dir}/${test_name}.txt"

            echo -n " -> Running $test_name... "

            # Run fpm test with the specific flags and save the output
            fpm test "$test_name" --compiler="$compiler" --flag="$opt" > "$output_file" 2>&1

            # Check fpm's exit code to report success or failure
            if [ $? -eq 0 ]; then
                echo -e "[\033[32mOK\033[0m]"

                awk '
                    /\[100%\] Project compiled successfully|Project is up to date/ {
                        line = NR
                    }
                    {
                        lines[NR] = $0
                    }
                    END {
                        for (i = line + 1; i <= NR; i++)
                            print lines[i]
                    }
                ' "$output_file" > "$output_file.tmp" &&
                mv "$output_file.tmp" "$output_file"
            else
                echo -e "[\033[31mFAILED\033[0m] (see $output_file)"
            fi

        done
    done
done

echo "=================================================="
echo "Test suite completed successfully."