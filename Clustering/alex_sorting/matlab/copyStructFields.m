function dest = copyStructFields( dest, src )
for f = fieldnames(src)'
    dest.(f{1}) = src.(f{1});
end