result=0

for number in 1 2 3 4; do
    testcase="Testcase${number}"
    output="Testcase${number}Diff"
    status="PASS"
    differences=0
    expected_files=()

    for file in "$testcase"/*.1.txt; do
        [ -f "$file" ] || continue

        partner="${file/.1.txt/.2.txt}"
        name="${file##*/}"
        name="${name%.1.txt}"
        output_file="$output/${name}Diff.txt"

        if ! cmp -s "$file" "$partner"; then
            differences=1
            expected_files+=("${name}Diff.txt")

            if [ ! -f "$output_file" ]; then
                status="FAIL"
            elif ! diff -u \
                <(diff -u "$file" "$partner" | tail -n +3) \
                <(tail -n +3 "$output_file") > /dev/null; then
                status="FAIL"
            fi
        else
            if [ -e "$output_file" ]; then
                status="FAIL"
            fi
        fi
    done

    if [ "$differences" -eq 0 ]; then
        if [ -e "$output" ]; then
            status="FAIL"
        fi
    else
        if [ ! -d "$output" ]; then
            status="FAIL"
        else
            for existing in "$output"/*; do
                [ -e "$existing" ] || continue

                found=0
                for expected in "${expected_files[@]}"; do
                    if [ "${existing##*/}" = "$expected" ]; then
                        found=1
                        break
                    fi
                done

                if [ "$found" -eq 0 ]; then
                    status="FAIL"
                fi
            done
        fi
    fi

    echo "Testcase${number}: $status"

    if [ "$status" = "FAIL" ]; then
        result=1
    fi
done

exit "$result"