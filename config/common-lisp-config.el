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

;; Modify the Hyperspec root directory to the local version that my Guix home
;; provides.
(require 'os-detection)
(use-package clhs
  :ensure nil ; "Built-in" by Guix Home providing it
  :defer t
  :config
  ;; Point to my LOCAL copy of the Hyperspec.
  (cond
   ((ravenjoad/is-guix-system) (setq common-lisp-hyperspec-root "~/.guix-home/profile/share/HyperSpec-7-0/"))))

(provide 'common-lisp-config)
;;; common-lisp-config.el ends here
