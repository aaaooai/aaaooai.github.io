#!/usr/bin/env -S awk -f

BEGIN {
    c = 0
}

c == 0 && /^---$/ {
    slug = FILENAME
    gsub(/.*\//, "", slug)
    gsub(/\.md$/, "", slug)
    outfile = "articles/" slug ".md"
    c=1
    print > outfile
    next
}

c == 1 && /^---$/ {
    print "canonical_url: https://aaaooai.github.io/posts/" slug "/" > outfile
    c=2; print > outfile
    next
}

c == 1 {
    gsub(/^zenn_/, "")
    print > outfile
    next
}

{
    print > outfile
}
