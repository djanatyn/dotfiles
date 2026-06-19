;;; ob-babashka.el --- Org Babel support for Babashka -*- lexical-binding: t; -*-

(require 'ob)

(defvar org-babel-babashka-command "bb"
  "Command to invoke Babashka.")

(defvar org-babel-babashka-project-dir
  (expand-file-name "~/code/babashka-filament")
  "Directory containing bb.edn for org-babel execution.")

(defun org-babel-execute:babashka (body params)
  "Execute a block of Babashka code with org-babel.
When :async is specified, run without blocking Emacs."
  (let* ((tmp (org-babel-temp-file "babashka-" ".clj"))
         (async (assq :async params))
         (default-directory org-babel-babashka-project-dir))
    (with-temp-file tmp
      (insert body))
    (if (and async (not (equal (cdr async) "no")))
        (ob-babashka--execute-async tmp params)
      (org-babel-eval
       (format "%s %s" org-babel-babashka-command
               (org-babel-process-file-name tmp))
       ""))))

(defun ob-babashka--execute-async (tmp-file params)
  "Run babashka asynchronously, inserting results when done."
  (let* ((buf (generate-new-buffer " *ob-babashka-async*"))
         (result-params (cdr (assq :result-params params)))
         (default-directory org-babel-babashka-project-dir))
    (set-process-sentinel
     (start-process "ob-babashka" buf
                    org-babel-babashka-command
                    (org-babel-process-file-name tmp-file))
     (lambda (proc _event)
       (when (eq (process-status proc) 'exit)
         (let ((output (with-current-buffer (process-buffer proc)
                         (buffer-string))))
           (kill-buffer (process-buffer proc))
           (org-babel-insert-result output result-params)))))
    "Executing..."))

(add-to-list 'org-src-lang-modes '("babashka" . clojure))

(provide 'ob-babashka)
;;; ob-babashka.el ends here
