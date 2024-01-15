-- Custom function to setup command abbreviations
local function setup_command_abbreviations()
    local abbreviations = {
        { 'W!', 'w!' },
        { 'Q!', 'q!' },
        { 'q1', 'q!' },
        { 'Qall!', 'qall!' },
        { 'Wq', 'wq' },
        { 'Wa', 'wa' },
        { 'wQ', 'wq' },
        { 'WQ', 'wq' },
        { 'W', 'w' },
        { 'Q', 'q' },
        { 'Qall', 'qall' }
    }

    for _, abbr in pairs(abbreviations) do
        vim.cmd(string.format("cabbrev %s %s", abbr[1], abbr[2]))
    end
end

setup_command_abbreviations()