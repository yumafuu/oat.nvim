local M = {}

local config = {
  prefix = "g",
  operators = {
    o = {
      name = "search",
      command = function(text)
        local encoded_text = vim.fn.substitute(text, ' ', '+', 'g')
        local url = "https://www.google.com/search?q=" .. encoded_text
        return "open " .. vim.fn.shellescape(url)
      end,
      description = "Search on Google"
    },
    g = {
      name = "github",
      command = function(text)
        local url = "https://github.com/" .. text
        return "open " .. vim.fn.shellescape(url)
      end,
      description = "Open GitHub repository"
    }
  }
}

local function get_visual_selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start_pos[2], end_pos[2])
  
  if #lines == 0 then
    return ""
  end
  
  if #lines == 1 then
    return string.sub(lines[1], start_pos[3], end_pos[3])
  end
  
  lines[1] = string.sub(lines[1], start_pos[3])
  lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
  
  return table.concat(lines, "\n")
end

local function get_word_under_cursor()
  return vim.fn.expand("<cword>")
end

local function execute_operator(op_key, text)
  local operator = config.operators[op_key]
  if not operator then
    vim.notify("Unknown operator: " .. op_key, vim.log.levels.ERROR)
    return
  end
  
  local function run_command(final_text)
    local command
    if type(operator.command) == "function" then
      command = operator.command(final_text)
    else
      command = operator.command .. " " .. vim.fn.shellescape(final_text)
    end
    
    vim.fn.system(command)
    vim.notify("Executed: " .. command)
  end
  
  -- Check if operator has interactive mode
  if operator.interactive then
    vim.ui.input({
      prompt = "Additional text for " .. operator.name .. ": ",
      default = "",
    }, function(input)
      if input ~= nil then
        local final_text = text .. (input ~= "" and " " .. input or "")
        run_command(final_text)
      end
    end)
  else
    run_command(text)
  end
end

local function create_operator_mapping(op_key)
  return function()
    print("DEBUG: create_operator_mapping called for op_key=" .. op_key)
    _G.oat_operator_func = function(type)
      print("DEBUG: oat_operator_func wrapper called with type=" .. type)
      M.operator_func(type)
    end
    vim.o.operatorfunc = "v:lua.oat_operator_func"
    vim.g.oat_current_operator = op_key
    print("DEBUG: operatorfunc set, returning g@")
    return "g@"
  end
end

function M.operator_func(type)
  local op_key = vim.g.oat_current_operator
  local text = ""
  
  print("DEBUG: operator_func called, type=" .. type .. ", op_key=" .. (op_key or "nil"))
  
  if type == "char" then
    local start_line = vim.fn.line("'[")
    local start_col = vim.fn.col("'[")
    local end_line = vim.fn.line("']")
    local end_col = vim.fn.col("']")
    
    print("DEBUG: char mode - start_line=" .. start_line .. ", start_col=" .. start_col .. ", end_line=" .. end_line .. ", end_col=" .. end_col)
    
    if start_line == end_line then
      local line = vim.fn.getline(start_line)
      text = string.sub(line, start_col, end_col)
    else
      local lines = vim.fn.getline(start_line, end_line)
      lines[1] = string.sub(lines[1], start_col)
      lines[#lines] = string.sub(lines[#lines], 1, end_col)
      text = table.concat(lines, "\n")
    end
  elseif type == "line" then
    local start_line = vim.fn.line("'[")
    local end_line = vim.fn.line("']")
    local lines = vim.fn.getline(start_line, end_line)
    text = table.concat(lines, "\n")
  elseif type == "block" then
    vim.notify("Block selection not supported", vim.log.levels.WARN)
    return
  end
  
  print("DEBUG: extracted text='" .. text .. "'")
  
  if text and text ~= "" then
    execute_operator(op_key, text)
  else
    print("DEBUG: no text extracted")
  end
end

function M.setup(opts)
  opts = opts or {}
  
  if opts.prefix then
    config.prefix = opts.prefix
  end
  
  if opts.operators then
    config.operators = vim.tbl_deep_extend("force", config.operators, opts.operators)
  end
  
  for op_key, _ in pairs(config.operators) do
    vim.keymap.set("n", config.prefix .. op_key, create_operator_mapping(op_key), { expr = true, desc = "Operator: " .. config.operators[op_key].description })
    
    vim.keymap.set("v", config.prefix .. op_key, function()
      local text = get_visual_selection()
      if text and text ~= "" then
        execute_operator(op_key, text)
      end
    end, { desc = "Operator: " .. config.operators[op_key].description })
    
    vim.keymap.set("n", config.prefix .. op_key .. op_key, function()
      local text = get_word_under_cursor()
      if text and text ~= "" then
        execute_operator(op_key, text)
      end
    end, { desc = "Operator on word: " .. config.operators[op_key].description })
  end
  
  -- Add test mappings for debugging
  vim.keymap.set("n", "<leader>test-gow", function()
    print("Testing gow manually...")
    vim.g.oat_current_operator = "o"
    vim.o.operatorfunc = "v:lua.oat_operator_func"
    vim.cmd("normal! g@w")
  end, { desc = "Test gow manually" })
  
  vim.keymap.set("n", "<leader>test-word", function()
    local word = get_word_under_cursor()
    print("Word under cursor: '" .. word .. "'")
    execute_operator("o", word)
  end, { desc = "Test word extraction" })
end

function M.add_operator(key, operator)
  config.operators[key] = operator
  
  vim.keymap.set("n", config.prefix .. key, create_operator_mapping(key), { expr = true, desc = "Operator: " .. operator.description })
  
  vim.keymap.set("v", config.prefix .. key, function()
    local text = get_visual_selection()
    if text and text ~= "" then
      execute_operator(key, text)
    end
  end, { desc = "Operator: " .. operator.description })
  
  vim.keymap.set("n", config.prefix .. key .. key, function()
    local text = get_word_under_cursor()
    if text and text ~= "" then
      execute_operator(key, text)
    end
  end, { desc = "Operator on word: " .. operator.description })
end

function M.list_operators()
  for key, op in pairs(config.operators) do
    print(config.prefix .. key .. " - " .. op.description)
  end
end

return M