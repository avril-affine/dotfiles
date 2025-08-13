return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    opts = {
        enabled = true,
        heading = {
            icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
            backgrounds = {
                "RenderMarkdownCustomH1Bg",
                "RenderMarkdownCustomH2Bg",
                "RenderMarkdownCustomH3Bg",
                "RenderMarkdownCustomH4Bg",
                "RenderMarkdownCustomH5Bg",
                "RenderMarkdownCustomH6Bg",
            },
            foregrounds = {
                "RenderMarkdownCustomH1Fg",
                "RenderMarkdownCustomH2Fg",
                "RenderMarkdownCustomH3Fg",
                "RenderMarkdownCustomH4Fg",
                "RenderMarkdownCustomH5Fg",
                "RenderMarkdownCustomH6Fg",
            },
        },
    },
}
