;; doom modules
;; ============
(doom/set-frame-opacity 80)
(setq display-line-numbers-type 'relative)
(setq doom-font (font-spec :family "Terminess Powerline" :size 14))
(setq doom-theme 'doom-monokai-pro)
(setq org-roam-directory "~/org-roam")

(after! org
  (setq org-agenda-files '("~/org-roam/" "~/org-roam/daily/"))
  (setq org-log-done t)
  (org-babel-lob-ingest "~/org-roam/library-of-babel.org")
  (require 'ucs-normalize))

(after! term
  (setq multi-term-program "/run/current-system/sw/bin/bash"))

(after! notmuch
  (setq +notmuch-sync-backend 'mbsync))

(after! format
  (set-formatter! 'ormolu "ormolu" :modes '(haskell-mode))
  (setq +format-on-save-enabled-modes
        '(not emacs-lisp-mode  ; elisp's mechanisms are good enough
              sql-mode         ; sqlformat is currently broken
              tex-mode         ; latexindent is broken
              latex-mode
              nix-mode)))

(after! magit
  (magit-delta-mode +1))

(use-package! pinentry
  :init (setenv "INSIDE_EMACS" (format "%s,comint" emacs-version))
  :config (pinentry-start))

(use-package! silicon)

;; set ssh agent socket to gpg agent
(defun gpg-ssh ()
  (interactive)
  (setenv "SSH_AUTH_SOCK" (string-trim (shell-command-to-string "gpgconf --list-dirs agent-ssh-socket"))))

(defun tmux-insert ()
  (interactive)
  (insert (string-trim (shell-command-to-string "tmux show-buffer"))))

;; personal keybindings
;; ====================
;; i learned how to do this from https://rameezkhan.me/adding-keybindings-to-doom-emacs/
(map! :leader
      (:prefix-map ("i" . "insert")
       :desc "tmux show-buffer" "l" 'tmux-insert)

      (:prefix-map ("c" . "code")
       :desc "org-structure-template" "," 'org-insert-structure-template
       :desc "license" "l" 'spdx-insert-spdx))

;; fix terminal escape sequences
(unless (display-graphic-p)
  (progn
    (define-key input-decode-map "\e[1;5C" [(control right)])
    (define-key input-decode-map "\e[1;5D" [(control left)])
    (define-key input-decode-map "\e[1;5A" [(control up)])
    (define-key input-decode-map "\e[1;5B" [(control down)])
    (define-key input-decode-map "\e[1;5F" [(meta left)])))

