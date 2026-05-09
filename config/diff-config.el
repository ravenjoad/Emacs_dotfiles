;;; diff-config.el --- Configure diff -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package diff
  :ensure nil ; Built-in
  :defer nil
  :custom
  ;; Don't syntax highlight the content being diffed inside the diff. The colors
  ;; used by the major-mode in the diff likely will not work with the red/green
  ;; of the diff.
  (diff-font-lock-syntax nil))

(provide 'diff-config)
;;; diff-config.el ends here
