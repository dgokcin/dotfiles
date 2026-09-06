return {
  "snacks.nvim",
  opts = {
    dashboard = {
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        {
          pane = 2,
          icon = "󰳏",
          desc = "Browse Repo",
          padding = 1,
          key = "b",
          action = function()
            Snacks.gitbrowse()
          end,
        },
        function(self)
          local in_git = Snacks.git.get_root() ~= nil
          local remote = in_git and vim.fn.system("git remote get-url origin 2>/dev/null"):gsub("%s+", "") or ""
          local is_github = remote:find("github%.com") ~= nil
          local is_gitlab = remote:find("gitlab") ~= nil or remote:find("git%.treatwell") ~= nil
          local repo = remote:match("github%.com[:/]([^/]+/[^/]+)")
          repo = repo and repo:gsub("%.git$", "") or ""

          -- Notifications as plain text (not a terminal section) so nothing renders
          -- when empty and no "[Process exited 0]" can appear. Reads a cache file and
          -- refreshes it in the background for the next dashboard open.
          local items = {}
          if in_git and is_github and repo ~= "" then
            local notif_file = vim.fn.stdpath("cache") .. "/dash-gh-notify-" .. repo:gsub("/", "_") .. ".txt"
            local stat = vim.uv.fs_stat(notif_file)
            if not stat or os.time() - stat.mtime.sec > 300 then
              local strip = [[perl -pe 's/\e\[[0-9;]*[A-Za-z]//g; s/\e\][^\a\e]*(?:\a|\e\\)//g; s/[\r\a]//g']]
              vim.fn.jobstart({
                "sh",
                "-c",
                ("gh notify -s -a -n5 -f '%s' 2>/dev/null | grep -v 'No results found.' | %s > '%s'"):format(
                  repo,
                  strip,
                  notif_file
                ),
              })
            end
            local lines = stat and vim.fn.readfile(notif_file) or {}
            lines = vim.tbl_filter(function(l)
              return l:match("%S")
            end, lines)
            if #lines > 0 then
              items[#items + 1] = {
                pane = 2,
                icon = " ",
                title = "Notifications",
                key = "N",
                action = function()
                  vim.ui.open("https://github.com/notifications?query=repo%3A" .. repo:gsub("/", "%%2F"))
                end,
              }
              local width = (self and self.opts and self.opts.width or 60) - 3
              for i, l in ipairs(lines) do
                items[#items + 1] = {
                  pane = 2,
                  indent = 3,
                  padding = i == #lines and 1 or 0,
                  text = { { vim.fn.strcharpart(l, 0, width), hl = "dir" } },
                }
              end
            end
          end

          local cmds = {
            -- {
            --   title = "Open Issues",
            --   cmd = "gh issue list -L 3",
            --   key = "i",
            --   action = function()
            --     vim.fn.jobstart("gh issue list --web", { detach = true })
            --   end,
            --   icon = " ",
            --   height = 7,
            -- },
            {
              icon = " ",
              title = "Open PRs",
              cmd = 'gh pr list -L 3 --json number,title,url,headRefName,createdAt,author 2>/dev/null | jq -r \'.[] | [.url, ("#" + (.number | tostring)), .title[0:45], .headRefName[0:30], .createdAt[0:10], .author.login] | @tsv\' | while IFS=$\'\\t\' read -r url id title branch date author; do printf \'\\e]8;;%s\\e\\\\\' "$url"; printf \'\\e[35m%s\\e[0m\' "$id"; printf \'\\e]8;;\\e\\\\\'; printf \'  \\e[1m%s\\e[0m  \\e[36m(%s)\\e[0m  \\e[2m%s  %s\\e[0m\\n\' "$title" "$branch" "$date" "$author"; done',
              key = "P",
              action = function()
                vim.fn.jobstart("gh pr list --web", { detach = true })
              end,
              height = 7,
              enabled = is_github,
            },
            {
              icon = "󰮠 ",
              title = "My MRs",
              cmd = "glab api 'merge_requests?scope=created_by_me&state=opened&per_page=5' 2>/dev/null | jq -r '.[] | [.web_url, .references.short, .title[0:45], .source_branch[0:30], .created_at[0:10], .author.username] | @tsv' | while IFS=$'\\t' read -r url id title branch date author; do printf '\\e]8;;%s\\e\\\\' \"$url\"; printf '\\e[34m%s\\e[0m' \"$id\"; printf '\\e]8;;\\e\\\\'; printf '  \\e[1m%s\\e[0m  \\e[36m(%s)\\e[0m  \\e[2m%s  %s\\e[0m\\n' \"$title\" \"$branch\" \"$date\" \"$author\"; done || echo 'glab not configured'",
              key = "M",
              action = function()
                vim.fn.jobstart("glab mr list --author @me --web", { detach = true })
              end,
              height = 7,
              enabled = is_gitlab,
            },
          }
          for _, cmd in ipairs(cmds) do
            items[#items + 1] = vim.tbl_extend("force", {
              pane = 2,
              section = "terminal",
              enabled = in_git,
              padding = 1,
              ttl = 5 * 60,
              indent = 3,
            }, cmd)
          end
          return items
        end,
        { section = "startup" },
      },
      preset = {
        pick = function(cmd, opts)
          return LazyVim.pick(cmd, opts)()
        end,
        header = [[
          ¯\_(ツ)_/¯
        ]],
        -- stylua: ignore
        ---@type snacks.dashboard.Item[]
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
    input = { enabled = true },
    notifier = { enabled = true },
    picker = {
      enabled = true,
      sources = {
        files = { hidden = true, ignored = false },
        smart = { hidden = true, ignored = false },
        grep = { hidden = true, ignored = false },
      },
    },
  },
}
