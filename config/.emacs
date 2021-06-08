(eval-when-compile (require 'use-package))

(custom-set-variables
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(blink-cursor-mode nil)
 '(initial-buffer-choice "~"))
(custom-set-faces)

;; disable alarm
(setq visible-bell 1)

;; disable backup
(setq make-backup-files nil) ; stop creating backup~ files
(setq auto-save-default nil) ; stop creating #autosave# files

;; Убрать все кнопки в GUI
(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)

;; Тема и шрифты
(use-package dracula-theme
  :config
  (load-theme 'dracula t))
(set-face-attribute 'default nil
		    :family "Fira Code"
		    :height 100
		    :weight 'normal
		    :width 'normal)

;; Нумерация строк
(use-package linum
  :config
  (setq linum-format " %d")
  (line-number-mode t)
  (global-linum-mode t)
  (column-number-mode t))

;; Отключение главного экрана
(setq inhibit-startup-message nil)

;; Автодополнение
(use-package company
  :ensure t
  :defer t
  :init (global-company-mode)
  :config
  (setq company-idle-delay 0.5)
  (setq company-dabbrev-domowncase nil)
  (setq company-minimum-prefix-length 1)
  (setq company-tooltip-limit 20)
  (setq company-tooltip-minimum-width 15)
  (add-to-list 'company-backends 'company-nixos-options)
  :bind ("C-<tab>" . company-complete)
  :diminish company-mode)

;; Не показывать предупреждение при нажатии A в dired
(put 'dired-find-alternate-file 'disabled nil)
(use-package dired-subtree
  :bind (:map dired-mode-map
	      ("i" . dired-subtree-insert)
	      ("I" . dired-subtree-remove)))

;; Радужные штуки с скобочками
(use-package rainbow-delimeters
  :hook (prog-mode-hook . rainbow-delimiters-mode)
  )
(show-paren-mode 1)
(electric-pair-mode 1)

;; Ivy штуки
(use-package ivy
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  :bind (("\C-s" . swiper)
	 ("C-c C-r" . 'ivy-resume)
	 ("C-c t" . counsel-tramp)
	 ("<f6>" . ivy-resume)
	 ("M-x" . counsel-M-x)
	 ("C-x C-f" . counsel-find-file)
	 ("<f1> f" . counsel-describe-function)
	 ("<f1> v" . counsel-describe-variable)
	 ("<f1> l" . counsel-find-library)
	 ("<f2> i" . counsel-info-lookup-symbol)
	 ("<f2> u" . counsel-unicode-char)
	 ("C-c k" . counsel-ag)
	 ("C-x l" . counsel-locate))
  :bind (:map minibuffer-local-map
	      ("C-r" . counsel-minibuffer-history))
  )
;; TRAMP штуки
(setq tramp-default-method "sshx")

;; Rust штуки
(use-package rust-mode
  :config
  (setq lsp-rust-server 'rust-analyzer)
  (setq lsp-rust-analyzer-server-command "rust-analyzer")
  :hook (rust-mode-hook . #'lsp)
  )

;; Няшные хоткеи
;; direnv
(global-set-key (kbd "C-c C-d") 'direnv-mode)
;; magit
(setq smerge-command-prefix "\C-cv")
(global-set-key (kbd "C-c v m") 'magit-status)
;; buffers
(global-set-key (kbd "M-k") 'kill-this-buffer)
(global-set-key (kbd "M-o") 'other-window)

;; Org-mode
(global-set-key (kbd "C-c a") 'org-agenda)
(custom-set-variables
 '(org-agenda-files (quote ("~/Nextcloud/twilight.org"))))
