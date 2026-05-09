;;; dired-config.el --- Configure dired -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; C-x C-j is bound to the (dired-jump) command by default. Put on the more
;; obvious C-x d.
;; We leave the more powerful, but verbose, (dired) command on C-x D
;; It is safe to use keymap-global-set here because these dired commands are set
;; in the global-map.
(use-package dired
  :ensure nil ; built-in
  :commands (dired dired-jump)
  :bind (("C-x d" . dired-jump)
         ("C-x D" . dired))
  :init
  (keymap-global-unset "C-x C-j")
  :custom
  ;; Only use a single dired buffer, having new ones "replace" this one.
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-auto-revert-buffer #'dired-directory-changed-p)
  (dired-clean-up-buffers-too t)
  (dired-clean-confirm-killing-deleted-buffers t)
  (dired-recursive-copies #'always)
  (dired-recursive-deletes #'always)
  (delete-by-moving-to-trash t)
  (dired-create-destination-dirs 'ask)
  (wdired-create-parent-directories t)
  (dired-dwim-target t))

(use-package dired
  :ensure nil ; built-in
  :when (>= emacs-major-version 29)
  :custom
  (dired-create-destination-dirs-on-trailing-dirsep t))

;; Enable dired-x so that we get the "extra goodies" we want to use in dired.
;; For example, `dired-do-find-marked-files', which does `find-file' on every
;; marked file comes from this library.
(use-package dired-x
  :ensure nil ; built-in
  :hook ((dired-mode . dired-omit-mode))
  :config
  ;; Don't show .git in dired.
  (setq-default dired-omit-files
                (concat dired-omit-files "\\|^\\.git$"))
  :custom
  ;; Don't let dired-x override the default keybindings for existing Emacs
  ;; functions/commands.
  (dired-x-hands-off-my-keys 't))

(provide 'dired-config)
;;; dired-config.el ends here
