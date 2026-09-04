;;; magit-config.el --- Provides and configures Magit -*- lexical-binding: t -*-
;;; Commentary:
;;
;; Magit is a Git procelain that gives us a nice way to work with Git
;;
;;; Code:

(require 'pcase)

;; We need to :ensure t transient because transient and magit are often
;; developed side-by-side, which means that if we want the newest magit, we ALSO
;; need the newest transient.
(use-package transient
  :ensure t
  :defer nil)

(use-package magit
  :ensure t
  :defer t
  :requires compat
  :bind
  (;; Open Magit Status (git status) for git handling
   ("C-x g" . #'magit-status)
   ;; Bring up a small menu to choose to do magit things
   ("C-x M-g" . #'magit-dispatch)
   ;; With `git blame`, we can find out the commits that changed certain lines and/or regions
   ("C-c b" . #'magit-blame))
  :config
  ;; Add section to list all worktrees in the magit-status buffer for a given
  ;; repository. Every worktree will list every other work tree.
  (magit-add-section-hook 'magit-status-sections-hook
                          #'magit-insert-worktrees
                          nil t)
  :custom
  (magit-no-confirm '(stage-all-changes unstage-all-changes))
  (magit-clone-default-directory "~/Repos/")
  (magit-auto-revert-mode t)
  (magit-tramp-pipe-stty-settings 'pty)
  :config
  ;; Have every magit-status buffer show all worktrees for that repo.
  (magit-add-section-hook 'magit-status-sections-hook
                          #'magit-insert-worktrees
                          nil t))

;; Display TODO/FIXME/other tagged items in the repository in the magit-status
;; buffer.
(use-package magit-todos
  :ensure t
  :demand t ; Use :demand, because we still autoload magit
  :after magit
  :custom
  (magit-todos-keywords-list
   (mapcar (pcase-lambda (`(,keyword . ,rgb-face))
             keyword)
           hl-todo-keyword-faces))
  (magit-todos-auto-group-items 50)
  (magit-todos-exclude-globs '(".git/"))
  :config
  (magit-todos-mode))

(use-package forge
  :ensure t
  :after magit)

;; Add major-modes for .gitconfig, .gitattributes, and .gitignore, along with
;; their other named variants.
(use-package git-modes
  :ensure t
  :defer t)

(provide 'magit-config)
;;; magit-config.el ends here
