(doom!
 :checkers (syntax-checker +childframe)

 :completion (company +auto) (ivy +childframe +icons +fuzzy)

 :ui doom doom-dashboard doom-quit modeline ophints hl-todo
 nav-flash (popup +all +defaults) ligatures vc-gutter vi-tilde-fringe
 window-select treemacs hydra zen minimap workspaces

 :editor snippets (evil +everywhere) file-templates (format +onsave)
 multiple-cursors parinfer rotate-text

 :emacs dired electric fold vc

 :term eshell term

 :tools lookup eval ansible docker editorconfig gist make magit pass
 tmux upload

 :lang data emacs-lisp (haskell +lsp) latex markdown nix raku
 (org +noter +roam +pretty +dragndrop +pandoc) (racket +xp) rust
 python (sh +zsh)

 :email notmuch

 :app (rss +org) irc

 :config (default +bindings +snippets +evil-commands))
