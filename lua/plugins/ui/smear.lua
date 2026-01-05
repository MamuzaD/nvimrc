return {
  "sphamba/smear-cursor.nvim",
  event = "VeryLazy",
  opts = {
    -- default preset name to load at startup
    preset = "normal",

    presets = {
      normal = {
        hide_target_hack = true,
        cursor_color = "none",
        particles_enabled = false,
        stiffness = 0.5,
        trailing_stiffness = 0.25,
        trailing_exponent = 4,
        damping = 0.6,
        gradient_exponent = 0,
        gamma = 1,
        never_draw_over_target = true,
      },

      fire_hazard = {
        cursor_color = "#ff4000",
        particles_enabled = true,
        stiffness = 0.5,
        trailing_stiffness = 0.2,
        trailing_exponent = 5,
        damping = 0.6,
        gradient_exponent = 0,
        gamma = 2,
        never_draw_over_target = true,
        hide_target_hack = true,
        particle_spread = 1,
        particles_per_second = 500,
        particles_per_length = 50,
        particle_max_lifetime = 800,
        particle_max_initial_velocity = 20,
        particle_velocity_from_cursor = 0.5,
        particle_damping = 0.15,
        particle_gravity = -50,
        min_distance_emit_particles = 0,
      },
    },
  },

  config = function(_, opts)
    local smear = require("smear_cursor")

    -- apply a preset by name
    local function apply_preset(name, notify)
      local preset = opts.presets[name]
      if not preset then
        vim.notify("smear-cursor: unknown preset '" .. tostring(name) .. "'", vim.log.levels.WARN)
        return
      end
      smear.setup(preset)
      opts.preset = name
      if notify then
        vim.notify("smear-cursor: applied preset '" .. name .. "'", vim.log.levels.INFO)
      end
    end

    -- initial apply
    apply_preset(opts.preset or "fire_hazard", false)

    -- user cmd: :SmearPreset <name>
    vim.api.nvim_create_user_command("SmearPreset", function(cmd)
      apply_preset(cmd.args, true)
    end, {
      nargs = 1,
      complete = function()
        return vim.tbl_keys(opts.presets or {})
      end,
      desc = "Switch smear-cursor preset",
    })

    -- quick cycle through presets (optional keymaps)
    local order = { "normal", "fire_hazard" }
    local idx = 1
    local function find_index(name)
      for i, n in ipairs(order) do
        if n == name then
          return i
        end
      end
      return 1
    end
    idx = find_index(opts.preset or order[1])

    -- next preset
    vim.keymap.set("n", "<leader>us", function()
      idx = (idx % #order) + 1
      apply_preset(order[idx], true)
    end, { desc = "Smear: Next preset" })
  end,
}
