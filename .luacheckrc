std = luajit
codes = true

globals = {
  "vim",
}

ignore = {
  "631",  -- max_line_length
  "212/_.*",  -- unused argument, for vars with "_" prefix
}

exclude_files = {
  "tests/minimal_init.lua",
}