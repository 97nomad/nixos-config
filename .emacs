(package-initialize)

(custom-set-variables
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(blink-cursor-mode nil)
 '(initial-buffer-choice "~")
 '(package-selected-packages
   (quote
    (magit company nix-mode rainbow-delimeters dracula-theme helm lsp-haskell))))
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
(load-theme 'dracula t)
(set-face-attribute 'default nil
		    :family "Fira Code"
		    :height 100
		    :weight 'normal
		    :width 'normal)

;; MELPA
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-initialize)

;; Нумерация строк
(require 'linum)
(line-number-mode t)
(global-linum-mode t)
(column-number-mode t)
(setq linum-format " %d")

;; Отключение главного экрана
(setq inhibit-startup-message nil)

;; Автодополнение
(require 'company)
(global-company-mode t)

;; Не показывать предупреждение при нажатии A в dired
(put 'dired-find-alternate-file 'disabled nil)

;; Радужные штуки с скобочками
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)
(show-paren-mode 1)
(electric-pair-mode 1)

;; Штуки для гита
(setq smerge-command-prefix "\C-cv")
(global-set-key (kbd "C-c v m") 'magit-status)

;; Ivy штуки
(ivy-mode 1)
(setq ivy-use-virtual-buffers t)
(setq enable-recursive-minibuffers t)
(global-set-key "\C-s" 'swiper)
(global-set-key (kbd "C-c C-r") 'ivy-resume)
(global-set-key (kbd "C-c t") 'counsel-tramp)
(global-set-key (kbd "<f6>") 'ivy-resume)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "<f1> f") 'counsel-describe-function)
(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
(global-set-key (kbd "<f1> l") 'counsel-find-library)
(global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
(global-set-key (kbd "<f2> u") 'counsel-unicode-char)
(global-set-key (kbd "C-c g") 'counsel-git)
(global-set-key (kbd "C-c j") 'counsel-git-grep)
(global-set-key (kbd "C-c k") 'counsel-ag)
(global-set-key (kbd "C-x l") 'counsel-locate)
(global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
(define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)

;; Haskell штуки
(add-hook 'haskell-mode-hook #'lsp)
(setq lsp-haskell-process-path-hie "hie-wrapper")

;; TRAMP штуки
(setq tramp-default-method "sshx")
