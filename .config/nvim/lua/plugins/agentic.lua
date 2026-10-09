return {
  {
    "carlos-algms/agentic.nvim",
    lazy = true,
    opts = {
      provider = "codex-acp",
    },
    keys = {
      {
        "<leader>ag",
        function()
          require("agentic").toggle()
        end,
        mode = { "n", "v", "i" },
        desc = "Toggle Agentic Chat",
      },
      {
        "<leader>ax",
        function()
          require("agentic").add_selection_or_file_to_context()
        end,
        mode = { "n", "v" },
        desc = "Add to Agentic context",
      },
      {
        "<leader>an",
        function()
          require("agentic").new_session()
        end,
        mode = { "n", "v", "i" },
        desc = "New Agentic session",
      },
    },
  },
}
