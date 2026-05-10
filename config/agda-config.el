;;; agda-config.el --- Configure Agda -*- lexical-binding: t -*-
;;; Commentary:
;;; Agda is dependently-typed programming language that provides their Emacs
;;; major-mode through their own toolchain. So you cannot grab the major-mode
;;; off melpa and be on your way. You must install all the tools.
;;;
;;; Code:

(require 'personal-functions)

(use-package agda2-mode
  :ensure nil ; Must be provided by system or other tool
  :when (ravenjoad/is-guix-system))

(provide 'agda-config)
;;; agda-config.el ends here
