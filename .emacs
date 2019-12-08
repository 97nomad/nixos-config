(package-initialize)

(custom-set-variables
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(blink-cursor-mode nil)
 '(custom-enabled-themes (quote (tango-dark)))
 '(initial-buffer-choice "~")
 '(package-selected-packages
   (quote
    (magit company nix-mode rainbow-delimeters))))
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
