local M = {}

local chunk_size = 1000
local send_count = 0

local function tmux_command(config, ...)
  local command = { "tmux" }
  local socket_name = config.socket_name or "default"

  if vim.startswith(socket_name, "/") then
    vim.list_extend(command, { "-S", socket_name })
  else
    vim.list_extend(command, { "-L", socket_name })
  end

  vim.list_extend(command, { ... })
  return command
end

local function run(command, input)
  local output
  if input == nil then
    output = vim.fn.system(command)
  else
    output = vim.fn.system(command, input)
  end

  return vim.v.shell_error == 0, vim.trim(output)
end

local function report_error(action, output)
  local detail = output == "" and "unknown tmux error" or output
  vim.notify("vim-slime could not " .. action .. ": " .. detail, vim.log.levels.ERROR)
end

function M.send(config, text)
  local paste = vim.fn["slime#common#bracketed_paste"](text)
  local bracketed_paste, text_to_paste, has_trailing_newline = unpack(paste)

  if text_to_paste == "" then
    return
  end

  -- Leave copy mode before targeting the pane, matching vim-slime's tmux target.
  run(tmux_command(config, "send-keys", "-X", "-t", config.target_pane, "cancel"))

  send_count = send_count + 1
  local buffer_name = ("slime-nvim-%d-%d"):format(vim.fn.getpid(), send_count)
  local character_count = vim.fn.strchars(text_to_paste)
  local offset = 0

  while offset < character_count do
    local chunk = vim.fn.strcharpart(text_to_paste, offset, chunk_size)
    local loaded, load_error = run(
      tmux_command(config, "load-buffer", "-b", buffer_name, "-"),
      chunk
    )
    if not loaded then
      report_error("load its paste buffer", load_error)
      return
    end

    local paste_args = { "paste-buffer", "-b", buffer_name, "-d" }
    if bracketed_paste ~= 0 then
      table.insert(paste_args, "-p")
    end
    vim.list_extend(paste_args, { "-t", config.target_pane })

    local pasted, paste_error = run(tmux_command(config, unpack(paste_args)))
    if not pasted then
      run(tmux_command(config, "delete-buffer", "-b", buffer_name))
      report_error("paste into its target pane", paste_error)
      return
    end

    offset = offset + chunk_size
  end

  if has_trailing_newline ~= 0 then
    local entered, enter_error = run(
      tmux_command(config, "send-keys", "-t", config.target_pane, "Enter")
    )
    if not entered then
      report_error("send Enter to its target pane", enter_error)
    end
  end
end

return M
