;;; search-config.el --- Configure the various kinds of searching Emacs has -*- lexical-binding: t -*-
;;; Commentary:
;;;
;;; Emacs has a variety of search mechanisms built into it, including occur,
;;; grep, isearch, Dired, etc. In addition, many of these search mechanisms
;;; provide a way to edit the resutls in their specialty buffer. For example,
;;; in an *Occur* buffer, users can enter occur-edit-mode to change the content
;;; in the *Occur* buffer and have it REFLECTED back into those buffers!
;;;
;;; Similar tools exist for grep (wgrep), Dired (wdired), etc. This file does
;;; all of that configuration in a single place, here.
;;;
;;; Code:

;; On Emacs 31, grep-mode comes with a grep-edit-mode, so we don't need wgrep at
;; all.

(use-package wgrep
  :ensure t
  :defer nil
  :when (<= emacs-major-version 30)
  :bind (:map grep-mode-map
         ;; e is the same key that occur-mode uses to enter occur-edit-mode
         ("e" . wgrep-change-to-wgrep-mode)
         ("C-x C-q" . wgrep-change-to-wgrep-mode)
         ("C-c C-c" . wgrep-finish-edit))
  :custom
  (wgrep-enable-key "e")
  (wgrep-auto-save-buffer t)
  ;; Do not let wgrep change read-only files.
  (wgrep-change-readonly-file nil))

(use-package grep
  :ensure nil ; Built-in
  :defer nil
  :when (>= emacs-major-version 31)
  ;; Configure grep-mode and grep-edit-mode here, when it releases and I spend
  ;; the time to see all the options.
  )

(provide 'search-config)
;;; search-config.el ends here
