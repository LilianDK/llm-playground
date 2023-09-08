#!/bin/bash

declare -A failed_libs

while read -r lib || [ -n "$lib" ]; do
    echo -n "installing $lib... "

    output=$(R -q -e "install.packages('$lib', repos='https://cran.rstudio.com/')" 2>&1)

    if [[ $output =~ "DONE ($lib)" ]]; then
        echo "OK"
    else
        echo "failed"
        failed_libs[$lib]="$output"
    fi
done <rlibs.txt

for lib in "${!failed_libs[@]}"; do
    echo -e "\n$lib failed with outpout:\n${failed_libs[$lib]}"
done

if ((${#failed_libs[@]})); then
    exit 1
fi

exit 0
