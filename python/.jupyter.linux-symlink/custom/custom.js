// Configure CodeMirror
require([
  'nbextensions/vim_binding/vim_binding',   // depends your installation
], function() {
  // Map jk to <Esc>
  CodeMirror.Vim.map("jk", "<Esc>", "insert");
  CodeMirror.Vim.map("jk", "<Esc>", "visual");
  CodeMirror.Vim.map("H", "^", "normal");
  CodeMirror.Vim.map("L", "$", "normal");
  CodeMirror.Vim.map("H", "^", "visual");
  CodeMirror.Vim.map("L", "$", "visual");
});
