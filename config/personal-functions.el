;;; personal-functions.el --- This file provides my exported personal functions -*- lexical-binding: t -*-
;;; Commentary:
;;
;; I have a file for personal information and personal settings, so it makes
;; sense to have another file whose only job is to define my personal functions.
;; These are functions that will be prefaced with ravenjoad/function-name.
;; These will typically only be callable through the M-x ravenjoad/function-name
;; route, simplifying my life a little bit.
;;
;;; Code:

(defvar ravenjoad--in-presentation-mode-p 'nil
  "Is Emacs currently in \"presentation mode\"?")

;; Modified from Adrien Brochard's configuration.org
(defun ravenjoad/toggle-presentation ()
  "If NEW-FONT-HEIGHT provided, toggle presentation features, like font increase."
  (interactive)
  (require 'personal-settings)
  (let ((presentation-fontsize 200))
    (if ravenjoad--in-presentation-mode-p
        (set-face-attribute 'default nil :height ravenjoad--default-font-height)
      (set-face-attribute 'default nil :height presentation-fontsize))
    (setq ravenjoad--in-presentation-mode-p (not ravenjoad--in-presentation-mode-p))))

(defun ravenjoad/etags-generate (dir-name)
  "Generate an etags TAGS file for C in the specified DIR-NAME.

Note that this uses `xargs' and `find', both of which are provided by GNU
findutils."
  (interactive "DDirectory: ")
  (eshell-command
      (format "find %s -type f -name \"*.[chS]\" | xargs etags -a" dir-name)))

(defun ravenjoad/reload-dir-locals-current-buffer ()
  "Reload `.dir-locals.el' for the current buffer.

This function is from https://emacs.stackexchange.com/a/13096"
  (interactive)
  (let ((enable-local-variables :all))
    (hack-dir-local-variables-non-file-buffer)))

(defun dos2unix (buffer)
  "Convert BUFFER from DOS line-endings to UNIX line-endings.
This function simply replaces all instances of \r ( in Emacs character type)
with the empty character."
  (interactive "*b") ;; Name of existing buffer that is RW
  (save-excursion
    (goto-char (point-min))
    (while (search-forward (string ?\C-m) nil t)
      (replace-match (string ?\C-j) nil t))
    (set-buffer-file-coding-system 'unix 't)))

(defun ravenjoad/remove-file-whitespace ()
  "Remove trailing whitespace from files.

Opens and removes all trailing whitespace from the list of files selected in a
Dired buffer. Trailing whitespace includes empty newlines at the end of the
file."
  (interactive)
  (require 'dired)
  (mapc (lambda (file-name)
          (with-temp-file file-name
            (insert-file-contents-literally file-name)
            (delete-trailing-whitespace (point-min) nil)))
        (dired-get-marked-files nil)))

(defun ravenjoad/revert-selected-buffers ()
  "Revert all buffers currently selected by ibuffer.

This will revert all the marked buffers, but will NOT open them for viewing,
and will leave you in the *Ibuffer* buffer.

WARNING: This does NOT ask for confirmation before reverting any buffer, even
if it is modified!"
  (interactive)
  (require 'ibuffer)
  (save-window-excursion
    (mapc (lambda (buffer-name)
            (switch-to-buffer buffer-name)
            (revert-buffer-quick))
          (ibuffer-get-marked-buffers))))

(defun ravenjoad/gc-events ()
  "Print message about GC statistics."
  (interactive)
  (message "%d GC Events\n%0.2f Seconds spent GC-ing" gcs-done gc-elapsed))

(defun ravenjoad/remove-ansi-escape-sequences (&optional start end backward
                                                        region-noncontiguous-p)
  "Remove ANSI terminal color and formatting escape sequences from START to END.

The color and formatting escape sequences are completely removed (replaced with
empty strings), so the formatting is completely lost!

BACKWARD and REGION-NONCONTIGUOUS-P are passed to `replace-regexp' exactly.

Removes ANSI terminal escape sequences from region. If no region is provided,
then remove escape sequences from the entire buffer."
  (interactive "*r")
  (require 'replace)
  (if (use-region-p)
      (replace-regexp "\\\\033\\[[0-9;]*[mK]" ""
                      nil ; DELIMITED
                      (region-beginning) (region-end)
                      backward region-noncontiguous-p)
    (replace-regexp "\\\\033\\[[0-9;]*[mK]" ""
                    nil ; DELIMITED
                    (point-min) (point-max) backward region-noncontiguous-p)))


;; TODO: Allow universal argument (C-u) to customize the format and allow the
;; desired location to be set (location other than point).
(defun ravenjoad/insert-today-date ()
  "Insert todays date in ISO (YYYY-MM-DD) format at point."
  (interactive)
  (require 'calendar)
  ;; Use a let-binding here so that the user's locale-based preference is not
  ;; overridden by inserting today's date in ISO format by this function.
  (let ((calendar-date-display-form calendar-iso-date-display-form))
    (insert (calendar-date-string (calendar-current-date) nil 't))))

(provide 'personal-functions)
;;; personal-functions.el ends here
