local M = {}

-- Prompt picker using Telescope
function M.pick(type)
  return function()
    local actions = require("CopilotChat.actions")
    require("CopilotChat.integrations.telescope").pick(actions[type .. "_actions"]())
  end
end

return {
  "CopilotC-Nvim/CopilotChat.nvim",
  branch = "main",
  cmd = "CopilotChat",
  dependencies = {
    { "nvim-telescope/telescope.nvim" },
    { "nvim-lua/plenary.nvim" },
  },
  opts = function()
    local user = vim.env.USER or "User"
    user = user:sub(1, 1):upper() .. user:sub(2)

    -- Base commit prompt template
    local commit_prompt =
    "Take a deep breath and analyze the changes made in the git diff. Then, write a commit message for the %s with commitizen convention, only use lower-case letters. Output the full multi-line command starting with `git commit -m` ready to be pasted into the terminal. If there are references to filenames or the backtics in the commit message, escape them with backslashes. i.e. \\` text with backticks \\`"

    return {
      auto_insert_mode = true,
      question_header = "  " .. user .. " ",
      answer_header = "  Copilot ",
      error_header = "## Error ",
      window = {
        width = 0.4,
      },
      -- Register custom contexts
      contexts = {
        pr_diff = {
          resolve = function()
            -- Check if we're in a git repository
            local is_git = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
            if vim.v.shell_error ~= 0 then
              return { { content = "Not in a git repository", filename = "error", filetype = "text" } }
            end

            -- Fetch the latest changes from the remote repository
            local fetch_result = vim.fn.system("git fetch origin main 2>&1")
            if vim.v.shell_error ~= 0 then
              return { { content = "Failed to fetch from remote: " .. fetch_result, filename = "error", filetype = "text" } }
            end

            -- Get current branch
            local current_branch = vim.fn.system("git rev-parse --abbrev-ref HEAD 2>/dev/null"):gsub("\n", "")
            if vim.v.shell_error ~= 0 or current_branch == "" then
              return { { content = "Failed to get current branch", filename = "error", filetype = "text" } }
            end

            -- Get the diff
            local cmd = string.format("git diff --no-color --no-ext-diff origin/main...%s 2>&1", current_branch)
            local handle = io.popen(cmd)
            if not handle then
              return { { content = "Failed to execute git diff", filename = "error", filetype = "text" } }
            end

            local result = handle:read("*a")
            handle:close()

            -- If there's no diff, return a meaningful message
            if not result or result == "" then
              return { { content = "No changes found between current branch and main", filename = "info", filetype = "text" } }
            end

            return {
              {
                content = result,
                filename = "pr_diff",
                filetype = "diff",
              }
            }
          end,
        },
      },
      -- Custom prompts incorporating git staged/unstaged functionality
      prompts = {
        -- Code related prompts
        Explain = {
          prompt = "Please explain how the following code works.",
          system_prompt = "You are an expert software developer and teacher. Explain the code in a clear, concise way.",
        },
        Review = {
          prompt = "Please review the following code and provide suggestions for improvement.",
          system_prompt = "You are an expert code reviewer. Focus on best practices, performance, and potential issues.",
        },
        Tests = {
          prompt = "Please explain how the selected code works, then generate unit tests for it.",
          system_prompt = "You are an expert in software testing. Generate thorough test cases covering edge cases.",
        },
        Refactor = {
          prompt = "Please refactor the following code to improve its clarity and readability.",
          system_prompt =
          "You are an expert in code refactoring. Focus on making the code more maintainable and easier to understand.",
        },
        FixCode = {
          prompt = "Please fix the following code to make it work as intended.",
          system_prompt =
          "You are an expert programmer. Help fix code issues while maintaining code style and best practices.",
        },
        FixError = {
          prompt = "Please explain the error in the following text and provide a solution.",
          system_prompt =
          "You are an expert in debugging. Help identify and fix the error while explaining the solution.",
        },
        BetterNamings = {
          prompt = "Please provide better names for the following variables and functions.",
          system_prompt =
          "You are an expert in code readability. Suggest clear, descriptive names following naming conventions.",
        },
        Documentation = {
          prompt = "Please provide documentation for the following code.",
          system_prompt = "You are an expert technical writer. Create clear, comprehensive documentation.",
        },
        SwaggerApiDocs = {
          prompt = "Please provide documentation for the following API using Swagger.",
          system_prompt = "You are an expert in API documentation. Create comprehensive Swagger/OpenAPI documentation.",
        },
        SwaggerJsDocs = {
          prompt = "Please write JSDoc for the following API using Swagger.",
          system_prompt =
          "You are an expert in JavaScript documentation. Create comprehensive JSDoc with Swagger annotations.",
        },
        -- Git related prompts
        Commit = {
          prompt = "> #git:staged\n\n" .. string.format(commit_prompt, "change"),
          system_prompt = "You are an expert in writing clear, concise git commit messages following best practices.",
        },
        CommitStaged = {
          prompt = "> #git:staged\n\n" .. string.format(commit_prompt, "staged changes"),
          system_prompt = "You are an expert in writing clear, concise git commit messages following best practices.",
        },
        CommitUnstaged = {
        prompt = "> #git:unstaged\n\n" .. string.format(commit_prompt, "unstaged changes"),
          system_prompt = "You are an expert in writing clear, concise git commit messages following best practices.",
        },
        PullRequest = {
          prompt =
          "> #pr_diff\n\nWrite a pull request description for these changes. Include a clear title, summary of changes, and any important notes.",
          system_prompt =
          [[You are an experienced software engineer about to open a PR. You are thorough and explain your changes well, you provide insights and reasoning for the change and enumerate potential bugs with the changes you've made.

Your task is to create a pull request for the given code changes. Follow these steps:

1. Analyze the git diff changes provided.
2. Draft a comprehensive description of the pull request based on the input.
3. Create the gh CLI command to create a GitHub pull request.

Output Instructions:
- The command should start with `gh pr create`.
- Do not use the new line character in the command since it does not work
- Output needs to be a multi-line command
- Include the `--base main` flag.
- Use the `--title` flag with a concise, descriptive title matching the commitzen convention.
- Use the `--body` flag for the PR description.
- Include the following sections in the body:
  - '## Summary' with a brief overview of changes
  - '## Changes' listing specific modifications
  - '## Additional Notes' for any extra information
- Escape any backticks within the command using backslashes. i.e. \` text with backticks \`
- Wrap the entire command in a code block for easy copy-pasting.]],
        },
        -- Text related prompts
        Summarize = {
          prompt = "Please summarize the following text.",
          system_prompt = "You are an expert in technical writing. Create clear, concise summaries.",
        },
        Spelling = {
          prompt = "Please correct any grammar and spelling errors in the following text.",
          system_prompt = "You are an expert editor. Fix grammar and spelling while maintaining the original meaning.",
        },
        Wording = {
          prompt = "Please improve the grammar and wording of the following text.",
          system_prompt =
          "You are an expert writer. Improve clarity and readability while maintaining the original meaning.",
        },
        Concise = {
          prompt = "Please rewrite the following text to make it more concise.",
          system_prompt =
          "You are an expert in technical writing. Make the text more concise while preserving key information.",
        },
      },
    }
  end,
  keys = {
    { "<c-s>",     "<CR>", ft = "copilot-chat", desc = "Submit Prompt", remap = true },
    { "<leader>a", "",     desc = "+ai",        mode = { "n", "v" } },
    -- Toggle and clear
    {
      "<leader>aa",
      function()
        return require("CopilotChat").toggle()
      end,
      desc = "Toggle (CopilotChat)",
      mode = { "n", "v" },
    },
    {
      "<leader>ax",
      function()
        return require("CopilotChat").reset()
      end,
      desc = "Clear (CopilotChat)",
      mode = { "n", "v" },
    },
    -- Quick chat
    {
      "<leader>aq",
      function()
        local input = vim.fn.input("Quick Chat: ")
        if input ~= "" then
          require("CopilotChat").ask(input)
        end
      end,
      desc = "Quick Chat (CopilotChat)",
      mode = { "n", "v" },
    },
    -- Show help and prompts with telescope
    { "<leader>ah", M.pick("help"),                       desc = "Help Actions (CopilotChat)",   mode = { "n", "v" } },
    { "<leader>ap", M.pick("prompt"),                     desc = "Prompt Actions (CopilotChat)", mode = { "n", "v" } },
    -- Code related commands
    { "<leader>ae", "<cmd>CopilotChatExplain<cr>",        desc = "Explain Code" },
    { "<leader>at", "<cmd>CopilotChatTests<cr>",          desc = "Generate Tests" },
    { "<leader>ar", "<cmd>CopilotChatReview<cr>",         desc = "Review Code" },
    { "<leader>aR", "<cmd>CopilotChatRefactor<cr>",       desc = "Refactor Code" },
    { "<leader>an", "<cmd>CopilotChatBetterNamings<cr>",  desc = "Better Naming" },
    -- Git related commands
    { "<leader>ac", "<cmd>CopilotChatCommit<cr>",         desc = "Generate Commit Message" },
    { "<leader>as", "<cmd>CopilotChatCommitStaged<cr>",   desc = "Commit Staged Changes" },
    { "<leader>au", "<cmd>CopilotChatCommitUnstaged<cr>", desc = "Commit Unstaged Changes" },
    { "<leader>ap", "<cmd>CopilotChatPullRequest<cr>",    desc = "Generate Pull Request" },
    -- Debug and fix
    { "<leader>ad", "<cmd>CopilotChatDebugInfo<cr>",      desc = "Debug Info" },
    { "<leader>af", "<cmd>CopilotChatFixDiagnostic<cr>",  desc = "Fix Diagnostic" },
    -- Models
    { "<leader>am", "<cmd>CopilotChatModels<cr>",         desc = "Select Models" },
  },
  config = function(_, opts)
    local chat = require("CopilotChat")
    local select = require("CopilotChat.select")

    -- Disable line numbers in chat window
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "copilot-chat",
      callback = function()
        vim.opt_local.relativenumber = false
        vim.opt_local.number = false
      end,
    })

    -- Setup CMP integration
    require("CopilotChat.integrations.cmp").setup()

    -- Create commands for visual mode
    vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
      chat.ask(args.args, { selection = select.visual })
    end, { nargs = "*", range = true })

    -- Inline chat with Copilot
    vim.api.nvim_create_user_command("CopilotChatInline", function(args)
      chat.ask(args.args, {
        selection = select.visual,
        window = {
          layout = "float",
          relative = "cursor",
          width = 1,
          height = 0.4,
          row = 1,
        },
      })
    end, { nargs = "*", range = true })

    chat.setup(opts)
  end,
}
