BEGIN {
    FS="::";
}

{
    for (i = 3; i < 6; i++) {
        if ($i ~ /,/) {
            gsub(/^.*,/, "", $i);
            cenas[$i];
        }
    }
}

END {
    for (cena in cenas)
        print(cena);
}
