local primary = 'rgb({{colors.primary.default.hex_stripped}})'
local surface = 'rgb({{colors.surface.default.hex_stripped}})'
local secondary = 'rgb({{colors.secondary.default.hex_stripped}})'
local error = 'rgb({{colors.error.default.hex_stripped}})'
local tertiary = 'rgb({{colors.tertiary.default.hex_stripped}})'
local surface_variant = 'rgb({{colors.surface_variant.default.hex_stripped}})'
local on_surface_variant = 'rgb({{colors.on_surface_variant.default.hex_stripped}})'
local secondary_fixed_dim = 'rgb({{colors.secondary_fixed_dim.default.hex_stripped}})'
local on_primary = 'rgb({{colors.on_primary.default.hex_stripped}})'

hl.config {
  general = {
    col = {
      active_border = {
        colors = {
          primary,
          secondary,
        },
        angle = 45,
      },
      inactive_border = {
        colors = {
          on_surface_variant,
        },
      }
    },
  },
  group = {
    col = {
      border_active = {
        colors = {
          secondary,
          tertiary,
        },
        angle = 45,
      },
      border_inactive = {
        colors = {
          on_surface_variant,
        },
      },
      border_locked_active = {
        colors = {
          error,
          secondary_fixed_dim,
        },
        angle = 45,
      },
      border_locked_inactive = {
        colors = {
          on_primary,
        },
      },
    },
    groupbar = {
      col = {
        active = {
          colors = {
            secondary,
            tertiary,
          },
          angle = 45,
        },
        inactive = {
          colors = {
            on_surface_variant,
          },
        },
        locked_active = {
          colors = {
            error,
            secondary_fixed_dim,
          },
          angle = 45,
        },
        loced_inactive = {
          colors = {
            on_primary,
          },
        },
      },
    },
  },
}
