#!/bin/tcsh -f
# Fixes printf variable stucture:
ex -s '+1,$s/\v(printf ")(\\"")?(.*)(\$[{}0-9a-zA-Z_]+)([^">]*")( \>[>!]{0,1} ["]{0,1}[$/][^ ;"]*["]{0,1})?;$/\1\2\3%s\2\5 "\2\4"\2\5\6/g' "$file";

