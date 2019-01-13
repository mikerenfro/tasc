function index = find_string_index(string, lines)
index = find(strncmp(string, lines, length(string))==1, 1);
