;;; org-mode-config.el --- Provides and configures org-mode -*- lexical-binding: t -*-
;;; Commentary:
;;
;; This file provides my changes to keybindings and commands while in the major mode Org-mode
;;
;;; Code:

(use-package org
  :ensure nil ;; built-in
  :defer t
  :bind (;; These keybindings are set without needing an org file, because they should always be available.
         ("C-c a" . 'org-agenda) ;; "C-c a" opens the Agenda Buffer to choose where to go
         ("C-c l" . 'org-store-link) ;; "C-c l" stores a hyperlink to the cursor's current position in the current Org-mode document
         ("C-c c" . 'org-capture) ;; "C-c c" will let me select a template and file the new information
         )
  :config
  ;; Enable line-wrapping in org-mode.
  (visual-line-mode 1)

  ;; Advise org-agenda-goto-today to behave how I prefer
  ;; NOTE: The syntax is:
  ;; (define-advice fn-to-advise (WHERE (args ...) advice-name)
  ;;   "Documentation String"
  ;;   body body1 ...)
  (define-advice org-agenda-goto-today (:before () org-agenda-refresh-before-goto-today)
    "Refresh all Org files that build the agenda before jumping to today."
    (message "Refreshing all Org-agenda files")
    (org-agenda-redo-all))
  (define-advice org-agenda-goto-today (:after () org-recenter-today-frame-top)
    "Recenter today to the top of the buffer/frame in org-mode's agenda."
    (recenter-top-bottom 'top))
  :custom
  ;; Use major-mode specific syntax highliting in source blocks while editing
  (org-src-fontify-natively t)
  ;; DO NOT put 2 leader spaces in source code.
  ;; Prevents issues with white-space sensitive languages
  (org-src-preserve-indentation t)
  ;; Make TAB act as if it were issued natively in that language's major mode
  (org-src-tab-acts-natively t)
  ;; When C-c ' a code block, use same window as org file
  (org-src-window-setup 'current-window)
  ;; Don't ask before evaluating code blocks
  (org-confirm-babel-evaluate nil)
  ;; Ensures that when tasks marked done, they also take the time that happened
  (org-log-done-with-time t)
  ;; Ensure subtasks in list are marked DONE before allowing parent to be DONE
  (org-enforce-todo-dependencies t)
  ;; Ensure checkboxes in list are marked DONE before allowing parent to be DONE
  (org-enforce-todo-checkbox-dependencies t)
  ;; Add ALL .org files in Agenda to the Agenda's file list
  (org-agenda-files '("~/Agenda/"))
  ;; Include American holidays on the Org-Agenda
  (org-agenda-include-diary t)
  ;; In the calendar to select days, highlight the ones that are American holidays.
  (calendar-mark-holidays-flag t))

;; This package minimizes bullets that are used in Org-mode
(use-package org-bullets
  :ensure t
  :hook ((org-mode . org-bullets-mode)))

;; Make sure we update Emacs' built-in emacsql
(use-package emacsql
  :ensure t
  :defer t)

(use-package org-roam
  :ensure t
  :defer t
  :after cl-lib
  :custom (org-roam-directory (file-truename "~/OrgRoamNotes/"))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n t" . org-roam-node-tag-read)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ;; Dailies
         ("C-c n j" . org-roam-dailies-capture-today)
         :map org-mode-map
         ("M-," . org-mark-ring-goto))
  :config
  (defun org-roam-tags-list ()
    "Return all tags (#+FILETAGs) stored in the database."
    (let ((rows (org-roam-db-query "SELECT DISTINCT tag FROM tags;")))
      (flatten-list rows)))

  (defun org-roam-node-tag-read (&optional initial-input filter-fn sort-fn
                                           require-match prompt)
    "Return a list of `org-roam-node' that have a matching #+FILETAG entry.

If provided, the PROMPT string is used as a custom prompt in the minibuffer."
    (interactive current-prefix-arg)
    (let* ((prompt (or prompt "File Tag: "))
           (tag (completing-read prompt (org-roam-tags-list)))
           ;; NOTE: We construct an alist because we want the user's title
           ;; selection to be used as a key to get the node's UUID.
           (nodes (mapcar (pcase-lambda (`(,title ,uuid))
                            `(,title . ,uuid))
                          (org-roam-db-query
                           [:select [title id]
                            :from [:select [id file title properties]
                                   :from nodes] :as nodes
                            :join tags
                            :on (= nodes:id tags:node_id)
                            :where (= tags:tag $s1)]
                           tag)))
           (selected-node (completing-read "Node: " nodes))
           (selected-node-id (alist-get selected-node nodes 'nil 'nil #'string=)))
      (org-roam-node-open
       (org-roam-node-from-id selected-node-id))))

  (org-roam-db-autosync-mode)
  (org-roam-setup)
  (setq-local completion-ignore-case t)

  :custom
  (org-roam-v2-ack t))

;; Add way to scrape from websites into Org-mode files.
(use-package org-web-tools
  :ensure t)

(provide 'org-mode-config)
;;; org-mode-config.el ends here
