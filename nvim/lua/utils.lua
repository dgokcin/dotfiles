local M = {}

local function move_line_or_visual_up_or_down(move_arg)
    local col_num = vim.fn.virtcol('.')
    vim.cmd('silent! ' .. move_arg)
    vim.cmd('normal! ' .. col_num .. '|')
end

local function move_line_or_visual_up(line_getter, range)
    local l_num = vim.fn.line(line_getter)
    local move_arg
    if l_num - vim.v.count1 - 1 < 0 then
        move_arg = '0'
    else
        move_arg = line_getter .. ' -' .. (vim.v.count1 + 1)
    end
    move_line_or_visual_up_or_down(range .. 'move ' .. move_arg)
end

local function move_line_or_visual_down(line_getter, range)
    local l_num = vim.fn.line(line_getter)
    local move_arg
    if l_num + vim.v.count1 > vim.fn.line('$') then
        move_arg = '$'
    else
        move_arg = line_getter .. ' +' .. vim.v.count1
    end
    move_line_or_visual_up_or_down(range .. 'move ' .. move_arg)
end

function M.move_line_up()
    move_line_or_visual_up('.', '')
end

function M.move_line_down()
    move_line_or_visual_down('.', '')
end

function M.move_visual_up()
    move_line_or_visual_up("'<", "'<,'>")
    vim.cmd('normal! gv')
end

function M.move_visual_down()
    move_line_or_visual_down("'>", "'<,'>")
    vim.cmd('normal! gv')
end

-- Function to swap words (placeholder)
function M.swap_words(direction)
    -- Additional logic will bej
    -- This is a placeholder for where you would implement the word swapping logic.
end

-- Inserts a blank line below the current line without losing cursor position
function M.insert_blank_line_below()
    local save_cursor = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_command('normal! o')
    vim.api.nvim_command('normal! \\<Esc>')
    vim.api.nvim_win_set_cursor(0, save_cursor)
end

-- Inserts a blank line above the current line without losing cursor position
function M.insert_blank_line_above()
    local save_cursor = vim.api.nvim_win_get_cursor(0)
    save_cursor[1] = save_cursor[1] + 1 -- Adjust for the added line above
    vim.api.nvim_command('normal! O')
    vim.api.nvim_command('normal! \\<Esc>')
    vim.api.nvim_win_set_cursor(0, save_cursor)
end

return M
