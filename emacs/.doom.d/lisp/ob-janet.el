;;; ob-janet.el --- Org Babel support for Janet -*- lexical-binding: t; -*-

(require 'ob)

(defvar org-babel-janet-command "janet"
  "Command to invoke Janet.")

(defvar org-babel-janet-path
  (expand-file-name "~/janet-tree/jpm_tree/lib")
  "Path to Janet modules for use with org-babel.")

(defun org-babel-execute:janet (body params)
  "Execute a block of Janet code with org-babel.
When :async is specified, run without blocking Emacs."
  (let* ((tmp (org-babel-temp-file "janet-" ".janet"))
         (async (assq :async params))
         (process-environment
          (cons (format "JANET_PATH=%s" org-babel-janet-path)
                process-environment)))
    (with-temp-file tmp
      (insert body))
    (if (and async (not (equal (cdr async) "no")))
        (ob-janet--execute-async tmp params process-environment)
      (org-babel-eval
       (format "%s %s" org-babel-janet-command
               (org-babel-process-file-name tmp))
       ""))))

(defun ob-janet--execute-async (tmp-file params env)
  "Run janet asynchronously, inserting results when done."
  (let* ((buf (generate-new-buffer " *ob-janet-async*"))
         (result-params (cdr (assq :result-params params)))
         (process-environment env))
    (set-process-sentinel
     (start-process "ob-janet" buf
                    org-babel-janet-command
                    (org-babel-process-file-name tmp-file))
     (lambda (proc _event)
       (when (eq (process-status proc) 'exit)
         (let ((output (with-current-buffer (process-buffer proc)
                         (buffer-string))))
           (kill-buffer (process-buffer proc))
           (org-babel-insert-result output result-params)))))
    "Executing..."))

(add-to-list 'org-src-lang-modes '("janet" . janet))

(provide 'ob-janet)
;;; ob-janet.el ends here
