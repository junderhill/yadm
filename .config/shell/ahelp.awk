# Parser for `ahelp`. Reads shell files and emits one record per line:
#   S|section              from  "# --- section ---"
#   A|name|description     from  alias / _alias_default lines (description = trailing # comment)
#   F|name|description     from  name() { ... }  (trailing # comment, else the comment line above)
#   K|keys|description     from  "#: keys   description"  (two+ spaces separate them)
# Names starting with _ are internal and skipped. POSIX awk only (works with mawk).

/^[ \t]*# --- .* ---/ {
  s = $0; sub(/^[ \t]*# --- /, "", s); sub(/ ---.*$/, "", s); sub(/ \(.*$/, "", s)
  print "S|" s; prev = ""; next
}
/^[ \t]*#: / {
  s = $0; sub(/^[ \t]*#: /, "", s)
  if (match(s, /  +/)) print "K|" substr(s, 1, RSTART - 1) "|" substr(s, RSTART + RLENGTH)
  else print "K|" s "|"
  prev = ""; next
}
/^[ \t]*#/ { prev = $0; sub(/^[ \t]*#[ \t]*/, "", prev); next }
{
  line = $0
  if (match(line, /^[ \t]*[A-Za-z][A-Za-z0-9_-]*\(\)/)) {
    name = substr(line, RSTART, RLENGTH); gsub(/[ \t()]/, "", name)
    desc = prev
    if (match(line, /[ \t]#[ \t].*$/)) { desc = substr(line, RSTART); sub(/^[ \t]*#[ \t]*/, "", desc) }
    if (name != "ahelp") print "F|" name "|" desc
  } else if (match(line, /(^|[ \t;])(alias|_alias_default)[ \t]+/)) {
    rest = substr(line, RSTART + RLENGTH); names = ""
    while (match(rest, /^[ \t]*[A-Za-z0-9_.-]+=('[^']*'|"[^"]*"|[^ \t;]+)/)) {
      tok = substr(rest, RSTART, RLENGTH); rest = substr(rest, RSTART + RLENGTH)
      sub(/^[ \t]*/, "", tok); sub(/=.*/, "", tok); names = names " " tok
    }
    desc = ""
    if (match(rest, /#.*$/)) { desc = substr(rest, RSTART + 1); sub(/^[ \t]*/, "", desc) }
    n = split(names, arr, " ")
    for (i = 1; i <= n; i++) if (arr[i] !~ /^_/) print "A|" arr[i] "|" desc
  }
  prev = ""
}
