return {
  -- lspconfig
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      { "mason-org/mason-lspconfig.nvim", config = function() end },
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            -- See the configuration section for more details
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            { path = "snacks.nvim", words = { "Snacks" } },
          },
        },
      },
    },
    opts_extend = { "servers.*.keys" },
    opts = {
      diagnostics = {
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
            [vim.diagnostic.severity.INFO] = "󰋼 ",
          },
        },
      },
      inlay_hints = { enabled = true },
      codelens = { enabled = false },
      folds = { enabled = true },
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },
      servers = {
        -- configuration for all lsp servers
        ["*"] = {
          capabilities = {
            workspace = {
              fileOperations = {
                didRename = true,
                willRename = true,
              },
            },
          },
          -- stylua: ignore
          keys = {
            { "<leader>cl", function() require("telescope.builtin").lsp_document_symbols() end, desc = "LSP Symbols (Buffer)" },
            { "gd", function() require("telescope.builtin").lsp_definitions({ reuse_win = true }) end, desc = "Goto Definition" },
            { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References", nowait = true },
            { "gI", function() require("telescope.builtin").lsp_implementations({ reuse_win = true }) end, desc = "Goto Implementation" },
            { "gy", function() require("telescope.builtin").lsp_type_definitions({ reuse_win = true }) end, desc = "Goto T[y]pe Definition" },
            { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
            { "K", function() return vim.lsp.buf.hover() end, desc = "Hover" },
            { "gK", function() return vim.lsp.buf.signature_help() end, desc = "Signature Help", has = "signatureHelp" },
            { "<c-k>", function() return vim.lsp.buf.signature_help() end, mode = "i", desc = "Signature Help", has = "signatureHelp" },
            { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "x" }, has = "codeAction" },
            { "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "x" }, has = "codeLens" },
            { "<leader>cC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = { "n" }, has = "codeLens" },
            { "<leader>cr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
            { "<leader>cA", function() vim.lsp.buf.code_action({ context = { only = { "source" } } }) end, desc = "Source Action", has = "codeAction" },
          },
        },
        stylua = { enabled = false },
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              codeLens = { enable = true },
              completion = {
                callSnippet = "Replace",
              },
              doc = {
                privateName = { "^_" },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
            },
          },
        },
      },
      setup = {},
    },
    config = function(_, opts)
      local function has_capability(client, cap)
        if not cap then
          return true
        end
        return client:supports_method("textDocument/" .. cap)
      end

      local function apply_keys(buf, client, keys)
        for _, key in ipairs(keys or {}) do
          if key.enabled ~= false and has_capability(client, key.has) then
            local lhs = key[1]
            local rhs = key[2]
            if lhs and rhs then
              vim.keymap.set(key.mode or "n", lhs, rhs, {
                buffer = buf,
                desc = key.desc,
              })
            end
          end
        end
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user-lsp-attach", {
          clear = true,
        }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if not client then
            return
          end

          -- setup keymaps
          apply_keys(event.buf, client, opts.servers["*"] and opts.servers["*"].keys)
          apply_keys(event.buf, client, opts.servers[client.name] and opts.servers[client.name].keys)

          -- inlay hints
          if opts.inlay_hints.enabled and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            local ft = vim.bo[event.buf].filetype
            if not vim.tbl_contains(opts.inlay_hints.exclude or {}, ft) then
              vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
            end
          end

          -- code lens
          if opts.codelens.enabled and vim.lsp.codelens and client.server_capabilities.codeLensProvider then
            vim.lsp.codelens.refresh()
            vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
              buffer = event.buf,
              callback = vim.lsp.codelens.refresh,
            })
          end
        end,
      })

      -- diagnostics
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      local ok, mappings = pcall(require, "mason-lspconfig.mappings")
      local mason_servers = ok and vim.tbl_keys(mappings.get_mason_map().lspconfig_to_package) or {}
      local mason_exclude = {}

      local function setup_server(server)
        if server == "*" then
          return false
        end

        local sopts = opts.servers[server]
        if sopts == true then
          sopts = {}
        elseif not sopts then
          sopts = { enabled = false }
        end

        if sopts.enabled == false then
          mason_exclude[#mason_exclude + 1] = server
          return false
        end

        local custom_setup = opts.setup[server] or opts.setup["*"]
        if custom_setup and custom_setup(server, sopts) then
          mason_exclude[#mason_exclude + 1] = server
          return false
        end

        vim.lsp.config(server, sopts)

        local use_mason = sopts.mason ~= false and vim.tbl_contains(mason_servers, server)

        if not use_mason then
          vim.lsp.enable(server)
        end

        return use_mason
      end

      local ensure_installed = vim.tbl_filter(setup_server, vim.tbl_keys(opts.servers))

      local ok_mlsp, mlsp = pcall(require, "mason-lspconfig")
      if ok_mlsp then
        mlsp.setup({
          ensure_installed = ensure_installed,
          automatic_enable = { exclude = mason_exclude },
        })
      end
    end,
  },

  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = {
      { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" },
    },
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)

      local mr = require("mason-registry")

      mr:on("package:install:success", function()
        vim.defer_fn(function()
          pcall(vim.api.nvim_exec_autocmds, "FileType", {
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)

      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local pkg = mr.get_package(tool)
          if not pkg:is_installed() then
            pkg:install()
          end
        end
      end)
    end,
  },
}
