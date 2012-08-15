;; djanatyn's emacs config
;; feel free to debug or use, or whatever.

;; -------------
;; vanilla emacs
;; -------------

;; set cc mode indent to 2
(setq c-default-style "bsd"
      c-basic-offset 2)
      
;; remap some commands
(global-set-key "\C-w" 'backward-kill-word)
(global-set-key "\C-x\C-k" 'kill-region)
(global-set-key "\C-cC" 'compile)
(global-set-key "\C-cR" 'recompile)

;; set load path
(add-to-list 'load-path "~/.emacs.d/site-lisp/")
(let ((default-directory "~/.emacs.d/site-lisp/"))
  (normal-top-level-add-subdirs-to-load-path))

;; open with *scratch* buffer
(setq inhibit-splash-screen t)

;; replace tabs with spaces
(setq tab-width 4)
(setq c-basic-offset 4)
(setq indent-tabs-mode nil)

;; make the font sexy
(set-default-font "Terminus-12:medium")

;; disable toolbars and scrollbars for a minimal design
(tool-bar-mode 0)
(scroll-bar-mode 0)
(menu-bar-mode 0)

;; show column numbers at the bottom of the screen
(column-number-mode 1)

;; make the title less boring
(setq frame-title-format "emacs - because notepad sucks")

;; highlight the current line
(global-hl-line-mode 1)

;; backup files are messy and stupid
(setq make-backup-files nil)

;; ido-mode :)
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)

;; line numbers
(global-linum-mode)

;; ----------------
;; emacs extensions
;; ----------------

;; load files
(require 'clojure-mode)
(require 'paredit)
(require 'color-theme)
(require 'evil)
(require 'auto-complete)
(require 'auto-complete-config)
(require 'tumble)

;; set hooks
(add-hook 'clojure-mode (lambda () (paredit-mode +1) (show-paren-mode)))
(add-hook 'slime-repl-mode-hook (lambda () (linum-mode 0)))

;; enable auto-complete
(ac-config-default)

;; set the theme
(color-theme-initialize)
(color-theme-jsc-light2)

;; vim is fast
(evil-mode)

;; djanatyn's org-mode setup
;; -------------------------

;; keybindings
;; -----------
(global-set-key (kbd "<f12>") 'org-agenda)

(global-set-key (kbd "<f9>") 'calendar)

(global-set-key (kbd "<f11>") 'org-clock-goto)
(global-set-key (kbd "C-<f11>") 'org-clock-in)
(global-set-key (kbd "M-<f11>") 'org-clock-out)

(global-set-key (kbd "C-M-r") 'org-capture)

(global-set-key (kbd "<f10>") 'org-insert-heading)
(global-set-key (kbd "S-<f10>") 'org-insert-todo-heading)

;; agenda files
;; ------------
(setq org-agenda-files
  '("~/org-mode/bucket.org"
    "~/org-mode/life.org"
    "~/org-mode/school.org"
    "~/org-mode/code.org"))

;; capture templates
;; -----------------
(setq org-capture-templates
  '(("b" "bucket" entry (file+headline "~/org-mode/bucket.org" "bucket") "** %?\n")
    ("h" "homework" entry (file+headline "~/org-mode/school.org" "homework") "** todo %?\n")
    ("l" "life" entry (file+headline "~/org-mode/life.org" "life") "** todo %?\n")
    ("p" "life-project" entry (file+headline "~/org-mode/life.org" "projects") "** todo %?\n")
    ("P" "school-project" entry (file+headline "~/org-mode/school.org" "projects") "** todo %?\n")
    ("f" "friends" entry (file+headline "~/org-mode/life.org" "friends") "** todo %?\n")
    ("r" "reading" entry (file+headline "~/org-mode/school.org" "reading") "** todo %?\n")
    ("j" "journal" entry (file+datetree "~/org-mode/journal.org") "** %?")))

;; line wrapping in org-mode buffers
(add-hook 'org-mode-hook 'visual-line-mode)

;; enable diary support in org-agenda
(setq org-agenda-include-diary t)

