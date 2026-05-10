;;; personal-settings.el --- Settings for making Emacs mine -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'os-detection)
;; Change the way an Emacs frame is drawn upon startup depending on OS.
(cond
 ;; On Windows GUI, make Emacs a maximized window
 ((equal system-type 'windows-nt)
  (progn
    (add-hook 'emacs-startup-hook 'toggle-frame-maximized)
    (add-to-list 'default-frame-alist '(fullscreen . fullboth))))
 ;; On Guix, I use StumpWM, use a maximized frame to NOT cover Stump's modeline
 ((ravenjoad/is-guix-system)
  (progn
    (add-hook 'emacs-startup-hook 'toggle-frame-maximized)
    (add-to-list 'default-frame-alist '(maximized . fullboth))))
 ;; Otherwise, on GNU/Linux/BSD/OSX, make Emacs fullscreen
 ((equal system-type 'gnu/linux)
  (progn
    (add-hook 'emacs-startup-hook 'toggle-frame-fullscreen)
    (add-to-list 'default-frame-alist '(fullscreen . fullboth)))))

;; Set initial frame's width slighly larger than 80 characters wide.
(add-to-list 'default-frame-alist '(width . 90))

;; Skip the "Welcome" Page
(setq inhibit-startup-message t)

(use-package emacs
  :ensure nil ;; built-in
  :bind (
         ;; This is usually bound by default, but sometimes it does not take
         ;; effect. We manually bind it here, just so we always get keybindings
         ;; that we want.
         ("M-<delete>" . #'backwards-kill-word)
         ;; I want a keybinding to quickly revert buffers, since sometimes Magit
         ;; doesn't do it.
         ("C-c g" . revert-buffer)
         ("C-c w" . whitespace-mode))
  :hook
  ((before-save . delete-trailing-whitespace)
   ;; If you create a file in Emacs that starts with a shebang, Emacs will
   ;; automatically chmod u+x it for you.
   (after-save . executable-make-buffer-file-executable-if-script-p))
  :config
  ;; Allow some keychords to be repeated without their prefix. For example,
  ;; using C-x o to switch multiple windows can be have the "o" repeated
  ;; without C-x to continue switching to other windows.
  (repeat-mode 1)
  ;; Unbind C-z from suspending the current Emacs frame.
  ;; This stops me from accidentally minimizing Emacs when running graphically.
  ;; You can still access this with C-x C-z (which is a default keybinding).
  (keymap-global-unset "C-z")
  ;; Show line numbers everywhere
  (global-display-line-numbers-mode)
  ;; Have line with my cursor highlighted
  (global-hl-line-mode 1)

  ;; Configure where windows holding special kinds of buffers appear.
  ;; Place selection/search/help/information windows below the current one.
  (add-to-list 'display-buffer-alist
               '((or . ((derived-mode . occur-mode)
                        (derived-mode . grep-mode)
                        (derived-mode . Buffer-menu-mode)
                        (derived-mode . log-view-mode)
                        (derived-mode . help-mode)))
                 ;; Display as a normal buffer on the right (if possible).
                 ;; This is not a side-window because I want to be able to use
                 ;; the `split-window' functions on it.
                 (display-buffer-in-direction)
                 (direction . right)
                 (dedicated . t)
                 (body-function . select-window)))

  ;; The `org-capture' key selection, `org-add-log-note', and agenda dispatcher
  (add-to-list 'display-buffer-alist
               '("\\`\\*\\(Org \\(Select\\|Note\\)\\|Agenda Commands\\)\\*\\'"
                 (display-buffer-in-side-window)
                 (dedicated . t)
                 (side . bottom)
                 (slot . 0)
                 (window-parameters . ((mode-line-format . none)))))

  ;; Put the calendar below.
  (add-to-list 'display-buffer-alist
               '((derived-mode . calendar-mode)
                 (display-buffer-reuse-mode-window display-buffer-below-selected)
                 (mode . (calendar-mode bookmark-edit-annotation-mode ert-results-mode))
                 (inhibit-switch-frame . t)
                 (dedicated . t)
                 (window-height . fit-window-to-buffer)))

  ;; The regular expression (re-builder) buffer & window holding it.
  (add-to-list 'display-buffer-alist
               '((derived-mode . reb-mode) ; M-x re-builder
                 (display-buffer-reuse-mode-window display-buffer-below-selected)
                 (inhibit-switch-frame . t)
                 (window-height . 4) ; note this is literal lines, not relative
                 (dedicated . t)
                 (preserve-size . (t . t))))

  :custom
  ;; Make Emacs treat manual and programmatic buffer switches the same. This
  ;; works by making `switch-to-buffer' actually use `pop-to-buffer-same-window'
  ;; which respects `display-buffer-alist'.
  (switch-to-buffer-obey-display-actions t)
  ;; Increase how much is read from processes in a single chunk. The default
  ;; value of 4096 is a bit small; use 4M in this case.
  (read-process-output-max (* 4 1024 1024))
  ;; According to the POSIX, a line is defined as "a sequence of zero or
  ;; more non-newline characters followed by a terminating newline".
  (require-final-newline t)
  ;; Remove duplicates from the kill ring to reduce clutter
  (kill-do-not-save-duplicates t)
  ;; Improve paren highlighting
  (show-paren-highlight-openparen t)
  (show-paren-when-point-in-periphery t)
  (show-paren-when-point-inside-paren t)
  ;; Do not fontify a window when the user is actively inputting data. This
  ;; should reduce input latency in large buffers. This should also help with
  ;; scroll performance.
  (redisplay-skip-fontification-on-input t)
  ;; Do not delay the delete-pair. That just makes things feel slow.
  ;; I almost never use `delete-pair', but let's make it behave like `kill-sexp'.
  (delete-pair-blink-delay 0)
  ;; Turn on column numbers in ALL major modes
  (column-number-mode 1)
  ;; Disable the visual bell
  (visible-bell nil)
  ;; Don't make a ding when failing command
  (ring-bell-function #'ignore)
  ;; If you copy something outside of Emacs, then kill something inside of
  ;; Emacs, the copied contents in clipboard are lost. This setting makes Emacs
  ;; save the clipboard to the kill-ring before doing the actual kill. Now C-y
  ;; and M-y behave the same regardless of what was copy-pasted from where.
  (save-interprogram-paste-before-kill t)

  ;; After invoking Emacs' help system, automatically select the buffer & window
  ;; containing the help information. The default is to leave your cursor alone,
  ;; which is annoying to remember.
  (help-window-select t)

  ;; I choose to remove the backup~ files because I don't want to have to add every one of those files
  ;; to the .gitignore for projects.
  ;; Besides, auto-saving happens frequently enough for it to not really matter.
  ;; Allow the #auto-save# files. They are removed upon buffer save anyways
  (auto-save-default t)
  ;; Do not auto-disable auto-save after deleting large chunks of
  ;; text. The purpose of auto-save is to provide a failsafe, and
  ;; disabling it contradicts this objective.
  (auto-save-include-big-deletions t)
  ;; Do not delete auto-save files when I kill a buffer. Just leave them sitting
  ;; around for later clean-up.
  (kill-buffer-delete-auto-save-files nil)
  ;; Disable backup~ files
  (make-backup-files nil)
  ;; Disable .#lockfile files
  (create-lockfiles nil)

  ;; Never ask whether or not to follow symlinks
  (vc-follow-symlinks t)
  ;; Transparently open compressed files
  (auto-compression-mode t)

  ;; NOTE: Emacs calls refreshing a buffer a revert.
  ;; Unless you have modifications in memory that are not saved to the disk, then you will be fine.
  ;; Auto refresh buffers
  (global-auto-revert-mode t)
  ;; Also refresh dired, but quietly
  ;; Allow buffers not attached to a file to refresh themselves. Important for
  ;; making dired useful
  (global-auto-revert-non-file-buffers t)
  ;; Usually, a message is generated everytime a buffer is reverted and placed in the *Messages* buffer.
  ;; But not now.
  (auto-revert-verbose nil)
  ;; Show keystrokes in progress more quickly than default
  (echo-keystrokes 0.75)
  ;; ALWAYS ask for confirmation before exiting Emacs
  (confirm-kill-emacs 'y-or-n-p))

(use-package emacs
  :ensure nil
  :defer nil
  :when (>= emacs-major-version 30)
  :config
  ;; Highlight the structure of your regexp as you type it in the minibuffer.
  ;; Capture groups, character classes, and other constructs get color-coded.
  (minibuffer-regexp-mode 1))

;; Use special line-highlighting for line-oriented or text-oriented buffers.
(use-package lin
  :ensure t
  :defer nil
  :config
  (lin-global-mode 1)
  :custom
  (lin-face 'lin-mac)
  ;; Line-oriented buffers (mu4e, elfeed), more heavily highlight point's
  ;; current line.
  (lin-mode-hooks '(elfeed-search-mode-hook
                    ibuffer-mode-hook
                    magit-log-mode-hook
                    mu4e-headers-mode-hook)))

;; Pulse the current line when performing certain actions in Emacs.
;; The functions that cause the pulse are in the `pulsar-pulse-functions' list.
(use-package pulsar
  :ensure t
  :demand t
  :config
  (pulsar-global-mode)
  :custom
  (pulsar-face 'pulsar-magenta)
  (pulsar-delay 0.05))

;; Parentheses/Brackets/Braces/Angles modifications
(use-package emacs
  :ensure nil ; Fake built-in package
  :config
  (show-paren-mode) ;; Emphasize MATCHING Parentheses/Brackets/Braces/Angles
  :custom
  ;; Don't let matching parens blink
  (blink-matching-paren nil))
(require 'rainbow-delimiters-config) ;; Pull in rainbow-delimiters config
;(electric-pair-mode 1) ;; Emacs automatically inserts closing pair

;; Enable syntax highlighting for older Emacsen that have it off
(global-font-lock-mode t)

;; Hide the long list of minor modes from the mode-line. The minions
;; package removes all the additional minor-mode names and their
;; information from the mode-line. If I have them all showing, the
;; modeline gets very busy, and very hard to read sometimes. So, I use
;; this package to remove them, leaving only the current major-mode
;; and a ;-) for the rest of the minor modes.
(use-package minions
  :ensure t
  :demand t
  :config
  (minions-mode 1))

;; Add highlighting for TODO/NOTE/FIXME strings in most buffers.
;; By default, it highlights TODO, FIXME, and NOTE.
;; You can also choose what words should be recognized and what color they should
;; be highlighted with my modifying the hl-todo-keyword-faces variable.
(use-package hl-todo
  :ensure (:depth nil)
  :demand t
  :bind (("C-c C-t p" . #'hl-todo-previous)
         ("C-c C-t n" . #'hl-todo-next))
  :config (global-hl-todo-mode))

;; (setq hl-todo-keyword-faces
;;       '(("TODO"   . "#FF0000")
;;         ("FIXME"  . "#FF0000")
;;         ("DEBUG"  . "#A020F0")
;;         ("GOTCHA" . "#FF4500")
;;         ("STUB"   . "#1E90FF")))

(use-package compile
  :ensure nil ;; built-in
  :defer t
  :hook
  ;; Render ANSI color codes in compilation buffers
  ((compilation-filter . ansi-color-compilation-filter))
  :custom
  ;; Have Emacs always follow compilation outputs in the Compile buffers.
  (compilation-scroll-output t)
  ;; Tell subprocesses they can emit color/escape codes
  (compilation-environment '("TERM=xterm-256color")))

;; Try to use UTF-8 for everything
(use-package emacs
  :ensure nil
  :init
  (set-language-environment "UTF-8")
  (set-default-coding-systems 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)
  (set-selection-coding-system 'utf-8)
  (prefer-coding-system 'utf-8) ;; Catch-all
  :custom
  (locale-coding-system 'utf-8)
  ;; Assume L->R text. I don't use any languages that are right-to-left, so this
  ;; will generally make text display faster by skipping the bidirectional
  ;; parenthesis algorithm.
  (bidi-display-reordering 'left-to-right)
  (bidi-paragraph-direction 'left-to-right)
  (bidi-inhibit-bpa t))

;; Sentences DO NOT need 2 spaces to end.
(setq-default sentence-end-double-space nil)

;; Make sure tab-width is 4, not 8
(setq-default tab-width 4)

;;; CONSTANT DEFINITIONS
(defconst do-not-show-time 0
  "Do NOT show current time on the modeline.
Use with 'display-time-mode' function.")
(defconst show-time 1
  "Show current time in the modeline.
Use with 'display-time-mode' function.")

(defconst do-not-show-load nil
  "Do not display a load average on modeline.
Use with `display-time-default-load-average' variable.")
(defconst 1-minute-load 0
  "Put last 1 minute of load average on modeline.
Use with `display-time-default-load-average' variable.")
(defconst 5-minute-load 1
  "Put last 5 minutes of load average on modeline.
Use with `display-time-default-load-average' variable.")
(defconst 15-minute-load 2
  "Put last 15 minutes of load average on modeline.
Use with `display-time-default-load-average' variable.")

(defconst do-not-show-battery 0
  "Do NOT show battery information on the modeline.
Use with the 'display-battery-mode' function.")
(defconst show-battery 1
  "Show battery status in modeline.
Use with the 'display-battery-mode' function.")

(defconst ravenjoad/display-time-mode-line-format "%R %F"
  "Karl's preference on the time and date information to display on the modeline.
Displays the time in HH:MM format (24-hour), then the date in YYYY-MM-DD format.

Use with `display-time-format' variable.")
(defconst ravenjoad/battery-mode-line-format "[%p%%,%mMin]"
  "Karl's preference on the battery information to display on the modeline.
Displays an approximation of the current amount of battery left, as a
percentage, then the number of minutes left until the battery is emptied or
fully charged.

Use with `battery-mode-line-format' variable.")
;;; END OF CONSTANT DEFINITIONS

;; Show time, date, and system process load information in the modeline.
(display-time-mode show-time) ;; Show system time in buffer modeline.
;; (setq display-time-24hr-format t) ;; Show system time in 24-hour clock
;; (setq display-time-day-and-date t) ;; Show time AND date
(setq display-time-format ravenjoad/display-time-mode-line-format) ;; Karl's preferred display-time setup
(setq display-time-default-load-average 5-minute-load)

;; Show battery information in the modeline.
(display-battery-mode show-battery) ;; Show battery status info in buffer modeline.
(setq battery-mode-line-format ravenjoad/battery-mode-line-format) ;; Karl's preferred battery-display setup.

(setq-default tab-width 2) ; Default to indentation size of 2 spaces
(setq-default indent-tabs-mode nil) ; Use spaces instead of tabs

;; Scratch is a package that allows me to create a *scratch* buffer for any
;; major mode that I may be working in right now. By default, it opens a new
;; scratch buffer with the same name as the programming language I am currently
;; working in.
(use-package scratch
  :ensure t
  :bind (("C-c s" . #'scratch)))


;; Set my preferred font style.
(defconst ravenjoad/preferred-font
  (cond
   ((equal system-type 'windows-nt) "Courier New-11") ;; In this case, 11pt Courier New
   ((equal system-type 'gnu/linux) "Iosevka Semibold-10.5")) ;"Fira Code Retina-11"
  "My (Ravenjoad's) preferred font.
This needs to be a string that matches a font available on the system Emacs is
currently running on.")

;; NOTE: Emacs' :height face-attribute is in 1/10pt, so 105 = 10.5 point font
(defconst ravenjoad--default-font-height
  (cond
   ((equal system-type 'windows-nt) 110)
   ((equal system-type 'gnu/linux) 105))
  "The \"height\" of the default face (font) when Emacs starts.")

(add-to-list 'initial-frame-alist `(font . ,ravenjoad/preferred-font))
(add-to-list 'default-frame-alist `(font . ,ravenjoad/preferred-font))


;;; Registers & Bookmarks
;;; Registers are single-character named "boxes" to store any kind of
;;; information in Emacs, including locations of the point (cursor).
;;; Bookmarks are similar, but use full names instead.
;;; In addition, bookmarks are persistent across sessions, whereas
;;; registers MAY not be.

;; Immediately pop up the register preview when using register commands.
(setq-default register-preview-delay 0)

;; Make Emacs repeat the C-u C-SPC command (`set-mark-command') by
;; following it up with another C-SPC.  It is faster to type
;; C-u C-SPC, C-SPC, C-SPC, than C-u C-SPC, C-u C-SPC, C-u C-SPC...
(setq-default set-mark-command-repeat-pop t)

;; I want Emacs to write the list of bookmarks to the `bookmark-file'
;; as soon as I set a new bookmark.  The default behaviour of Emacs is
;; to write to the disk as a final step before closing Emacs.  Though
;; this can lead to data loss, such as in the case of a power failure.
;; Storing the data outright mitigates this problem.
(setq bookmark-save-flag 1)

;; If you are using the wonderful `consult' package, set up the
;; register preview facility with its more informative presentation:
(use-package consult
  :ensure t
  :defer t
  :custom
  (register-preview-function #'consult-register-format))


;;; Searching
(use-package ispell
  :ensure nil ; Use built-in
  :custom
  (isearch-lazy-count t)
  (isearch-count-prefix-format "(%s/%s) ")
  (isearch-count-prefix-format nil))


;;; Window navigation
;;; Windows contain buffers, and are the things you switch between.
;;; For example, C-x o runs the command (other-window) by default.
;;; Add keybindings for moving between windows in certain directions.
;;; These were originally set to S-direction.
(use-package emacs
  :ensure nil
  :bind (
         ("C-c C-b" . windmove-left)
         ("C-c C-n" . windmove-down)
         ("C-c C-p" . windmove-up)
         ("C-c C-f" . windmove-right)))


;;;
;;; EditorConfig provides a way for projects to define coding styles for all
;;; editors in a uniform way that is easily checked into version control
;;; systems. Think of this like a cross-editor/IDE version of .dir-locals.el.
;;;

(use-package editorconfig
  :ensure t ; Editorconfig is built into Emacs >= 30.1, but we pull from Git
  :defer t
  :config
  (editorconfig-mode 1))

(provide 'personal-settings)
;;; personal-settings.el ends here
