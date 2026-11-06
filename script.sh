
for number in 1 2 3 4; do
    testcase="Testcase${number}"
    output="Testcase${number}Diff"

    rm -rf "$output"

    for file in "$testcase"/*.1.txt; do
        [ -f "$file" ] || continue

        partner="${file/.1.txt/.2.txt}"
        name="${file##*/}"
        name="${name%.1.txt}"

        if ! cmp -s "$file" "$partner"; then
            mkdir -p "$output"
            diff -u "$file" "$partner" > "$output/${name}Diff.txt"
        fi
    done
done