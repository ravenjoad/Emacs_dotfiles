;;; email-config.el --- This file configured mu4e for my email -*- lexical-binding: t -*-
;;; Commentary:
;;
;; Since I tend to use GMail for many things, I have to perform multiple steps
;; to use Emacs to receive, read, compose, and send emails.
;;
;; First, we need an IMAP mail fetching program.
;; For OpenSUSE Tumbleweed, I build my own isync package.
;;   This program contains mbsync as its main binary; project name is isync.
;;   The configuration file for this program is `~/.mbsyncrc'
;;   You need libopenssl-devel and cyrus-sasl-devel packages from OpenSUSE.
;;
;; Next, we need a way to index our mail so we can search through it.
;; mu4e requires another program be installed that interfaces with IMAP
;; to download the emails, since mu ONLY indexes and queries the downloaded
;; emails.
;;
;; To start using `mu' (maildir-utils), you must first download the mail using
;; isync/`mbsync'.
;; Then, you must perform an `mu init --maildir=<path-to-maildir> \
;;                            --my-address="example@domain.com" \
;;                            [--my-address="example2@domain2.com"]`
;; You only need to initialize the mu database once, but you can feed it several
;; personal addresses when initializing.
;; Once done, you must index the database with `mu index'
;;
;; Lastly, we need a way to send the email through SMTP.
;; I will use msmtp to send my mail.
;; It requires there be an `~/.msmtprc' config file.
;; Special permissions are required, namely 600.
;;
;;; Code:

(require 'personal-functions)
(defvar mu4e-load-path
  (cond
   ((ravenjoad/is-nixos)
    "/run/current-system/sw/share/emacs/site-lisp/mu4e")
   ((ravenjoad/is-guix-system)
    (concat (getenv "HOME") "/.guix-home/profile/share/emacs"))
   (t
    "/usr/share/emacs/site-lisp/mu4e"))
  "System-specific path to find mu's Emacs Lisp package which provide mu4e.")

(use-package mu4e
  :ensure nil ; Provided by mu package
  :defer t
  ;; We can only load mu4e if mu was installed
  :when (and (executable-find "mu")
             (locate-library "mu4e")
             (executable-find "msmtp"))
  :load-path mu4e-load-path
  ;; Give myself a nice easy keybinding to open mu4e
  :bind (("C-c m" . mu4e)
         :map mu4e-view-mode-map
         ("C-c C-o" . mu4e--view-browse-url-from-binding)
         :map mu4e-main-mode-map
         ;; ("m" . 'ravenjoad/set-sendmail-program)
         ("S" . 'ravenjoad/send-queued-mail)
         ("f" . 'ravenjoad/send-queued-mail)
         :map mu4e-compose-mode-map
         ("M-$" . ispell-message))
  :hook ((mu4e-compose-mode . ravenjoad/encrypt-responses)
         ;; When writing an email, a file is created in `mu4e-drafts-folder',
         ;; which keeps copies of the message as I write it. However, using the
         ;; email stack I have now, by default, causes my drafts to be synced up
         ;; to Gmail, but never get removed when I send the actual email. So,
         ;; disable `auto-save-mode' in `mu4e-compose-mode' preventing drafts
         ;; from being saved when I don't want them to be.
         ;; NOTE, this does NOT stop me from saving drafts. It just prevents
         ;; auto-saving of drafts.
         (mu4e-compose-mode . (lambda () (auto-save-mode -1)))
         ;; Enable org-mode style tables in messages
         (message-mode . turn-on-orgtbl))
  :custom
  ;; mu4e starts quickly, so closing it isn't that bad.
  (mu4e-confirm-quit nil)
  (mu4e-get-mail-command "mbsync -a")
  ;; Send all mail immediately. We set this to msmtp by default so we always TRY
  ;; to send something. We can change this later on.
  ;; (sendmail-program "msmtp")
  ;; We don't let smtpmail queue mail, because we rely on mu4e & msmtp to queue
  ;; our mail the msmtp expects.
  (smtpmail-queue-mail nil)
  ;; Where should our SMTP-based sendmail program place queued emails?
  (smtpmail-queue-dir ravenjoad/queue-mail-command)
  ;; Moving messages (especially between directories) renames files to avoid
  ;; errors
  (mu4e-change-filenames-when-moving t)
  ;; Always ask me which mu4e context an email should be composed from.
  (mu4e-compose-context-policy 'always-ask)
  ;; Emacs' C-x m is bound to `compose-mail', which choses a mail composition
  ;; package based on mail-user-agent. By setting this, Emacs keeps its default
  ;; keybinding, but I get the mu4e behavior I want.
  (mail-user-agent 'mu4e-user-agent)
  ;; Once I finish the email and have sent it, kill the message buffer, rather
  ;; than burying it in the buffer-list.
  (message-kill-buffer-on-exit 't)
  ;; Start attachment finding & saving from /tmp. We can navigate elsewhere when
  ;; we choose what to attach.
  (mu4e-attachment-dir "/tmp/")
  ;; When sending mail, delete the message file from "outgoing". If using Gmail,
  ;; messages are automatically moved to the Sent folder by Google. So, we don't
  ;; need to do anything on our end to preserve the fact we sent the message.
  (mu4e-sent-messages-behavior 'delete)
  ;; Don't show the context of a thread in the Inbox, once it has been deleted.
  (mu4e-headers-include-related nil)
  ;; Show the email address of the person I am emailing, along with their name.
  (mu4e-view-show-addresses t)
  (mu4e-view-show-images t)
  ;; Use a sendmail program rather than sending directly from Emacs
  (message-send-mail-function 'message-send-mail-with-sendmail)
  ;; Make msmtp infer the correct account to send from by the From: email address
  (message-sendmail-extra-arguments '("--read-envelope-from"))
  ;; Don't add "-f username" to the msmtp command.
  (message-sendmail-f-is-evil 't)
  ;; Don't let me easily reply to myself
  (mu4e-compose-dont-reply-to-self t)
  (mu4e-compose-keep-self-cc nil)
  ;; Make mu4e use Emacs' built-in completion system rather than mu4e's custom
  ;; one. This means that the rest of my completion configuration kicks in for
  ;; mu4e too.
  (mu4e-read-option-use-builtin 'nil)
  (mu4e-completing-read-function #'completing-read)

  :config
  ;; Set the contexts for the accounts I use.
  (setq mu4e-contexts
        `(,(make-mu4e-context
            :name "personal"
            :match-func (lambda (msg)
                          (when msg
                            (string-prefix-p "/Personal" (mu4e-message-field msg :maildir))))
            :vars '((user-full-name . "Karl Hallsby") ;; My full name is set in personal-info
                    (user-mail-address . "karl@hallsby.com")
                    ;; Although personal email address set in personal-info, need
                    ;; to reset it when I change contexts in mu4e
                    (mu4e-trash-folder . "/Personal/Trash")
                    (mu4e-refile-folder . "/Personal/Refile")
                    (mu4e-sent-folder . "/Personal/Sent")
                    (mu4e-drafts-folder . "/Personal/Drafts")
                    (mu4e-compose-signature . "Karl Hallsby
PhD Computer Engineering 2027
Northwestern University
https://raven.hallsby.com

Contact:
karl@hallsby.com
+1-630-815-7827")))
          ,(make-mu4e-context
            :name "nu"
            :match-func (lambda (msg)
                          (when msg
                            (string-prefix-p "/Northwestern" (mu4e-message-field msg :maildir))))
            :vars '((user-full-name . "Karl Hallsby") ;; My full name is set in personal-info
                    (user-mail-address . "karlhallsby2027@u.northwestern.edu")
                    ;; Although personal email address set in personal-info, need to reset it
                    ;; when I change contexts in mu4e
                    (mu4e-trash-folder . "/Northwestern/Trash")
                    (mu4e-refile-folder . "/Northwestern/Refile")
                    (mu4e-sent-folder . "/Northwestern/Sent")
                    (mu4e-drafts-folder . "/Northwestern/Drafts")
                    (mu4e-compose-signature . "Karl Hallsby
PhD Computer Engineering 2027
Northwestern University
Mudd Library, Room 3301
https://raven.hallsby.com

Contact:
kgh@u.northwestern.edu")))))

  ;; Install frequent queries as "bookmarks", bound to a key in mu4e's main
  ;; dispatch page.
  (add-to-list
   'mu4e-bookmarks
   '( :name "All Inboxes"
      :key ?a
      :query "maildir:/Personal/Inbox OR maildir:/IIT/Inbox OR maildir:/Northwestern/Inbox OR maildir:/ServerAdmin/Inbox"))
  (add-to-list
   'mu4e-bookmarks
   '( :name "All Mail"
      :key ?A
      ;; This query works because the * is expanded by the shell before being passed to the mu binary.
      :query "maildir:/Personal/* OR maildir:/IIT/* OR maildir:/Northwestern OR/* maildir:/ServerAdmin/*")))

;; HTML email is rife in the world. It is used by Gmail, for instance.
;; There are accessibility reasons why not to use it, but I still want to be able
;;  to read emails sent through Gmail. So, we configure that here.
(use-package mu4e-contrib
  :ensure nil ; Provided by mu package
  :load-path mu4e-load-path
  :after mu4e
  :config
  (advice-add #'shr-colorize-region
              :around (defun shr-no-colourise-region (&rest ignore)))
  ;; However, there are some HTML emails that are just too hard for Emacs to display.
  ;; So, open the HTML up in my browser.
  ;; By default, this is bound to "a h" in the mu4e mode.
  (add-to-list 'mu4e-view-actions
               '("HTML in Browser" . mu4e-action-view-in-browser)
               ;; Append the action, to list, rather than overwrite.
               ;; The add-to-list function actually appends to the FRONT of the list!
               t)
  :custom
  (mu4e-html2text-command 'mu4e-shr2text)
  (shr-color-visible-luminance-min 60)
  (shr-color-visible-distance-min 5)
  (shr-use-fonts nil)
  (shr-use-colors nil))

;; =============================================================================
;; Allow mu4e to use some capabilities of org-mode
;; =============================================================================

;; Enable org-mode like list manipulation
;; This may also include the section headers that org-mode uses
;; (add-hook 'message-mode-hook 'turn-on-orgstruct++)
;; FIXME: Symbol disappeared. Causes face attribute issues.

;; =============================================================================
;; Mail sending setup
;; =============================================================================
;; Since I use Gmail, I have to use SMTP to send my emails.
;; This means I need to use a non-default mail sender, namely the program msmtp.

(use-package emacs
  :ensure nil ; built-in
  :defer nil
  :init
  (defvar ravenjoad/queue-mail-command
    (or (executable-find "msmtp-enqueue.sh")
        "~/.nix-profile/share/doc/msmtp/scripts/msmtpqueue/msmtp-enqueue.sh")
    "Command that will queue the mail for sending by placing it in a directory for later sending.")

  (defvar ravenjoad/send-queued-mail-command
    (or (executable-find "msmtp-runqueue.sh")
        "~/.nix-profile/share/doc/msmtp/scripts/msmtpqueue/msmtp-runqueue.sh")
    "Command that will send ALL queued mail.")

  (defvar ravenjoad/queued-mail-dir
    (or (getenv "QUEUEDIR")
        (getenv "QUEUE_DIR")
        (getenv "MSMTP_QUEUE")
        (getenv "MSMTPQUEUE")
        "~/.msmtpqueue/")
    "Location where the mail queued to be sent will be stored until that time.")

  :config
  ;; Or, we can queue them, and then have an mu4e keybinding to send them when we
  ;; get the chance.
  ;; Switched by my4e~main-toggle-mail-sending-mode function
  (setq smtpmail-queue-mail nil)
  (setq smtpmail-queue-dir ravenjoad/queued-mail-dir)
  ;; We need to make sure the queuing directory exists, before Emacs lets the user
  ;; attempt to use the directory.
  (when (not (file-directory-p smtpmail-queue-dir))
    (make-directory smtpmail-queue-dir t))

  :custom
  ;; This will send ALL mail IMMEDIATELY, and will fail if you do not have an
  ;; Internet connection.
  ;; We set this by default here, so we can always try to send something
  (sendmail-program "msmtp"))

;; Overwrite the mu4e~main-toggle-mail-sending-mode keybinding with my own function
(defun ravenjoad/set-sendmail-program ()
  "Set the smtpmail variable sendmail-program based on the value of smtpmail-queue-mail's value."
  (interactive)
  (mu4e--main-toggle-mail-sending-mode)
  (if smtpmail-queue-mail ;; Is true, meaning we queue it
      (setq sendmail-program ravenjoad/queue-mail-command)
  (setq sendmail-program "msmtp")))

(defun ravenjoad/send-queued-mail ()
  "Sends all mail currently stored in `smtpmail-queue-dir'. Put output in *msmtp-runqueue Output* buffer."
  (interactive)
  ;; Now run the msmtp-runqueue.sh command, and put the output in a temporary buffer.
  (with-temp-buffer (async-shell-command ravenjoad/send-queued-mail-command)))

;; Commented until I figure out how to make this work.
;; I want to print an additional command-context line in the main mu4e buffer.
;; (add-hook 'mu4e-main-mode
;; 	  (let ((buf (get-buffer mu4e-main-buffer-name)))
;; 	    (with-current-buffer buf
;; 	      (setq inhibit-read-only t)
;; 	      (insert
;; 	       (mu4e~main-action-str "\t[f]lush all queued mail and [S]end" 'ravenjoad/send-queued-mail))
;; 	      (setq inhibit-read-only nil))))


;; =============================================================================
;; My personal functions
;; =============================================================================

;; Shamelessly stolen from Howard R. Schwarz's configuration.org file.
(defun ravenjoad/encrypt-responses ()
  "Encrypt the current message if it's a reply to another encrypted message."
  (let ((msg mu4e-compose-parent-message))
    (when (and msg (member 'encrypted (mu4e-message-field msg :flags)))
        (mml-secure-message-encrypt-pgpmime))))


(provide 'email-config)
;;; email-config.el ends here
