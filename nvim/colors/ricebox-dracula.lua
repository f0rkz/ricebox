-- ricebox-dracula
-- auto-generated from ricebox theme: dracula

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then vim.cmd("syntax reset") end
vim.o.termguicolors = true
vim.g.colors_name = "ricebox-dracula"

local c = {
  bg       = "#282A36",
  bg_alt   = "#44475A",
  bg_dark  = "#1E1F29",
  fg       = "#F8F8F2",
  fg_alt   = "#6272A4",
  primary  = "#BD93F9",
  secondary= "#8BE9FD",
  alert    = "#FF5555",
  disabled = "#6272A4",
  black    = "#282A36",
  black_br = "#4D4F68",
  red      = "#FF5555",
  red_br   = "#FF6E6E",
  green    = "#50FA7B",
  green_br = "#69FF94",
  yellow   = "#F1FA8C",
  yellow_br= "#FFFFA5",
  blue     = "#BD93F9",
  blue_br  = "#D6ACFF",
  magenta  = "#FF79C6",
  magenta_br="#FF92DF",
  cyan     = "#8BE9FD",
  cyan_br  = "#A4FFFF",
  white    = "#F8F8F2",
  white_br = "#FFFFFF",
}

local hi = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- editor
hi("Normal",       { fg = c.fg, bg = c.bg })
hi("NormalFloat",  { fg = c.fg, bg = c.bg_alt })
hi("FloatBorder",  { fg = c.disabled, bg = c.bg_alt })
hi("Cursor",       { fg = c.bg, bg = c.fg })
hi("CursorLine",   { bg = c.bg_alt })
hi("CursorColumn", { bg = c.bg_alt })
hi("ColorColumn",  { bg = c.bg_alt })
hi("LineNr",       { fg = c.disabled })
hi("CursorLineNr", { fg = c.primary, bold = true })
hi("SignColumn",   { bg = c.bg })
hi("VertSplit",    { fg = c.bg_alt })
hi("WinSeparator", { fg = c.bg_alt })
hi("StatusLine",   { fg = c.fg, bg = c.bg_alt })
hi("StatusLineNC", { fg = c.disabled, bg = c.bg_alt })
hi("TabLine",      { fg = c.disabled, bg = c.bg_alt })
hi("TabLineFill",  { bg = c.bg_alt })
hi("TabLineSel",   { fg = c.bg, bg = c.primary, bold = true })
hi("WinBar",       { fg = c.fg, bg = c.bg })
hi("WinBarNC",     { fg = c.disabled, bg = c.bg })

-- search / selection
hi("Visual",       { bg = c.bg_alt })
hi("VisualNOS",    { bg = c.bg_alt })
hi("Search",       { fg = c.bg, bg = c.yellow })
hi("IncSearch",    { fg = c.bg, bg = c.primary })
hi("CurSearch",    { fg = c.bg, bg = c.primary, bold = true })
hi("Substitute",   { fg = c.bg, bg = c.red })

-- pmenu
hi("Pmenu",        { fg = c.fg, bg = c.bg_alt })
hi("PmenuSel",     { fg = c.bg, bg = c.primary })
hi("PmenuSbar",    { bg = c.bg_alt })
hi("PmenuThumb",   { bg = c.disabled })

-- messages
hi("ErrorMsg",     { fg = c.red, bold = true })
hi("WarningMsg",   { fg = c.yellow })
hi("MoreMsg",      { fg = c.green })
hi("Question",     { fg = c.green })
hi("ModeMsg",      { fg = c.primary, bold = true })

-- diff
hi("DiffAdd",      { bg = c.green, fg = c.bg })
hi("DiffChange",   { bg = c.yellow, fg = c.bg })
hi("DiffDelete",   { bg = c.red, fg = c.bg })
hi("DiffText",     { bg = c.yellow_br, fg = c.bg, bold = true })

-- misc
hi("Folded",       { fg = c.disabled, bg = c.bg_alt })
hi("FoldColumn",   { fg = c.disabled })
hi("NonText",      { fg = c.disabled })
hi("SpecialKey",   { fg = c.disabled })
hi("Conceal",      { fg = c.disabled })
hi("Directory",    { fg = c.blue })
hi("Title",        { fg = c.primary, bold = true })
hi("MatchParen",   { fg = c.primary, bg = c.bg_alt, bold = true })

-- syntax
hi("Comment",      { fg = c.disabled, italic = true })
hi("Constant",     { fg = c.cyan })
hi("String",       { fg = c.green })
hi("Character",    { fg = c.green })
hi("Number",       { fg = c.cyan })
hi("Boolean",      { fg = c.cyan })
hi("Float",        { fg = c.cyan })
hi("Identifier",   { fg = c.fg })
hi("Function",     { fg = c.blue })
hi("Statement",    { fg = c.magenta })
hi("Conditional",  { fg = c.magenta })
hi("Repeat",       { fg = c.magenta })
hi("Label",        { fg = c.magenta })
hi("Operator",     { fg = c.fg_alt })
hi("Keyword",      { fg = c.magenta })
hi("Exception",    { fg = c.magenta })
hi("PreProc",      { fg = c.primary })
hi("Include",      { fg = c.magenta })
hi("Define",       { fg = c.magenta })
hi("Macro",        { fg = c.primary })
hi("PreCondit",    { fg = c.primary })
hi("Type",         { fg = c.yellow })
hi("StorageClass", { fg = c.yellow })
hi("Structure",    { fg = c.yellow })
hi("Typedef",      { fg = c.yellow })
hi("Special",      { fg = c.secondary })
hi("SpecialChar",  { fg = c.secondary })
hi("Tag",          { fg = c.primary })
hi("Delimiter",    { fg = c.fg_alt })
hi("Debug",        { fg = c.red })
hi("Underlined",   { underline = true })
hi("Error",        { fg = c.red })
hi("Todo",         { fg = c.bg, bg = c.yellow, bold = true })

-- treesitter
hi("@variable",            { fg = c.fg })
hi("@variable.builtin",    { fg = c.red })
hi("@variable.parameter",  { fg = c.fg, italic = true })
hi("@constant",            { fg = c.cyan })
hi("@constant.builtin",    { fg = c.cyan })
hi("@module",              { fg = c.yellow })
hi("@string",              { fg = c.green })
hi("@string.escape",       { fg = c.secondary })
hi("@string.regex",        { fg = c.secondary })
hi("@character",           { fg = c.green })
hi("@number",              { fg = c.cyan })
hi("@boolean",             { fg = c.cyan })
hi("@float",               { fg = c.cyan })
hi("@function",            { fg = c.blue })
hi("@function.builtin",    { fg = c.blue })
hi("@function.call",       { fg = c.blue })
hi("@function.method",     { fg = c.blue })
hi("@constructor",         { fg = c.yellow })
hi("@keyword",             { fg = c.magenta })
hi("@keyword.function",    { fg = c.magenta })
hi("@keyword.return",      { fg = c.magenta })
hi("@keyword.operator",    { fg = c.magenta })
hi("@operator",            { fg = c.fg_alt })
hi("@punctuation",         { fg = c.fg_alt })
hi("@punctuation.bracket",  { fg = c.fg_alt })
hi("@punctuation.delimiter",{ fg = c.fg_alt })
hi("@type",                { fg = c.yellow })
hi("@type.builtin",        { fg = c.yellow })
hi("@tag",                 { fg = c.primary })
hi("@tag.attribute",       { fg = c.blue })
hi("@tag.delimiter",       { fg = c.fg_alt })
hi("@property",            { fg = c.cyan })
hi("@comment",             { fg = c.disabled, italic = true })

-- diagnostics
hi("DiagnosticError",      { fg = c.red })
hi("DiagnosticWarn",       { fg = c.yellow })
hi("DiagnosticInfo",       { fg = c.blue })
hi("DiagnosticHint",       { fg = c.cyan })
hi("DiagnosticUnderlineError", { undercurl = true, sp = c.red })
hi("DiagnosticUnderlineWarn",  { undercurl = true, sp = c.yellow })
hi("DiagnosticUnderlineInfo",  { undercurl = true, sp = c.blue })
hi("DiagnosticUnderlineHint",  { undercurl = true, sp = c.cyan })

-- git signs
hi("GitSignsAdd",    { fg = c.green })
hi("GitSignsChange", { fg = c.yellow })
hi("GitSignsDelete", { fg = c.red })

-- telescope
hi("TelescopeBorder",        { fg = c.disabled })
hi("TelescopePromptBorder",  { fg = c.primary })
hi("TelescopePromptTitle",   { fg = c.primary })
hi("TelescopeSelection",     { bg = c.bg_alt })
hi("TelescopeMatching",      { fg = c.primary, bold = true })

-- indent blankline
hi("IndentBlanklineChar",        { fg = c.bg_alt })
hi("IndentBlanklineContextChar", { fg = c.disabled })
