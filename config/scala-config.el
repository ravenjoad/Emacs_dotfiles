;;; scala-config.el --- This file provides changes to allow the writing of Scala -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'magit-config)
(require 'lsp-config)

(use-package scala-mode
  :ensure (scala-mode :inherit elpaca-menu-melpa)
  :defer t
  :interpreter ("scala" . scala-mode))

(use-package sbt-mode
  :ensure t
  :defer t
  :commands sbt-start sbt-command
  :config
  ;; WORKAROUND: https://github.com/ensime/emacs-sbt-mode/issues/31
  ;; allows using SPACE when in the minibuffer
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)
  ;; sbt-supershell kills sbt-mode:  https://github.com/hvesalai/emacs-sbt-mode/issues/152
  (setq sbt:program-options '("-Dsbt.supershell=false")))

(use-package scala-ts-mode
  :ensure (:host github :repo "ravenjoad/scala-ts-mode"
           :branch "main"
           :depth nil)
  :defer t
  :interpreter ("scala" . scala-ts-mode))

(provide 'scala-config)
;;; scala-config.el ends here
