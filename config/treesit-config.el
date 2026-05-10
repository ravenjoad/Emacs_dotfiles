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
          ;; TODO: Add mermaid-tree-sitter to Guix and add to my home env!
          ;; (mermaid-mode . mermaid-ts-mode)
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

(provide 'treesit-config)
;;; treesit-config.el ends here
