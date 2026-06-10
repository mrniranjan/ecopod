;; ========================================
;; Basic Settings
;; ========================================
(setq inhibit-startup-message t)
(setq visible-bell t)
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
(setq text-quoting-style 'grave)
(setq package-install-upgrade-built-in t)
(setq package-report-prerequisite-errors nil)
(add-to-list 'load-path "/root/.emacs.d/lisp")

;; ========================================
;; UI Settings - Guarded for batch / terminal mode
;; ========================================
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'tooltip-mode)
  (tooltip-mode -1))
(when (fboundp 'menu-bar-mode)
  (menu-bar-mode -1))
(when (fboundp 'set-fringe-mode)
  (set-fringe-mode 10))

;; ========================================
;; Package Management
;; ========================================
(require 'package)
(setq package-archives '(("melpa" . "http://melpa.org/packages/")
                         ("org" . "http://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'compat)
  (package-install 'compat))
(require 'compat)

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; ========================================
;; Core Packages
;; ========================================
(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill))
  :config (ivy-mode 1))

(use-package ivy-rich
  :init (ivy-rich-mode 1))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         :map minibuffer-local-map
         ("C-r" . counsel-minibuffer-history))
  :config (setq ivy-initial-inputs-alist nil))

(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom (doom-modeline-height 10))

(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-one t)
  (doom-themes-visual-bell-config)
  (doom-themes-neotree-config)
  (setq doom-themes-treemacs-theme "doom-atom")
  (doom-themes-treemacs-config)
  (doom-themes-org-config))

;; Line numbers
(column-number-mode)
(global-display-line-numbers-mode t)

(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config (setq which-key-idle-delay 0.3))

;; ========================================
;; Projectile
;; ========================================
(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :bind-keymap ("C-c p" . projectile-command-map)
  :init
  (setq projectile-project-search-path '("/workspace" "/root/source/"))
  (setq projectile-switch-project-action #'projectile-dired))

;; ========================================
;; Ollama + LLM Integration
;; ========================================
(use-package compat
  :ensure t)

(use-package gptel
  :config
  (setq gptel-backend
        (gptel-make-ollama "Ollama"
          :host "localhost:11434"
          :stream t
          :models '(qwen2.5-coder:7b
                    qwen2.5-coder:3b
                    llama3.2:3b)))
  (setq gptel-model 'qwen2.5-coder:7b
        gptel-default-mode 'org-mode
        gptel-chat-buffer "*Ollama*")

  (global-set-key (kbd "C-c g") #'gptel)
  (global-set-key (kbd "C-c C-g") #'gptel-send))

(use-package ellama
  :ensure t
  :after transient
  :init (setopt ellama-language "English")
  :config
  (setq ellama-host "http://localhost:11434"
        ellama-model "qwen2.5-coder:7b")
  (global-set-key (kbd "C-c e c") #'ellama-chat)
  (global-set-key (kbd "C-c e e") #'ellama-code-edit)
  (global-set-key (kbd "C-c e r") #'ellama-code-review))

;; Ollama Buddy - Fixed loading order
(use-package ollama-buddy
  :ensure t
  :after (compat transient gptel)   ; Important: load after dependencies
  :bind (("C-c o" . ollama-buddy-role-transient-menu)
         ("C-c c" . ollama-buddy-chat)))

;; ========================================
;; Load LSP config last
;; ========================================
(load "~/.emacs.d/lisp/lsp.el" t)  ;; 't' = no error if missing
