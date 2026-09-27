local G = {}

G.setup = function ()
  return {
    settings = {
      gopls = {
        -- Analysis settings
        analyses = {
          fillstruct = true,
          shadow = true,
          unusedparams = true,
          unusedwrite = true,
          useany = true,
        },
        -- Code completion
        completeUnimported = true,
        usePlaceholders = true,
        -- Diagnostics
        staticcheck = true,
        -- Formatting (disabled - we use null-ls for formatting)
        gofumpt = false,
        -- Hints
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
        -- Codelenses
        codelenses = {
          gc_details = false,
          generate = true,
          regenerate_cgo = true,
          run_govulncheck = true,
          test = true,
          tidy = true,
          upgrade_dependency = true,
          vendor = true,
        },
        -- Build tags
        directoryFilters = {
          '-**/.git',
          '-**/node_modules',
          '-**/vendor',
        },
        -- Semantic tokens
        semanticTokens = true,
      },
    },
    -- Additional gopls flags
    flags = {
      debounce_text_changes = 150,
    },
  }
end

return G
