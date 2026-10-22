;;; treesit-config.el --- This file provides configuration for Treesitter -*- lexical-binding: t -*-
;;; Commentary:

;; treesit is Emacs' built-in support for tree-sitter. treesit started to be
;; available in Emacs version >29. Before that, you needed to use the tree-sitter
;; ELisp package, which brough the first support of tree-sitter to Emacs.
;;
;; The tree-sitter & tree-sitter-* ELisp packages are a set of 3rd party packages
;; that brought initial support for the tree-sitter incremental parser
;; and all of its supporting libraries (one for each programming
;; language).
;;
;; tree-sitter (the incremental parser) is intended to provide incredibly fast
;; and accurate AST information WITHOUT needing to send the program through a
;; compiler/LSP.
;; Emacs uses tree-sitter for font-locking (highlighting), indentation, and all
;; the other features it used to use regular expressions for when building a
;; major mode. In theory, tree-sitter will produce both more precise and accurate
;; syntax font-locking and indentation.
;;
;; It will take some time for Emacs to move over to tree-sitter (if it ever fully
;; does), so we must remap major modes that previously relied on regular
;; expression parsing to now use the tree-sitter supported mode.

;;; Code:

(require 'os-detection)

;; Fetch and use the treesit package (which is built INTO Emacs) when Emacs is
;; built with tree-sitter support, which requires Emacs to be >29 AND be
;; configured with:
;; ./configure --with-tree-sitter.
;; We first check the version of Emacs before going on and potentially loading
;; treesit & its changing the major-mode-remap-alist.
(use-package treesit
  :ensure nil ;; built-in
  :when (and (>= emacs-major-version 29)
             (treesit-available-p)
             (getenv "TREE_SITTER_GRAMMAR_PATH"))
  :init
  ;; I use Guix Home to install tree-sitter grammars for programming which, by the
  ;; nature of its functional package-management system, will install these shared
  ;; objects into a particular location within the Guix store, which is then
  ;; exposed with an environment variable.
  ;; When I am on a Guix-based system, assume I am using Guix Home and add the
  ;; store path to Emacs' understanding of the tree-sitter module load path.
  (when (ravenjoad/is-guix-system)
    (setq treesit-extra-load-path
          (append (split-string (getenv "TREE_SITTER_GRAMMAR_PATH") ":")
                  treesit-extra-load-path)))

  (setq major-mode-remap-alist
        '((yaml-mode . yaml-ts-mode)
          (conf-toml-mode . toml-ts-mode)
          ;; TODO: libtree-sitter-markdown-inline.so is not found.
          ;; (markdown-mode . markdown-ts-mode)
          (mermaid-mode . mermaid-ts-mode)
          (bash-mode . bash-ts-mode)
          (c-mode . c-ts-mode)
          (c++-mode . c++-ts-mode)
          (c-or-c++-mode . c-or-c++-ts-mode)
          (go-mode . go-ts-mode)
          (js2-mode . js-ts-mode)
          (typescript-mode . typescript-ts-mode)
          (json-mode . json-ts-mode)
          (css-mode . css-ts-mode)
          (python-mode . python-ts-mode)
          (verilog-mode . verilog-ts-mode)
          (vhdl-mode . vhdl-ts-mode)
          (rust-mode . rust-ts-mode)
          (scala-mode . scala-ts-mode)
          (ada-mode . ada-ts-mode)
          (gpr-mode . gpr-ts-mode))))

;; Bring paredit-like functionality to every programming language!
(use-package tree-edit
  :ensure t
  :defer t)

;; Fix indirect buffers whose parent is a tree-sitter major-mode buffer.
;; Block below taken from James Cherti and modified to be used in a use-package.
;; Author: James Cherti
;; License: GPL
;; URL: https://www.jamescherti.com/restore-emacs-tree-sitter-syntax-highlighting-in-indirect-buffers/
;; URL: https://lists.gnu.org/archive/html/bug-gnu-emacs/2026-08/msg00904.html
(use-package emacs
  :ensure nil ; built-in metapackage
  ;; FIXME: Once Emacs addresses this in core Emacs, put an upper bounds on this
  ;; version check.
  :if (>= emacs-major-version 31)
  :config
  (defun initialize-indirect-buffer-treesit-parsers ()
    "Initialize tree-sitter parsers in indirect buffers based on the base buffer."
    (when (and (fboundp 'treesit-major-mode-setup)
               (fboundp 'treesit-parser-list)
               (fboundp 'treesit-parser-create))
      (let* ((base (buffer-base-buffer))
             ;; If this is an indirect buffer, switch context to the base buffer
             ;; to retrieve its active parsers.
             (parser-list (and base
                               (with-current-buffer base
                                 (treesit-parser-list)))))
        (when parser-list
          ;; Instantiate identical parsers for this indirect buffer.
          (dolist (parser parser-list)
            (treesit-parser-create (treesit-parser-language parser)))

          ;; Activate tree-sitter features (such as font-lock and indentation).
          (treesit-major-mode-setup)

          ;; Force an immediate font-lock refresh
          (when (fboundp 'font-lock-flush)
            (font-lock-flush))))))

  :hook ((clone-indirect-buffer-hook . #'initialize-indirect-buffer-treesit-parsers)))

(provide 'treesit-config)
;;; treesit-config.el ends here
