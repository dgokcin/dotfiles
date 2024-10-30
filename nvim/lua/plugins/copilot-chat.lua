local IS_DEV = false

local prompts = { -- Code related prompts Explain = "Please explain how the following code works.", Review = "Please review the following code and provide suggestions for improvement.", Tests = "Please explain how the selected code works, then generate unit tests for it.",
  Refactor = "Please refactor the following code to improve its clarity and readability.",
  FixCode = "Please fix the following code to make it work as intended.",
  FixError = "Please explain the error in the following text and provide a solution.",
  BetterNamings = "Please provide better names for the following variables and functions.",
  Documentation = "Please provide documentation for the following code.",
  SwaggerApiDocs = "Please provide documentation for the following API using Swagger.",
  SwaggerJsDocs = "Please write JSDoc for the following API using Swagger.",
  -- Text related prompts
  Summarize = "Please summarize the following text.",
  Spelling = "Please correct any grammar and spelling errors in the following text.",
  Wording = "Please improve the grammar and wording of the following text.",
  Concise = "Please rewrite the following text to make it more concise.",
  PullRequest = "Please write a pull request for the following code.",
}

return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary", -- Use the canary branch if you want to test the latest features but it might be unstable
    -- Do not use branch and version together, either use branch or version
    dependencies = {
      { "nvim-telescope/telescope.nvim" }, -- Use telescope for help actions
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      question_header = "## User ",
      answer_header = "## Copilot ",
      error_header = "## Error ",
      prompts = prompts,
      auto_follow_cursor = false, -- Don't follow the cursor after getting response
      show_help = false, -- Show help in virtual text, set to true if that's 1st time using Copilot Chat
      mappings = {
        -- Use tab for completion
        complete = {
          detail = "Use @<Tab> or /<Tab> for options.",
          insert = "<Tab>",
        },
        -- Close the chat
        close = {
          normal = "q",
          insert = "<C-c>",
        },
        -- Reset the chat buffer
        reset = {
          normal = "<C-x>",
          insert = "<C-x>",
        },
        -- Submit the prompt to Copilot
        submit_prompt = {
          normal = "<CR>",
          insert = "<C-CR>",
        },
        -- Accept the diff
        accept_diff = {
          normal = "<C-y>",
          insert = "<C-y>",
        },
        -- Yank the diff in the response to register
        yank_diff = {
          normal = "gmy",
        },
        -- Show the diff
        show_diff = {
          normal = "gmd",
        },
        -- Show the prompt
        show_system_prompt = {
          normal = "gmp",
        },
        -- Show the user selection
        show_user_selection = {
          normal = "gms",
        },
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")
      local select = require("CopilotChat.select")
      -- Use unnamed register for the selection
      opts.selection = select.unnamed

      local commit_prompt =
        "Take a deep breath and analyze the changes made in the git diff. Then, write a commit message for the change with commitizen convention, only use lower-case letters. Output the full multi-line command starting with `git commit -m` ready to be pasted into the terminal. If there are backticks in the message, escape them with `\\`."

      -- Override the git prompts message
      opts.prompts.Commit = {
        prompt = commit_prompt,
        selection = select.gitdiff,
        mapping = "<leader>gccd",
      }
      opts.prompts.CommitStaged = {
        prompt = commit_prompt,
        selection = function(source)
          return select.gitdiff(source, true)
        end,
        mapping = "<leader>gccs",
      }

      -- Custom function to get diff between current branch and main
      local function pr_diff(source)
        local select_buffer = require("CopilotChat.select").buffer(source)
        if not select_buffer then
          return nil
        end

        -- Fetch the latest changes from the remote repository
        vim.fn.system("git fetch origin")

        local current_branch = vim.fn.system("git rev-parse --abbrev-ref HEAD"):gsub("\n", "")
        -- Get the parent branch (either main or master)
        local parent_branch = vim.fn.system("git for-each-ref --format='%(refname:short)' refs/heads/ | grep -E '^(main|master|develop)' | head -n 1"):gsub("\n", "")

        if parent_branch == "" then
          return nil -- No common parent branch found
        end

        local cmd = string.format("git diff --no-color --no-ext-diff origin/%s...%s", parent_branch, current_branch)
        local handle = io.popen(cmd)
        if not handle then
          return nil
        end

        local result = handle:read("*a")
        handle:close()

        if not result or result == "" then
          return nil
        end

        select_buffer.filetype = "diff"
        select_buffer.lines = result
        return select_buffer
      end

      opts.prompts.PullRequest = {
        system_prompt = [[
          You are an experienced software engineer about to open a PR. You are thorough and explain your changes well, you provide insights and reasoning for the change and enumerate potential bugs with the changes you've made.

          Your task is to create a pull request for the given code changes. Follow these steps:

          1. Analyze the git diff changes provided.
          2. Draft a comprehensive description of the pull request based on the input.
          3. Create the gh CLI command to create a GitHub pull request.

          Output Instructions:
          - The command should start with `gh pr create`.
          - Do not use the new line character in the command since it does not work
          - Include the `--base main` flag.
          - Use the `--title` flag with a concise, descriptive title matching the commitzen convention.
          - Use the `--body` flag for the PR description.
          - Include the following sections in the body:
            - '## Summary' with a brief overview of changes
            - '## Changes' listing specific modifications
            - '## Additional Notes' for any extra information
          - Escape any backticks within the command using backslashes. i.e. \` text with backticks \`
          - Wrap the entire command in a code block for easy copy-pasting.

          Input Format:
          The expected input format is command line output from git diff that compares all the changes of the current branch with the main repository branch. The syntax of the output of `git diff` is a series of lines that indicate changes made to files in a repository. Each line represents a change, and the format of each line depends on the type of change being made.

          Examples:

          Adding a file:
          +++ b/newfile.txt
          @@ -0,0 +1 @@
          +This is the contents of the new file.

          Deleting a file:
          --- a/oldfile.txt
          +++ b/deleted
          @@ -1 +0,0 @@
          -This is the contents of the old file.

          Modifying a file:
          --- a/oldfile.txt
          +++ b/newfile.txt
          @@ -1,3 +1,4 @@
           This is an example of how to modify a file.
          -The first line of the old file contains this text.
           The second line contains this other text.
          +This is the contents of the new file.

          Moving a file:
          --- a/oldfile.txt
          +++ b/newfile.txt
          @@ -1 +1 @@
           This is an example of how to move a file.

          Renaming a file:
          --- a/oldfile.txt
          +++ b/newfile.txt
          @@ -1 +1,2 @@
           This is an example of how to rename a file.
          +This is the contents of the new file.

          Example Output:
          ```sh
          gh pr create --base main --title "commitzen style title" --body "hello
          multiline
          body
          with \`escaped backticks\`
          "
          ```
        ]],
        prompt = "Please create a pull request for the following code changes.",
        selection = pr_diff,
        mapping = "<leader>gccp",
      }

      chat.setup(opts)
      -- Setup the CMP integration
      require("CopilotChat.integrations.cmp").setup()

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

      -- Restore CopilotChatBuffer
      vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
        chat.ask(args.args, { selection = select.buffer })
      end, { nargs = "*", range = true })

      -- Custom buffer for CopilotChat
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-*",
        callback = function()
          vim.opt_local.relativenumber = true
          vim.opt_local.number = true

          -- Get current filetype and set it to markdown if the current filetype is copilot-chat
          local ft = vim.bo.filetype
          if ft == "copilot-chat" then
            vim.bo.filetype = "markdown"
          end
        end,
      })

      -- Add which-key mappings
      local wk = require("which-key")
      wk.add({
        { "<leader>gc", group = "+Copilot Chat" }, -- group
        { "<leader>gcd", desc = "Show diff" },
        { "<leader>gcp", desc = "System prompt" },
        { "<leader>gcs", desc = "Show selection" },
        { "<leader>gcy", desc = "Yank diff" },
        -- Custom Prompt Mappings
        { "<leader>gcc", group = "+Create" }, -- group
        { "<leader>gccd", desc = "Diff Commit" },
        { "<leader>gccs", desc = "Staged Files Commit" },
        { "<leader>gccp", desc = "Pull Request" },
      })
    end,
    event = "VeryLazy",
    keys = {
      -- Show help actions with telescope
      {
        "<leader>ah",
        function()
          local actions = require("CopilotChat.actions")
          require("CopilotChat.integrations.telescope").pick(actions.help_actions())
        end,
        desc = "CopilotChat - Help actions",
      },
      -- Show prompts actions with telescope
      {
        "<leader>ap",
        function()
          local actions = require("CopilotChat.actions")
          require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
        end,
        desc = "CopilotChat - Prompt actions",
      },
      {
        "<leader>ap",
        ":lua require('CopilotChat.integrations.telescope').pick(require('CopilotChat.actions').prompt_actions({selection = require('CopilotChat.select').visual}))<CR>",
        mode = "x",
        desc = "CopilotChat - Prompt actions",
      },
      -- Code related commands
      { "<leader>ae", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },
      { "<leader>at", "<cmd>CopilotChatTests<cr>", desc = "CopilotChat - Generate tests" },
      { "<leader>ar", "<cmd>CopilotChatReview<cr>", desc = "CopilotChat - Review code" },
      { "<leader>aR", "<cmd>CopilotChatRefactor<cr>", desc = "CopilotChat - Refactor code" },
      { "<leader>an", "<cmd>CopilotChatBetterNamings<cr>", desc = "CopilotChat - Better Naming" },
      -- Chat with Copilot in visual mode
      {
        "<leader>av",
        ":CopilotChatVisual",
        mode = "x",
        desc = "CopilotChat - Open in vertical split",
      },
      {
        "<leader>ax",
        ":CopilotChatInline<cr>",
        mode = "x",
        desc = "CopilotChat - Inline chat",
      },
      -- Custom input for CopilotChat
      {
        "<leader>ai",
        function()
          local input = vim.fn.input("Ask Copilot: ")
          if input ~= "" then
            vim.cmd("CopilotChat " .. input)
          end
        end,
        desc = "CopilotChat - Ask input",
      },
      -- Generate commit message based on the git diff
      {
        "<leader>am",
        "<cmd>CopilotChatCommit<cr>",
        desc = "CopilotChat - Generate commit message for all changes",
      },
      {
        "<leader>aM",
        "<cmd>CopilotChatCommitStaged<cr>",
        desc = "CopilotChat - Generate commit message for staged changes",
      },
      -- Quick chat with Copilot
      {
        "<leader>aq",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            vim.cmd("CopilotChatBuffer " .. input)
          end
        end,
        desc = "CopilotChat - Quick chat",
      },
      -- Debug
      { "<leader>ad", "<cmd>CopilotChatDebugInfo<cr>", desc = "CopilotChat - Debug Info" },
      -- Fix the issue with diagnostic
      { "<leader>af", "<cmd>CopilotChatFixDiagnostic<cr>", desc = "CopilotChat - Fix Diagnostic" },
      -- Clear buffer and chat history
      { "<leader>al", "<cmd>CopilotChatReset<cr>", desc = "CopilotChat - Clear buffer and chat history" },
      -- Toggle Copilot Chat Vsplit
      { "<leader>av", "<cmd>CopilotChatToggle<cr>", desc = "CopilotChat - Toggle" },
      -- Copilot Chat Models
      { "<leader>a?", "<cmd>CopilotChatModels<cr>", desc = "CopilotChat - Select Models" },
    },
  },
}
