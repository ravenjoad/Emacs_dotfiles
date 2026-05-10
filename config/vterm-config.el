;;; vterm-config.el --- Configuration for vterm-mode -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'personal-functions)

(use-package vterm
  :ensure nil ;; built-in
  :defer t
  :when (ravenjoad/is-guix-system))

(provide 'vterm-config)
;;; vterm-config.el ends here
