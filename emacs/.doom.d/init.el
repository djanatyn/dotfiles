(doom!
 :checkers (syntax-checker +childframe)

 :completion (company +auto) (ivy +childframe +icons +fuzzy)

 :ui doom doom-dashboard doom-quit modeline ophints hl-todo
 nav-flash (popup +all +defaults) ligatures vc-gutter vi-tilde-fringe
 window-select treemacs hydra zen minimap workspaces

 :editor snippets (evil +everywhere) file-templates (format +onsave) parinfer
 :emacs dired electric fold vc (undo +tree)
 :tools lookup eval editorconfig make magit pass tmux
 :lang elm dhall data (haskell +lsp) markdown nix (org +roam +dragndrop +pandoc) rust (sh +zsh) racket
 :config (default +bindings +snippets +evil-commands))
