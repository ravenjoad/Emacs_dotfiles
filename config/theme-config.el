;;; theme-config.el --- This file provides my theming options and configuration -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package modus-themes
  :ensure t
  :bind ("C-c T" . modus-themes-toggle)
  :hook ((after-init . (lambda () (load-theme 'modus-vivendi t)))
         (elpaca-after-init . (lambda () (load-theme 'modus-vivendi t))))
  ;; NOTE: Because elpaca does all its work async, the initial frame would be
  ;; put onto the monitor before the theme loaded. So we use the
  ;; elpaca-after-init-hook to load the theme once all the async work is done.
  ;; We could also have gotten away with an (elpaca-wait) call.

  :custom
  (modus-vivendi-theme-section-headings t)
  (modus-vivendi-theme-slanted-constructs t)
  (modus-vivendi-theme-bold-constructs t)
  (modus-vivendi-theme-proportional-fonts nil)
  (modus-operandi-theme-slanted-constructs t)
  (modus-operandi-theme-bold-constructs t)
  (modus-operandi-theme-proportional-fonts nil))

(provide 'theme-config)
;;; theme-config.el ends here
