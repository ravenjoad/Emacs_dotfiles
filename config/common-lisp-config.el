;;; common-lisp-config.el --- Handles everything needed for Common Lisp development -*- lexical-binding: t -*-
;;; Commentary:
;;
;;
;;; Code:

(require 'magit-config)
(require 'snippets-config)
(require 'lispy-config)

(setq inferior-lisp-program "sbcl")

(use-package sly
  :ensure t
  :defer t)

(require 'os-detection)
(use-package clhs
  :ensure nil ; "Built-in" by Guix Home providing it
  :defer t
  :init
  (cond
   ((ravenjoad/is-guix-system)
    (let ((local-hyperspec-path
           (expand-file-name "~/.guix-home/profile/share/HyperSpec-7-0/")))
      ;; Point to my LOCAL copy of the Hyperspec.
      (setq common-lisp-hyperspec-root (concat "file://" local-hyperspec-path))
      (add-to-list 'browse-url-handlers
                   (cons (concat "\\file://" (regexp-quote local-hyperspec-path))
                         #'eww))))))

(provide 'common-lisp-config)
;;; common-lisp-config.el ends here
