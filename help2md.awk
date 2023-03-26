# Initialize usage section (and optional first usage line).
/^Usage:/ {
    usage = 1
    sub(/^Usage: +/, "\n```\n", $0)
    sub(/^Usage:$/, "\n```", $0)
    $0 = "Usage\n-----\n" $0
}

# Initialize section (close usage code if after usage).
/^[a-zA-Z_0-9]+:$/ {
    if (usage) {
      usage = 0
      prev = prev "```\n"
    }

    sub(/:$/, "", $0)
    $0 = "### " $0 "\n\nName | Description\n---- | -----------"
}

# This version is specifically adapted for the help output of
# https://github.com/namhyung/uftrace

# Even case long options are indented more, they are not continuatin lines.
# Make them appear as new command line options to the rest of the matches below
!usage && /     --/ {
      sub(/     --/, " --")
}

# Join continuation lines with previous line.
!usage && /^    / {
    # The real continuation lines have a deep indent.
    # make them appear as the kind of contiuation lines
    # rest of the matches expect:
    subs = sub(/^                          /,"\n:")
    if (subs == 0) {
	    sub(/^ */, "   ", $0)
    }
    prev = prev $0
    next
}

# Format arguments/options table.
!usage && /^  / {
    # for highlighting uppercase strings in options, we don't use monospace for them:
    # sub(/^  /, "`", $0)
    sub(/^  /, "", $0)
    # uftrace.md apparently likes the long options prefixed with a backslash:
    sub(/--/, "\\--", $0)
    # Highlight uppercase strings in the option and option description:
    gsub(/\<[A-Z][A-Z_]+\>/, "*&*")
    # for highlighting uppercase strings in options, we don't use monospace for them:
    # sub(/\]$/, "]`", $0)
    sub(/\]$/, "]", $0)
    # for highlighting uppercase strings in options, we don't use monospace for them:
    # sub(/  +/, "`\n:   ", $0)
    sub(/  +/, "\n:   ", $0)
    print("")
}

# Format usage code.
usage && /^  / {
    sub(/^  /, "", $0)
}

# Initialize buffered line.
NR == 1 {
    prev = $0
}

# Print line (one line buffered).
NR > 1 {
    print prev
    prev = $0
}

END {
    print prev
}
