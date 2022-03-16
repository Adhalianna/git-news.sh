#!/bin/bash

if [[ -z ${CODEDIR+true} ]]; then #check if CODEDIR is set
    echo "Please set CODEDIR variable to path (or colon-separated paths) of a directory containing git repositories."
else
    OLDIFS=$IFS
    IFS=":"
    for dir in $CODEDIR; do #read paths in CODEDIR
        if [[ -r "$dir/.git" && -w "$dir/.git" ]]; then #check read-write access to .git
            printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -  #a trick, line through terminal width
            echo ${dir##*/}
            printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
            cd $dir #go to the repository
            git fetch -q
            IFS=$OLDIFS
            git branch --format="%(refname:lstrip=2)" | while read branch ; do
                git log $branch..$branch@{upstream} --pretty=medium --ignore-missing --remove-empty --first-parent --dense --simplify-merges --ancestry-path --date-order --in-commit-order --abbrev-commit --notes --relative-date --right-only 2>/dev/null
            done
            cd - > /dev/null #go back to previous working directory and discard the output
        else
            echo "Missing permissions recquired to access the repository under $dir"
        fi
    IFS=":"
    done
    IFS=OLDIFS
fi