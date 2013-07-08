;;; Custom emacs styes
(setq prelude-flyspell nil)

;; 2 spaces for tab
(setq-default tab-width 2
      indent-tabs-mode nil
      tab-always-indent nil
      display-time-24hr-format t
      display-time-day-and-date nil
      )

(defvaralias 'js-indent-level 'tab-width)
(defvaralias 'css-indent-level 'tab-width)
(defvaralias 'sgml-indent-level 'tab-width)
(defvaralias 'tab-indent-level 'tab-width)
(defvaralias 'c-indent-level 'tab-width)

;; Backup store cutomizations
(setq backup-by-copying t    ; Don't delink hardlinks
      backup-directory-alist '(("." . "~/.emacs.backups"))
      version-control t      ; Use version numbers on backups
      delete-old-versions t  ; Automatically delete excess backups
      kept-new-versions 20   ; how many of the newest versions to keep
      kept-old-versions 5    ; and how many of the old
      c-basic-offset 2
      auto-save-file-name-transforms `((".*" ,"~/.emacs.d/temps/autosaves" t))
      undo-tree-history-directory-alist '(("." . "~/.emacs.d/temps/undotrees"))
      )

;(global-auto-revert-mode t)

;; Some comfort styles
(setq-default cursor-type 'bar)
(blink-cursor-mode -1)
(display-time-mode 1)

; Mode specific configurations follow.
(prelude-ensure-module-deps '(js3-mode))
(add-hook 'js3-mode-hook
          (lambda ()
            (js3-manual-indentation t)
            (whitespace-mode t)
           ))

; Insert vertical ruler
(prelude-ensure-module-deps '(fill-column-indicator))
(setq fci-rule-width 2)
(setq fci-rule-column 79)
(add-hook 'after-change-major-mode-hook 'fci-mode)

;; Show whitepsaces, trailling spaces, lines longer than 80 columns, etc.
(setq-default whitespace-line-column 79
      whitespace-style '(face tabs trailing lines-tail))

;; Some functionality
;; Move lines with M-Up M-Down
(prelude-ensure-module-deps '(move-text))

(global-set-key (kbd "M-p") 'move-text-up)
(global-set-key (kbd "M-n") 'move-text-down)

(global-set-key (kbd "C-<tab>") 'next-buffer)
(global-set-key (kbd "C-S-<iso-lefttab>") 'previous-buffer)

;; I did this after pressing C-z many times by accident
(global-unset-key (kbd "C-z"))
