(doom!
 :checkers (syntax-checker +childframe)

 :completion (company +auto) (ivy +childframe +icons +fuzzy)

 :ui doom doom-dashboard doom-quit modeline ophints hl-todo
 nav-flash (popup +all +defaults) ligatures vc-gutter vi-tilde-fringe
 window-select treemacs hydra zen minimap workspaces (treemacs +lsp)

 :email notmuch
 :editor snippets (evil +everywhere) file-templates (format +onsave) parinfer
 :emacs dired electric fold vc (undo +tree)
 :tools lookup eval editorconfig make magit pass tmux lsp (debugger +lsp) direnv
 :lang elm dhall lua data (haskell +lsp) markdown (org +roam +dragndrop +pandoc) (web +html)
 (rust +lsp) (sh +zsh) racket yaml nix julia common-lisp plantuml zig ruby lua (javascript +lsp)
 :term vterm
 :config (default +bindings +snippets +evil-commands))
