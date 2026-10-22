;;; markdown-config.el --- Provides and configures markdown-mode for me -*- lexical-binding: t -*-
;;; Commentary:
;;
;; This major mode provides syntax highlighting, among other things, that makes it easier
;; to write markdown files.
;;
;;; Code:

(use-package markdown-mode
  :ensure t
  :defer t
  :custom
  (markdown-fontify-code-block-natively t))

(use-package markdown-ts-mode
  :ensure nil ; built-in
  :defer t
  ;; Emacs 31 & newer ship with markdown-ts-mode built-in.
  :when (not (version< emacs-version "31")))

(provide 'markdown-config)
;;; markdown-config.el ends here
