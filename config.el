;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name (password-store-get "emacs/personal_info/name")
      user-mail-address (password-store-get "emacs/personal_info/email"))

(setq epg-gpg-program "/opt/homebrew/bin/gpg")

(after! epa
  (setq epg-pinentry-mode nil))

(after! password-store
  (setq epa-file-encrypt-to (list (password-store-get "emacs/personal_info/email"))))

(after! auth-source
  (setq auth-sources '("~/.authinfo.gpg")
        auth-source-cache-expiry 21600))

(after! browse-url
  (setq browse-url-browser-function 'browse-url-default-browser))
        ;; browse-url-generic-program (executable-find "firefox")))

;; (setq browse-url-browser-function 'xwidget-webkit-browse-url)

(add-transient-hook! 'focus-out-hook (atomic-chrome-start-server))

(setq-default major-mode 'org-mode)

(setq doom-fallback-buffer-name "► Doom"
      +doom-dashboard-name "► Doom")

(setq frame-title-format
      '(""
        (:eval
         (let ((fname (buffer-file-name)))
           (if (and fname (boundp 'org-roam-directory) org-roam-directory
                    (s-contains-p org-roam-directory fname))
               (replace-regexp-in-string
                ".*/[0-9]*-?" "☰ "
                (subst-char-in-string ?_ ?  fname))
             "%b")))
        (:eval
         (let ((project-name (projectile-project-name)))
           (unless (string= "-" project-name)
             (format (if (buffer-modified-p)  " ◉ %s" "  ●  %s") project-name))))))

(map! :leader
      :prefix "b"
      :desc "Flycheck errors" "e" #'consult-flycheck
      :desc "Focus lines" "F" #'consult-focus-lines
      :desc "History" "h" #'consult-history)

(use-package! corfu
  :defer t
  :custom
  (setq corfu-cycle
        corfu-preselect 'directory))

(setq which-key-idle-delay 0.2)
(setq which-key-idle-secondary-delay 0.01)

;; (after! spell-fu
;;   (setq spell-fu-idle-delay 0.5))

(use-package! dirvish
  :defer t
  :init
  (dirvish-override-dired-mode)
  :config
  (setq dirvish-side-follow-mode t
        dirvish-peek-mode t
        dirvish-preview-dispatchers
        (cl-substitute 'pdf-preface 'pdf dirvish-preview-dispatchers)))

(after! evil
  (setq evil-kill-on-visual-paste nil)) ; Don't put overwritten text in the kill ring

(map! :map evil-insert-state-map
      "C-p" #'evil-previous-line
      "C-n" #'evil-next-line)

(use-package! nov
  :defer t
  :mode ("\\.epub\\'" . nov-mode)
  :config
  ;; (map! :map nov-mode-map
  ;;       :n "RET" #'nov-scroll-up)

  (advice-add 'nov-render-title :override #'ignore)

  (defun +nov-mode-setup ()
    "Tweak nov-mode to our liking."
    ;; (face-remap-add-relative 'variable-pitch
    ;;                          :family "Merriweather"
    ;;                          :height 1.4
    ;;                          :width 'semi-expanded)
    (face-remap-add-relative 'default :height 1.3)
    (variable-pitch-mode 1)
    (setq-local line-spacing 0.2
                next-screen-context-lines 4
                shr-use-colors nil)
    (when (require 'visual-fill-column nil t)
      (setq-local visual-fill-column-center-text t
                  visual-fill-column-width 64
                  nov-text-width 106)
      (visual-fill-column-mode 1))
    (when (featurep 'hl-line-mode)
      (hl-line-mode -1))
    ;; Re-render with new display settings
    (nov-render-document)
    ;; Look up words with the dictionary.
    (add-to-list '+lookup-definition-functions #'+lookup/dictionary-definition))

  (add-hook 'nov-mode-hook #'+nov-mode-setup))

(use-package nov-xwidget
  :after nov
  :config

(add-hook! 'nov-mode-hook #'nov-xwidget-inject-all-files))

(after! doom-modeline
  (defvar doom-modeline-nov-title-max-length 40)
  (doom-modeline-def-segment nov-author
    (propertize
     (cdr (assoc 'creator nov-metadata))
     'face (doom-modeline-face 'doom-modeline-project-parent-dir)))
  (doom-modeline-def-segment nov-title
    (let ((title (or (cdr (assoc 'title nov-metadata)) "")))
      (if (<= (length title) doom-modeline-nov-title-max-length)
          (concat " " title)
        (propertize
         (concat " " (truncate-string-to-width title doom-modeline-nov-title-max-length nil nil t))
         'help-echo title))))
  (doom-modeline-def-segment nov-current-page
    (let ((words (count-words (point-min) (point-max))))
      (propertize
       (format " %d/%d"
               (1+ nov-documents-index)
               (length nov-documents))
       'face (doom-modeline-face 'doom-modeline-info)
       'help-echo (if (= words 1) "1 word in this chapter"
                    (format "%s words in this chapter" words)))))
  (doom-modeline-def-segment scroll-percentage-subtle
    (concat
     (doom-modeline-spc)
     (propertize (format-mode-line '("" doom-modeline-percent-position "%%"))
                 'face (doom-modeline-face 'shadow)
                 'help-echo "Buffer percentage")))

  (doom-modeline-def-modeline 'nov
    '(workspace-name window-number nov-author nov-title nov-current-page scroll-percentage-subtle))
    ;; '(media-player misc-info major-mode time))

  (add-to-list 'doom-modeline-mode-alist '(nov-mode . nov)))

(after! flycheck
  (setq flycheck-checker-error-threshold 10000))

;; Use fish for interactive shells, /bin/sh for non-interactive (org-babel, TRAMP)
(setq explicit-shell-file-name (executable-find "fish"))
(setq shell-file-name "/bin/sh")

;; Use the system trash
(setq delete-by-moving-to-trash t
      x-stretch-cursor t)

;; General file settings
(setq undo-limit 80000000
      evil-want-fine-undo t
      auto-save-default t
      password-cache-expiry 300)

;; (setq debug-on-error t)

(setq global-subword-mode t)

;; Set vertico/consult commands
(map! "C-s" #'+default/search-buffer)
(map! "C-M-s" #'+vertico/search-symbol-at-point)
(map! :leader
      :prefix "s"
      :desc "fd file" "f" #'+vertico/consult-fd-or-find
      :desc "ripgrep file" "g" #'consult-ripgrep
      :desc "Search help" "h" #'consult-info
      :desc "Search man" "M" #'consult-man
      :desc "Outline" "o" #'consult-outline)

;; TODO
;; Use delete to move back a page in which-key
;; (map! which-key-mode-map
;;       "DEL" #'which-key-undo)

;; Disable toolbar on mac
;; (when (string= (system-name) "maccie")
;;   (add-hook 'doom-after-init-hook (lambda () (tool-bar-mode 1) (tool-bar-mode 0))))

;; Enable nicer scrolling
;; (pixel-scroll-precision-mode)
;; (setq pixel-scroll-precision-interpolate-mice t)
(setq next-screen-context-lines 2
      mouse-wheel-tilt-scroll t
      mouse-wheel-flip-direction t)

(use-package! ultra-scroll
  :init
  (ultra-scroll-mode 1)
  (setq scroll-conservatively 10
        scroll-margin 0))
        ;; scroll-margin 2))  ; TODO when scroll-margin 2 is supported

(use-package! gptel
  :config
  (setq gptel-backend (gptel-make-anthropic "Claude"
                        :stream t
                        :key #'gptel-api-key-from-auth-source)
        gptel-model 'claude-opus-4-6)
  
  (gptel-make-gh-copilot "Copilot")

  (add-hook 'gptel-post-stream-hook 'gptel-auto-scroll)
  (add-hook 'gptel-post-response-functions 'gptel-end-of-response))

(set-popup-rule! "\\*\\(Claude\\|Copilot\\)\\*"
  :side 'right
  :width 0.3
  :select t)

(use-package! claude-code-ide
  :config
  (claude-code-ide-emacs-tools-setup)) ; Optionally enable Emacs MCP tools

(map! :leader
      :prefix "o l"
      "c" #'claude-code-ide-menu)

(setq display-line-numbers-type 'relative)

(add-hook 'text-mode-hook 'turn-on-visual-line-mode)
(setq visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow))

;; (setq-default auto-fill-function 'do-auto-fill)

(setq projectile-sort-order 'recently-active
      projectile-auto-discover t
      projectile-enable-caching t
      projectile-file-exists-remote-cache-expire (* 10 60))

(after! spell-fu
  (setq ispell-personal-dictionary "~/.config/emacs/.local/etc/ispell/.pws")
  (setq ispell-dictionary "en_GB"))

(use-package! jinx
  :defer t
  :init
  (setenv "PKG_CONFIG_PATH" (concat "/opt/homebrew/opt/glib/lib/pkgconfig/:" (getenv "PKG_CONFIG_PATH")))
  (add-hook 'doom-init-ui-hook #'global-jinx-mode)
  :custom
  (setq jinx-languages "en_GB")
  :config
  (push 'org-inline-src-block
        (alist-get 'org-mode jinx-exclude-faces)))

(map! :after jinx
      :map jinx-overlay-map
      "M-o" #'jinx-correct
      "M-S-o" #'jinx-correct-all)

;;   ;; Take over the relevant bindings.
;;   (after! ispell
;;     (global-set-key [remap ispell-word] #'jinx-correct))
;;   (after! evil-commands
;;     (global-set-key [remap evil-next-flyspell-error] #'jinx-next)
;;     (global-set-key [remap evil-prev-flyspell-error] #'jinx-previous))

(use-package! treemacs
  :defer t
  :init
  (lsp-treemacs-sync-mode 1)
  :config
  (progn
    (setq treemacs-eldoc-display 'detailed
          treemacs-find-workspace-method 'find-for-file-or-pick-first
          treemacs-indent-guide-style 'line
          treemacs-missing-project-action 'remove
          treemacs-move-forward-on-expand t
          treemacs-project-follow-cleanup t
          treemacs-project-follow-into-home t
          treemacs-recenter-after-file-follow 'always
          treemacs-recenter-after-project-expand 'always
          treemacs-recenter-after-project-jump 'always
          treemacs-recenter-after-tag-follow 'always
          treemacs-recenter-distance 0.2
          treemacs-show-hidden-files nil
          treemacs-select-when-already-in-treemacs 'next-or-back
          treemacs-sorting 'alphabetic-numeric-case-insensitive-asc
          treemacs-tag-follow-delay 1.0
          treemacs-width-increment 5)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (treemacs-indent-guide-mode t)
    (treemacs-project-follow-mode t)
    (treemacs-tag-follow-mode t)
    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))

  ;; :bind
  (map! :nvi "M-0" nil)  ; unbind from go to last workspace
  (map! "M-0" #'treemacs-select-window))
        ;; ("SPC e 1"   . treemacs-delete-other-windows)
        ;; ("SPC e t"   . treemacs)
        ;; ("SPC e d"   . treemacs-select-directory)
        ;; ("SPC e b"   . treemacs-bookmark)
        ;; ("SPC e f"   . treemacs-find-file)
        ;; ("SPC e F"   . treemacs-find-tag)))

(after! imenu
  (setq imenu-auto-rescan t))

(setq tramp-default-method "ssh")
(setq tramp-default-remote-shell "/bin/sh")

(setq evil-vsplit-window-right t
      evil-split-window-below t)

(defadvice! prompt-for-buffer (&rest _)
  :after '(evil-window-split evil-window-vsplit)
  (consult-buffer))

(setq window-combination-resize t)

(setq yas-triggers-in-field t)

(after! org
  (sp-local-pair
   '(org-mode)
   "<<" ">>"
   :actions
   '(insert))

  (sp-local-pair
   '(org-mode)
   "$$" "$$"
   :actions
   '(insert)))

(when (string= (system-name) "maccie")
  ;; (setq doom-font (font-spec :family "Fira Code" :size 15)
  (setq doom-font (font-spec :family "JetBrainsMono NF" :size 15)
        doom-big-font (font-spec :family "Iosevka Aile" :size 20)
        doom-variable-pitch-font (font-spec :family "Iosevka Aile" :size 15)))

(when (string= (system-name) "archie")
;;   ;; (setq doom-font (font-spec :family "Fira Code" :size 16)
  (setq doom-font (font-spec :family "JetBrainsMonoNerdFont" :size 16)
        doom-big-font (font-spec :family "Iosevka Aile" :size 21)
        doom-variable-pitch-font (font-spec :family "Iosevka Aile" :size 16)))

(after! text-mode
  (set-input-method 'TeX))

(defun doom-modeline-conditional-buffer-encoding ()
  "We expect the encoding to be LF UTF-8, so only show the modeline when this is not the case"
  (setq-local doom-modeline-buffer-encoding
              (unless (and (memq (plist-get (coding-system-plist buffer-file-coding-system) :category)
                                 '(coding-category-undecided coding-category-utf-8))
                           (not (memq (coding-system-eol-type buffer-file-coding-system) '(1 2))))
                t)))

(add-hook 'after-change-major-mode-hook #'doom-modeline-conditional-buffer-encoding)

(after! doom-modeline
  (doom-modeline-def-segment buffer-name
    "Display the current buffer's name, without any other information."
    (concat
     (doom-modeline-spc)
     (doom-modeline--buffer-name)))

  (doom-modeline-def-segment pdf-icon
    "PDF icon from all-the-icons."
    (concat
     (doom-modeline-spc)
     (doom-modeline-icon 'octicon "file-pdf" nil nil
                         :face (if (doom-modeline--active)
                                   'all-the-icons-red
                                 'mode-line-inactive)
                         :v-adjust 0.02)))

  (defun doom-modeline-update-pdf-pages ()
    "Update PDF pages."
    (setq doom-modeline--pdf-pages
          (let ((current-page-str (number-to-string (eval `(pdf-view-current-page))))
                (total-page-str (number-to-string (pdf-cache-number-of-pages))))
            (concat
             (propertize
              (concat (make-string (- (length total-page-str) (length current-page-str)) ? )
                      " P" current-page-str)
              'face 'mode-line)
             (propertize (concat "/" total-page-str) 'face 'doom-modeline-buffer-minor-mode)))))

  (doom-modeline-def-segment pdf-pages
    "Display PDF pages."
    (if (doom-modeline--active) doom-modeline--pdf-pages
      (propertize doom-modeline--pdf-pages 'face 'mode-line-inactive)))

  (doom-modeline-def-modeline 'pdf
    '(bar window-number pdf-pages pdf-icon buffer-name)
    '(misc-info matches major-mode process vcs)))

(defvar fancy-splash-image-template
  (expand-file-name "splash/doom-emacs-splash-template.svg" doom-private-dir)
  "Default template svg used for the splash image, with substitutions from ")

(defvar fancy-splash-sizes
  `((:height 500 :min-height 50 :padding (0 . 2))
    (:height 450 :min-height 42 :padding (2 . 4))
    (:height 400 :min-height 35 :padding (3 . 3))
    (:height 350 :min-height 28 :padding (3 . 3))
    (:height 200 :min-height 20 :padding (2 . 2))
    (:height 150  :min-height 15 :padding (2 . 1))
    (:height 100  :min-height 13 :padding (2 . 1))
    (:height 75  :min-height 12 :padding (2 . 1))
    (:height 50  :min-height 10 :padding (1 . 0))
    (:height 1   :min-height 0  :padding (0 . 0)))
  "list of plists with the following properties
  :height the height of the image
  :min-height minimum `frame-height' for image
  :padding `+doom-dashboard-banner-padding' (top . bottom) to apply
  :template non-default template file
  :file file to use instead of template")

(defvar fancy-splash-template-colours
  '(("$color1" . functions) ("$color2" . keywords) ("$color3" .  highlight) ("$color4" . bg) ("$color5" . bg) ("$color6" . base0))
  ;; 1: Text up, 2: Text low, 3: upper outlines, 4: shadow, 5: background, 6: gradient to middle
  "list of colour-replacement alists of the form (\"$placeholder\" . 'theme-colour) which applied the template")

(unless (file-exists-p (expand-file-name "theme-splashes" doom-cache-dir))
  (make-directory (expand-file-name "theme-splashes" doom-cache-dir) t))

(defun fancy-splash-filename (theme-name height)
  (expand-file-name (concat (file-name-as-directory "theme-splashes")
                            theme-name
                            "-" (number-to-string height) ".svg")
                    doom-cache-dir))

(defun fancy-splash-clear-cache ()
  "Delete all cached fancy splash images"
  (interactive)
  (delete-directory (expand-file-name "theme-splashes" doom-cache-dir) t)
  (message "Cache cleared!"))

(defun fancy-splash-generate-image (template height)
  "Read TEMPLATE and create an image if HEIGHT with colour substitutions as
   described by `fancy-splash-template-colours' for the current theme"
  (with-temp-buffer
    (insert-file-contents template)
    (re-search-forward "$height" nil t)
    (replace-match (number-to-string height) nil nil)
    (replace-match (number-to-string height) nil nil)
    (dolist (substitution fancy-splash-template-colours)
      (goto-char (point-min))
      (while (re-search-forward (car substitution) nil t)
        (replace-match (doom-color (cdr substitution)) nil nil)))
    (write-region nil nil
                  (fancy-splash-filename (symbol-name doom-theme) height) nil nil)))

(defun fancy-splash-generate-images ()
  "Perform `fancy-splash-generate-image' in bulk"
  (dolist (size fancy-splash-sizes)
    (unless (plist-get size :file)
      (fancy-splash-generate-image (or (plist-get size :template)
                                       fancy-splash-image-template)
                                   (plist-get size :height)))))

(defun ensure-theme-splash-images-exist (&optional height)
  (unless (file-exists-p (fancy-splash-filename
                          (symbol-name doom-theme)
                          (or height
                              (plist-get (car fancy-splash-sizes) :height))))
    (fancy-splash-generate-images)))

(defun get-appropriate-splash ()
  (let ((height (frame-height)))
    (cl-some (lambda (size) (when (>= height (plist-get size :min-height)) size))
             fancy-splash-sizes)))

(setq fancy-splash-last-size nil)
(setq fancy-splash-last-theme nil)
(defun set-appropriate-splash (&rest _)
  (let ((appropriate-image (get-appropriate-splash)))
    (unless (and (equal appropriate-image fancy-splash-last-size)
                 (equal doom-theme fancy-splash-last-theme)))
    (unless (plist-get appropriate-image :file)
      (ensure-theme-splash-images-exist (plist-get appropriate-image :height)))
    (setq fancy-splash-image
          (or (plist-get appropriate-image :file)
              (fancy-splash-filename (symbol-name doom-theme) (plist-get appropriate-image :height))))
    (setq +doom-dashboard-banner-padding (plist-get appropriate-image :padding))
    (setq fancy-splash-last-size appropriate-image)
    (setq fancy-splash-last-theme doom-theme)
    (+doom-dashboard-reload)))

(add-hook 'window-size-change-functions #'set-appropriate-splash)
(add-hook 'doom-load-theme-hook #'set-appropriate-splash)

(after! centaur-tabs
  (centaur-tabs-mode -1)
  (setq centaur-tabs-set-icons t
        ;; centaur-tabs-style "wave"
        ;; centaur-tabs-set-modified-marker t
        ;; centaur-tabs-modified-marker "o"
        ;; centaur-tabs-close-button "×"
        centaur-tabs-set-bar 'left
        centaur-tabs-gray-out-icons 'buffer))
  ;; (centaur-tabs-change-fonts "P22 Underground Book" 160))
;; (setq x-underline-at-descent-line t)

;; (set-frame-parameter nil 'ns-alpha-elements
;;                      '(
;;                        ns-alpha-default
;;                        ns-alpha-fringe
;;                        ns-alpha-box
;;                        ns-alpha-stipple
;;                        ns-alpha-relief
;;                        ns-alpha-glyphs
;;                        ))

;; (set-frame-parameter nil 'alpha-background 0.75)
;; (set-frame-parameter nil 'ns-background-blur 100)

;; (after! solar
;;   (setq calendar-latitude (string-to-number (password-store-get "emacs/solar/latitude")))
;;   (setq calendar-longitude (string-to-number (password-store-get "emacs/solar/longitude"))))

;; (use-package! circadian
;;   :defer t
;;   :config
;;   (setq circadian-themes '((:sunrise . doom-dracula)
;;                            (:sunset . doom-one))))

;; (circadian-setup)

;; (set-frame-parameter (selected-frame) 'alpha '(85 85))
;; (add-to-list 'default-frame-alist '(alpha 85 85))

;; (doom/set-frame-opacity 100)
;; (doom/set-frame-opacity 95)
;; (doom/set-frame-opacity 85)

(map! :leader
      :prefix "c"
      :desc "Aphelia format buffer" "F" #'apheleia-format-buffer)

(map! :nvi "C-TAB" nil)
(map! :nvi "C-<tab>" nil)

;; accept completion from copilot and fallback to company
(use-package! copilot
  :hook ((prog-mode . copilot-mode)
         (sh-mode . copilot-mode))
  :bind (:map copilot-completion-map
              ("C-S-<iso-lefttab>" . 'copilot-accept-completion-by-word)
              ("C-S-<tab>" . 'copilot-accept-completion-by-word)
              ("C-TAB" . 'copilot-accept-completion-by-line)
              ("C-<tab>" . 'copilot-accept-completion-by-line)
              ("C-M-TAB" . 'copilot-accept-completion)
              ("C-M-<tab>" . 'copilot-accept-completion))
  :config
  (setq copilot-indent-offset-warning-disable t)
  (add-to-list 'copilot-indentation-alist '(prog-mode 4))
  (add-to-list 'copilot-indentation-alist '(sh-mode 2))
  (add-to-list 'copilot-indentation-alist '(fish-mode 4))
  (add-to-list 'copilot-indentation-alist '(emacs-lisp-mode 2))
  (add-to-list 'copilot-indentation-alist '(text-mode 2))
  (add-to-list 'copilot-indentation-alist '(tex-mode 2))
  (add-to-list 'copilot-indentation-alist '(latex-mode 2))
  (add-to-list 'copilot-indentation-alist '(LaTeX-mode 2))
  (add-to-list 'copilot-indentation-alist '(org-mode 2))
  (add-to-list 'copilot-indentation-alist '(markdown-mode 2)))

(map! :leader
      :desc "Toggle Copilot Completion" "c G" #'copilot-mode)

(after! copilot-chat
  (setq copilot-chat-frontend 'org
        copilot-chat-follow t
        copilot-chat-default-model "gemini-2.5-pro"
        copilot-chat-list-show-path nil))

(map! :map copilot-chat-map
      :n "M-p" #'copilot-chat-prompt-history-previous
      :n "M-n" #'copilot-chat-prompt-history-next
      :leader
      (:prefix ("cg" . "Copilot Chat")
       :desc "add current buffer" "a" #'copilot-chat-add-current-buffer
       :desc "switch to buffer" "b" #'copilot-chat-switch-to-buffer
       :desc "delete buffer" "D" #'copilot-chat-del-current-buffer
       :desc "buffer list" "l" #'copilot-chat-list
       :desc "transient" "g" #'copilot-chat-transient
       :desc "display" "G" #'copilot-chat-display
       :desc "reset" "R" #'copilot-chat-reset
       :desc "explain" "e" #'copilot-chat-explain
       :desc "explain symbol at point" "s" #'copilot-chat-explain-symbol-at-line
       :desc "explain function at point" "f" #'copilot-chat-explain-defun
       :desc "review" "r" #'copilot-chat-review
       :desc "review entire buffer" "B" #'copilot-chat-review-whole-buffer
       :desc "document" "d" #'copilot-chat-doc
       :desc "fix" "f" #'copilot-chat-fix
       :desc "optimise" "o" #'copilot-chat-optimize
       :desc "test" "t" #'copilot-chat-test
       :desc "custom paste" "P" #'copilot-chat-custom-prompt-selection
       :desc "custom function prompt" "F" #'copilot-chat-custom-prompt-function
       :desc "ask and insert" "i" #'copilot-chat-ask-and-insert
       :desc "insert commit message" "c" #'copilot-chat-insert-commit-messages
       :desc "set model" "m" #'copilot-chat-set-model))

(map! :leader
      (:desc "Copilot Chat" "C" #'copilot-chat-transient))

(add-hook! 'prog-mode-hook #'indent-bars-mode)

(after! indent-bars
  (setq indent-bars-treesit-support t
        indent-bars-color '(highlight :face-bg t :blend 0.2)
        indent-bars-pattern "."
        indent-bars-pad-frac 0.1
        indent-bars-highlight-current-depth '(:blend 0.55)))

  ;; (when (string= (system-name) "maccie")
  ;;   (setq indent-bars-prefer-character t)))

(map! :leader
      :desc "Indent bars" "t i" #'indent-bars-mode)

(add-hook! 'prog-mode-hook #'rainbow-delimiters-mode)
(add-hook! 'sh-mode-hook #'rainbow-delimiters-mode)

(+global-word-wrap-mode 1)
;; (add-hook! 'prog-mode-hook #'+word-wrap-mode)
;; (add-hook! 'sh-mode-hook #'+word-wrap-mode)

(map! :leader
      :desc "Magit pull" "g p" #'magit-pull
      :desc "Magit push" "g P" #'magit-push
      :desc "Magit diff" "g d" #'magit-diff
      :desc "Magit stash" "g z" #'magit-stash
      :desc "Magit stage all" "g a" #'magit-stage-modified
      :desc "Magit unstage all" "g A" #'magit-unstage-all)

(after! sh-mode
  (sh-set-shell "bash"))

(after! sh-mode
  (setq sh-indentation 2
        sh-basic-offset 2))

(after! f90-mode
  (setq f90-do-indent 2
        f90-if-indent 2
        f90-type-indent 2
        f90-program-indent 2
        f90-continuation-indent 4
        f90-smart-end 'blink))

(after! fortran-mode
  (setq fortran-continuation-string "&"
        fortran-do-indent 2
        fortran-if-indent 2
        fortran-structure-indent 2))

(set-formatter! 'fprettify
  '("fprettify" "-i 2" "-l 88" "-w 4" "--whitespace-comma=true" "--whitespace-assignment=true" "--whitespace-decl=true" "--whitespace-relational=true" "--whitespace-plusminus=true" "--whitespace-multdiv=true" "--whitespace-print=true" "--whitespace-type=true" "--whitespace-intrinsics=true" "--strict-indent" "--enable-decl" "--enable-replacements" "--c-relations" "--case 1 1 1 1" "--strip-comments" "--disable-fypp")
  :modes '(f90-mode fortran-mode))

(setq auto-mode-alist
      (cons '("\\.F90$" . f90-mode) auto-mode-alist))
(setq auto-mode-alist
      (cons '("\\.f90$" . f90-mode) auto-mode-alist))
(setq auto-mode-alist
      (cons '("\\.pf$" . f90-mode) auto-mode-alist))
(setq auto-mode-alist
      (cons '("\\.pf$" . f90-mode) auto-mode-alist))
(setq auto-mode-alist
      (cons '("\\.fpp$" . f90-mode) auto-mode-alist))
(setq auto-mode-alist
      (cons '("\\.F$" . fortran-mode) auto-mode-alist))
(setq auto-mode-alist
      (cons '("\\.f$" . fortran-mode) auto-mode-alist))

(use-package! lsp-mode
  :hook (f90-mode . lsp-deferred))

(use-package! julia-mode
  :init
  (setenv "JULIA_NUM_THREADS" "6,1")
  :interpreter
  ("julia" . julia-mode)
  :config
  (setq lsp-julia-package-dir nil))

;; (after! julia-mode
;;   (setq julia-snail-extensions '(repl-history formatter ob-julia)))

(use-package! julia-snail
  :hook (julia-mode . julia-snail-mode)
  ;; :custom
  ;; (julia-snail-terminal-type :eat)
  :config
  (setq julia-snail-extensions '(repl-history formatter)))  ; ob-julia

(map! :after julia-mode
      :map julia-mode-map
      :localleader
      ;; Rebind julia-snail to "m" to make it easier to jump between the REPL and .jl file
      :desc "" "'" nil
      :desc "Julia Snail" "m" #'julia-snail
      :desc "Format buffer" "f" #'julia-snail/formatter-format-buffer
      :desc "Format region" "F" #'julia-snail/formatter-format-region
      :desc "Paste REPL history" "p" #'julia-snail/repl-history-yank
      :desc "Show REPL history" "b" #'julia-snail/repl-history-buffer
      :desc "Search and paste REPL history" "s" 'julia-snail/repl-history-search-and-yank)

(after! julia-mode
  (add-hook! 'before-save-hook #'julia-snail/formatter-format-buffer))

(after! julia-mode
  (add-hook! 'julia-mode-hook #'lsp-mode)
  (add-hook! 'julia-mode-hook #'julia-snail-mode))

(setq lsp-julia-package-dir nil)

(after! lsp-julia
  (setq lsp-julia-default-environment "~/.julia/environments/emacs-julia"))

(setq! bibtex-completion-bibliography '("~/Documents/warwick/thesus/references.bib"))

(eval-after-load 'latex
                 '(define-key LaTeX-mode-map [(tab)] 'cdlatex-tab))

(after! cdlatex
  (setq cdlatex-env-alist
        '(("non-numbered equation" "\\begin{equation*}\n    ?\n\\end{equation*}" nil)
          ("equation" "\\begin{equation}\n    ?\n\\end{equation}" nil) ; This might not work
          ("bmatrix" "\\begin{equation*}\n    ?\n    \\begin{bmatrix}\n        \n    \\end{bmatrix}\n\\end{equation*}" nil)
          ("vmatrix" "\\begin{equation*}\n    ?\n    \\begin{vmatrix}\n        \n    \\end{vmatrix}\n\\end{equation*}" nil)
          ("pmatrix" "\\begin{equation*}\n    ?\n    \\begin{pmatrix}\n        \n    \\end{pmatrix}\n\\end{equation*}" nil)
          ("split" "\\begin{equation}\n    \n    \\begin{split}\n        ?\n    \\end{split}\n\\end{equation}" nil)
          ("non-numbered split" "\\begin{equation*}\n    \\begin{split}\n        ?\n    \\end{split}\n\\end{equation*}" nil)))
  (setq cdlatex-command-alist
        '(("neq" "Insert non-numbered equation env" "" cdlatex-environment ("non-numbered equation") t nil)
          ("equ" "Insert numbered equation env" "" cdlatex-environment ("equation") t nil) ; This might not work
          ("bmat" "Insert bmatrix env" "" cdlatex-environment ("bmatrix") t nil)
          ("vmat" "Insert vmatrix env" "" cdlatex-environment ("vmatrix") t nil)
          ("pmat" "Insert pmatrix env" "" cdlatex-environment ("pmatrix") t nil)
          ("spl" "Insert split env" "" cdlatex-environment ("split") t nil)
          ("nspl" "Insert non-numbered split env" "" cdlatex-environment ("non-numbered split") t nil)))
  (setq cdlatex-math-symbol-alist
        '((?= ("\\equiv" "\\leftrightarrow" "\\longleftrightarrow"))
          (?! ("\\neq"))
          (?+ ("\\cup" "\\pm"))
          (?^ ("\\uparrow" "\\downarrow"))
          (?: ("\\cdots" "\\vdots" "\\ddots"))
          (?b ("\\beta" "\\mathbb{?}"))
          (?i ("\\in" "\\implies" "\\imath"))
          (?I ("\\int" "\\Im"))
          (?F ("\\Phi"))
          (?P ("\\Pi" "\\propto"))
          (?Q ("\\Theta" "\\quad" "\\qquad"))
          (?S ("\\Sigma" "\\sum" "\\arcsin"))
          (?t ("\\tau" "\\therefore" "\\tan"))
          (?T ("\\times" "" "\\arctan"))
          (?V ())
          (?/ ("\\frac{?}{}" "\\not")) ;; Normal fr command doesn't work properly
          (?< ("\\leq" "\\ll" "\\longleftarrow"))
          (?> ("\\geq" "\\gg" "\\longrightarrow"))
          (?$ ("\\leftarrow" "" ""))
          (?% ("\\rightarrow" "" "")))))

(setq major-mode-remap-alist major-mode-remap-defaults)

(after! (:or tex-mode LaTeX-mode TeX-mode latex-mode)
  (setenv "PATH" (concat (getenv "PATH") ":/usr/bin/"))
  (setq exec-path (append exec-path '("/usr/bin/")))
  (setq tex-command "latexmk"
        tex-run-command "latexmk"
        latex-run-command "latexmk"
        TeX-master 'dwim
        TeX-engine 'lualatex
        TeX-command "latexmk"
        TeX-command-default "LaTeXMk"
        TeX-command-extra-options "-bibtex -lualatex -ps-"
        TeX-show-compilation nil
        TeX-electric-sub-and-superscript t
        TeX-electric-math (cons "\\(" "")
        TeX-electric-escape t
        TeX-view-program-selection '((output-pdf "PDF Tools")
                                     ((output-dvi has-no-display-manager) "dvi2tty")
                                     ((output-dvi style-pstricks) "dvips and gv")
                                     (output-dvi "xdvi")
                                     (output-html "xdg-open"))

        LaTeX-command "latexmk"
        ;; LaTeX-default-format "  "
        LaTeX-default-environment "figure"
        LaTeX-electric-left-right-brace t))
        ;; +latex-viewers '(pdf-tools) ; skim evince sumatrapdf zathura okular))

;; (use-package! lsp-ltex-plus
;;   :hook (text-mode . (lambda ()
;;                        (require 'lsp-ltex-plus)
;;                        (lsp-deferred)))  ; or lsp
;;   :init
;;   (setq lsp-ltex-plus-version "18.5.1")  ; make sure you have set this, see below
;;   :config
;;   (setq lsp-ltex-plus-mother-tongue "en-GB"
;;         lsp-ltex-plus-server-store-path (executable-find "ltex-ls-plus")))
;;         
;; (use-package! lsp-ltex
;;   :hook (text-mode . (lambda ()
;;                        (require 'lsp-ltex)
;;                        (lsp-deferred)))  ; or lsp
;;   :init
;;   (setq lsp-ltex-version "16.0.0"))  ; make sure you have set this, see below
  ;; (setq lsp-ltex-version (gethash "ltex-ls" (json-parse-string (shell-command-to-string "ltex-ls-plus -V"))))  ; make sure you have set this, see below
  ;; :config
  ;; (setq lsp-ltex-mother-tongue "en-GB"
  ;;       lsp-ltex-server-store-path (executable-find "ltex-ls")))

(after! lsp-mode
  (setq lsp-ltex-plus-mother-tongue "en-GB"
        lsp-ltex-plus-language "en-GB"
        lsp-ltex-plus-disabled-rules '(:en-GB ["OXFORD_SPELLING_Z_NOT_S"])
        lsp-ltex-plus-completion-enabled t
        ;; lsp-ltex-plus-languagetool-http-server-uri ""
        lsp-ltex-plus-additional-rules-enable-picky-rules t))

;; (let ((credential (auth-source-user-and-password "languagetool")))
;;   (setq lsp-ltex-plus-languagetool-org-username (car credential)
;;         lsp-ltex-plus-languagetool-org-api-key (cadr credential)))

(after! LaTeX-mode
  ;; When on mac
  (when (string= (system-name) "maccie")
    (add-to-list 'load-path "/opt/homebrew/bin/texlab")
    (setq lsp-latex-texlab-executable "/opt/homebrew/bin/texlab"))

  ;; When on arch
  ;; (when (string= (system-name) "archie")
  ;;   (add-to-list 'load-path "/usr/bin/texlab")
  ;;   (setq lsp-latex-texlab-executable "/usr/bin/texlab"))

  (with-eval-after-load "tex-mode"
    (add-hook 'tex-mode-hook 'lsp)
    (add-hook 'latex-mode-hook 'lsp)
    (add-hook 'LaTeX-mode-hook 'lsp))
  (with-eval-after-load "bibtex"
    (add-hook 'bibtex-mode-hook 'lsp)))

(map! :after latex
      :map LaTeX-mode-map
      :localleader
      :desc "" "P" nil
      :desc "Unpreview" "P" #'preview-clearout-buffer)

(after! latex
  (setq reftex-default-bibliography "~/Documents/warwick/thesus/references.bib"))

(map! :map reftex-mode-map
      :localleader
      :desc "reftex-cite" "r" #'reftex-citation
      :desc "reftex-reference" "R" #'reftex-reference
      :desc "reftex-label" "l" #'reftex-label)

(use-package! zotra
  :defer t
  :config
  (setq zotra-backend 'zotra-server)
  (setq zotra-local-server-directory "~/Applications/zotra-server/"))

(after! lsp-mode
  (setq lsp-enable-symbol-highlighting t
        lsp-lens-enable t
        lsp-headerline-breadcrumb-enable t
        lsp-modeline-code-actions-enable t
        lsp-modeline-diagnostics-enable t
        lsp-diagnostics-provider :auto
        lsp-eldoc-enable-hover t
        lsp-completion-provider :capf
        lsp-completion-show-detail t
        lsp-completion-show-kind t
        lsp-signature-render-documentation t
        lsp-idle-delay 0.75))

(after! lsp-ui
    (setq lsp-ui-doc-enable t
          lsp-ui-doc-show-with-cursor t
          lsp-ui-doc-show-with-mouse t
          lsp-headerline-breadcrumb-enable t
          lsp-ui-sideline-enable t
          lsp-ui-sideline-show-code-actions t
          lsp-ui-sideline-show-hover t
          lsp-ui-sideline-delay 0.5
          lsp-ui-sideline-show-symbol t
          lsp-ui-sideline-show-diagnostics t
          lsp-ui-sideline-update-mode 'line
          lsp-ui-peek-enable t
          lsp-ui-peek-show-directory t
          lsp-ui-doc-delay 1
          lsp-ui-doc-header t
          lsp-ui-doc-use-childframe t
          lsp-ui-doc-position 'top
          lsp-ui-doc-max-height 20
          lsp-ui-doc-max-width 80
          lsp-ui-doc-use-webkit nil
          lsp-ui-imenu-enable t
          lsp-ui-imenu-kind-position 'left
          lsp-ui-imenu-buffer-position 'right
          lsp-ui-imenu-window-width 40
          lsp-ui-imenu-auto-refresh t
          lsp-ui-imenu-auto-refresh-delay 1.0))

(map! :map lsp-ui-mode-map "C-," #'lsp-ui-doc-toggle)
(map! :map lsp-ui-mode-map "C-;" #'lsp-ui-doc-focus-frame)

;; (map! :after lsp-mode
;;       :map lsp-mode-map
;;       :leader
;;       :prefix ("#" . "custom")
;;       :prefix ("# l" . "lsp")
;;       :desc "open imenu"
;;       "i" #'lsp-ui-imenu
;;       "I" #'lsp-ui-imenu--refresh)

(use-package! grip-mode
  :defer t
  :config
  (let ((credential (auth-source-user-and-password "api.github.com")))
    (setq grip-github-user (car credential)
          grip-github-password (cadr credential)))

  (setq grip-sleep-time 2
        grip-preview-use-webkit t
        grip-url-browser nil))

  ;; (when (string= (system-name) "archie")
  ;;   (setq grip-binary-path "/home/dylanmorgan/.local/bin/grip"))
  ;; (when (string= (system-name) "maccie")
  ;;   (setq grip-binary-path "/opt/homebrew/bin/grip")))

(after! markdown-mode
  (add-hook! (gfm-mode markdown-mode) #'visual-line-mode #'turn-off-auto-fill))

(after! markdown-mode
  (custom-set-faces!
    '(markdown-header-face-1 :height 1.5 :weight extra-bold :inherit markdown-header-face)
    '(markdown-header-face-2 :height 1.25 :weight bold       :inherit markdown-header-face)
    '(markdown-header-face-3 :height 1.15 :weight bold       :inherit markdown-header-face)
    '(markdown-header-face-4 :height 1.00 :weight bold       :inherit markdown-header-face)
    '(markdown-header-face-5 :height 0.85 :weight bold       :inherit markdown-header-face)
    '(markdown-header-face-6 :height 0.75 :weight extra-bold :inherit markdown-header-face)))

;; (use-package! obsidian
;;   :ensure t
;;   :demand t
;;   :custom
;;   ;; This directory will be used for `obsidian-capture' if set.
;;   (obsidian-inbox-directory "inbox")
;;   ;; Create missing files in inbox? - when clicking on a wiki link
;;   ;; t: in inbox, nil: next to the file with the link
;;   ;; default: t
;;   ;(obsidian-wiki-link-create-file-in-inbox nil)
;;   ;; The directory for daily notes (file name is YYYY-MM-DD.md)
;;   (obsidian-daily-notes-directory "daily_notes")
;;   ;; Directory of note templates, unset (nil) by default
;;   ;(obsidian-templates-directory "Templates")
;;   ;; Daily Note template name - requires a template directory. Default: Daily Note Template.md
;;   ;(setq obsidian-daily-note-template "Daily Note Template.md")
;;   :config
;;   (obsidian-specify-path "~/Documents/obsidian/")
;;   ;; Activate detection of Obsidian vault
;;   (global-obsidian-mode t)
;;   (map! :map obsidian-mode-map
;;         :localleader
;;         :prefix ("O" . "Obsidian")
;;         ;; Replace C-c C-o with Obsidian.el's implementation. It's ok to use another key binding.
;;         :desc "follow link" "o" #'obsidian-follow-link-at-point
;;         ;; Jump to backlinks
;;         :desc "backlink jump" "b" #'obsidian-backlink-jump
;;         :desc "insert link" "l" #'obsidian-insert-wikilink
;;         ;; If you prefer you can use `obsidian-insert-link'
;;         :desc "insert wikilink" "w" #'obsidian-insert-wikilink
;;         ;; Open a note
;;         :desc "jump" "j" #'obsidian-jump
;;         ;; Capture a new note in the inbox
;;         :desc "capture" "c" #'obsidian-capture
;;         ;; Create a daily note
;;         :desc "daily note" #'obsidian-daily-note)

(set-formatter! 'ruff '("ruff" "format" "-") :modes '(python-mode))

(after! lsp-ruff
  (setq lsp-ruff-show-notifications "onError"))

(after! lsp-pyright
  (setq lsp-pyright-disable-language-services nil
        lsp-pyright-disable-organize-imports nil
        lsp-pyright-auto-import-completions t
        lsp-pyright-auto-search-paths t
        lsp-pyright-diagnostic-mode "openFilesOnly"
        lsp-pyright-log-level "info"
        lsp-pyright-type-checking-mode "basic"
        lsp-completion-enable t))

(use-package! numpydoc
  :after python
  :config
  (map! :map python-mode-map
        :localleader
        :desc "numpydoc" "n" #'numpydoc-generate)
  ;; (setq numpydoc-template-long "")
  (setq numpydoc-insertion-style 'yas))

(add-hook! 'python-mode #'uv-mode-auto-activate-hook)

(map! :map python-mode-map
      :localleader
      :desc "uv virtualenv" "u" #'uv-mode-set
      :desc "uv unset virtualenv" "U" #'uv-mode-unset)

(after! rustic
   (setq rustic-format-on-save t)
   (setq rustic-lsp-server 'rust-analyzer))

;; (add-hook! 'rust-mode-hook #'prettify-symbols-mode)

(after! org
  (setq org-agenda-files (directory-files-recursively "~/Documents/org/" "\\.org$")))

;; (use-package org-super-agenda
;;   :after org-agenda
;;   :config
;;   ;; 1. Enable the mode globally
;;   (org-super-agenda-mode 1)

;;   ;; 2. Optional: Style the headers to be slightly larger and underlined
;;   (setq org-super-agenda-header-properties '((face (:height 1.1 :underline t :weight bold)))
;;         org-super-agenda-header-separator "\n")

;;   ;; 3. Define the Grouping Strategy
;;   (setq my-super-agenda-groups
;;         '(;; --- CRITICAL ITEMS ---
;;           (:name "Overdue"
;;                  :deadline past
;;                  :face error
;;                  :order 1)
;;           (:name "High Priority"
;;                  :priority "A"
;;                  :order 2)

;;           ;; --- DAILY CONTEXT ---
;;           (:name "Today"
;;                  :time-grid t
;;                  :date today
;;                  :scheduled today
;;                  :deadline today  ;; Show deadlines due today in "Today" section
;;                  :order 3)

;;           ;; --- FUTURE PLANNING (Date-based) ---
;;           ;; Note: Items with dates are pulled here first, removing them from "Projects" etc.
;;           (:name "Upcoming Deadlines"
;;                  :deadline future
;;                  :order 4)
;;           (:name "Scheduled"
;;                  :scheduled future
;;                  :order 5)

;;           ;; --- ACTIVE WORKFLOW (Keyword-based) ---
;;           (:name "In Progress"
;;                  :todo ("STRT" "[-]")
;;                  :order 6)
;;           (:name "Projects"
;;                  :todo "PROJ"
;;                  :order 10)
;;           (:name "Routines"
;;                  :todo "LOOP"
;;                  :order 11)
;;           (:name "Next Actions"
;;                  :todo ("TODO" "[ ]")
;;                  :order 12)

;;           ;; --- PASSIVE / BLOCKED ---
;;           (:name "Waiting / On Hold"
;;                  :todo ("WAIT" "HOLD" "[?]")
;;                  :order 20)
;;           (:name "Ideas"
;;                  :todo "IDEA"
;;                  :order 30)
;;           (:name "Decisions / Review"
;;                  :todo ("OKAY" "YES" "NO")
;;                  :order 40)

;;           ;; --- LEFTOVERS ---
;;           (:name "Other"
;;                  :auto-category t
;;                  :order 90)))

;;   ;; 4. Apply globally (This ensures <SPC> o A works nicely)
;;   (setq org-super-agenda-groups my-super-agenda-groups)

;;   ;; 5. Define Custom Dashboard Command (This ensures <SPC> o a s works)
;;   (add-to-list 'org-agenda-custom-commands
;;                '("s" "Super Dashboard"
;;                  ((alltodo "" ((org-agenda-overriding-header "")
;;                                (org-super-agenda-groups my-super-agenda-groups)
;;                                ;; SORTING:
;;                                ;; 1. Deadlines (soonest first)
;;                                ;; 2. Scheduled (soonest first)
;;                                ;; 3. Priority (A -> B -> C)
;;                                (org-agenda-sorting-strategy '(deadline-up scheduled-up priority-down))))))))

(use-package! org-appear
  :after org
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autoemphasis t)
  (setq org-appear-autolinks nil
        org-appear-autosubmarkers t
        org-appear-autoentities t
        org-appear-autokeywords t
        org-appear-inside-latex t))

(after! org
  (setq org-attach-id-dir "~/Documents/org/.attach/"
        org-attach-dir-relative t
        org-attach-method 'mv
        org-attach-archive-delete 'query
        org-attach-auto-tag "attach"))

(after! org
  (require 'ob-fortran)
  (require 'ob-julia)
  (require 'ob-latex)
  (require 'ob-lua)
  (require 'ob-python)
  (require 'ob-shell)

  (require 'org-src)
  (require 'ob-emacs-lisp)
  (require 'ob-async)
  ;; (require 'ob-jupyter)
  ;; (require 'jupyter)
  ;; (require 'jupyter-org-client)

  (setq org-src-fontify-natively t
        org-src-tab-acts-natively t
        org-src-window-setup 'other-window)

  (set-popup-rule! "^\\*Org Src" :ignore t))

(after! org
  (setq org-structure-template-alist
        '(("a" . "export ascii\n")
          ("b" . "src bash\n")
          ("c" . "center\n")
          ("C" . "comment\n")
          ("e" . "example\n")
          ("E" . "export\n")
          ("f" . "src f90\n")
          ("h" . "export html\n")
          ("j" . "src jupyter-python\n")
          ("J" . "src julia\n")
          ("l" . "src emacs-lisp\n")
          ("L" . "export latex\n")
          ("p" . "src python\n")
          ("q" . "quote\n")
          ("s" . "src")
          ("S" . "src shell\n")
          ("t" . "src latex\n")
          ("v" . "verse\n"))))

(map! :map org-mode-map
      :after org
      :localleader
      :desc "org-insert-template" "w" #'org-insert-structure-template)

(map! :map org-mode-map
      :after org
      :localleader
      "k" nil
      "K" nil
      :prefix ("B" . "babel")
      :desc "Insert header arg" "a" #'org-babel-insert-header-arg
      :desc "Execute buffer" "b" #'org-babel-execute-buffer
      :desc "Check SRC block" "c" #'org-babel-check-src-block
      :desc "Demarcate block" "d" #'org-babel-demarcate-block
      :desc "Go to src block" "g" #'org-babel-goto-named-src-block
      :desc "Go to result" "G" #'org-babel-goto-named-result
      :desc "Toggle result visibility" "h" #'org-babel-hide-result-toggle
      :desc "Hide all results" "H" #'org-babel-result-hide-all
      :desc "Jupyter buffer" "j" #'org-babel-jupyter-scratch-buffer
      :desc "Open result" "o" #'org-babel-open-src-block-result
      :desc "Remove result" "r" #'org-babel-remove-result
      :desc "Remove all results" "R" #'+org/remove-result-blocks
      :desc "Execute subtree" "s" #'org-babel-execute-subtree
      :desc "Tangle SRC blocks" "t" #'org-babel-tangle)

(after! org
  (setq org-capture-templates
      '(("t" "Tasks" entry
         (file+headline "" "Inbox")
         "* TODO %?\n %U")
        ("c" "Phone Call" entry
         (file+headline "" "Inbox")
         "* TODO Call %?\n %U")
        ("m" "Meeting" entry
         (file+headline "" "Meetings")
         "* %?\n %U"))))

(use-package! oc-csl-activate
  :after (oc citar)
  :hook (org-mode . (lambda ()
                      (cursor-sensor-mode 1)
                      (org-cite-csl-activate-render-all)))
  :config
  (setq org-cite-activate-processor 'csl-activate
        org-cite-csl-activate-use-document-style t
        org-cite-csl-activate-use-document-style t
        org-cite-csl-activate-use-document-locale t
        org-cite-csl-activate-use-citar-cache t))

;; (defun +org-cite-csl-activate/enable ()
;;   (interactive)
;;   (setq org-cite-activate-processor 'csl-activate)
;;   (add-hook! 'org-mode-hook '((lambda () (cursor-sensor-mode 1)) org-cite-csl-activate-render-all))
;;   (defadvice! +org-cite-csl-activate-render-all-silent (orig-fn)
;;     :around #'org-cite-csl-activate-render-all
;;     (with-silent-modifications (funcall orig-fn)))
;;   (when (eq major-mode 'org-mode)
;;     (with-silent-modifications
;;       (save-excursion
;;         (goto-char (point-min))
;;         (org-cite-activate (point-max)))
;;       (org-cite-csl-activate-render-all)))
;;   (fmakunbound #'+org-cite-csl-activate/enable)))

(after! citar
  (setq org-cite-global-bibliography
        (let ((libfile-search-names '("references.bib" "references.json"))
              (libfile-dir "~/Documents/org/")
              paths)
          (dolist (libfile libfile-search-names)
            (when (and (not paths)
                       (file-exists-p (expand-file-name libfile libfile-dir)))
              (setq paths (list (expand-file-name libfile libfile-dir)))))
          paths)
        citar-bibliography org-cite-global-bibliography
        citar-symbols
        `((file ,(nerd-icons-faicon "nf-fa-file_o" :face 'nerd-icons-green :v-adjust -0.1) . " ")
          (note ,(nerd-icons-octicon "nf-oct-note" :face 'nerd-icons-blue :v-adjust -0.3) . " ")
          (link ,(nerd-icons-octicon "nf-oct-link" :face 'nerd-icons-orange :v-adjust 0.01) . " "))))

(after! oc-csl
  (setq org-cite-csl-styles-dir "~/Zotero/styles"))

(after! oc
  (setq org-cite-export-processors '((t csl))))

(map! :map org-mode-map
      :after org
      :localleader
      :desc "org-export-to-org"
      "E" 'org-org-export-to-org
      :desc "org-export-to-LaTeX-pdf"
      "L" 'org-latex-export-to-pdf
      :desc "org-export-as-md"
      "M" 'org-pandoc-export-to-markdown)

(use-package! org-pandoc-import
  :after org)

(after! org
  (setq org-directory "~/Documents/org/"
        org-id-locations-file "~/.config/emacs/.local/cache/.org-id-locations"
        org-use-property-inheritance t
        org-list-allow-alphabetical t
        org-export-in-background t
        org-fold-catch-invisible-edits 'smart))

(use-package! org-special-block-extras
  :hook (org-mode . org-special-block-extras-mode))

(after! org
  (setq org-startup-folded 'content
        org-startup-numerated nil))

(after! org
  (setq org-list-demote-modify-bullet '(("-" . "+")
                                        ("+" . "-")
                                        ("1." . "a.")
                                        ("1)" . "a)")))

  (setq org-list-use-circular-motion t
        org-list-allow-alphabetical t))

(defun dm/org--indent-length (s)
  "Return the visual indentation length of string S (tabs = 8 spaces)."
  (length (replace-regexp-in-string "\t" "        " s)))

(defun dm/org--heading-boundary ()
  "Return the position of the previous heading line, or `point-min'."
  (save-excursion
    (if (re-search-backward "^\\*+ " nil t)
        (line-beginning-position)
      (point-min))))

(defun dm/org--find-prev-sibling-item (indent-len limit)
  "Search backward from point for a list item at INDENT-LEN, stopping at LIMIT.
Skip items at deeper indent levels.  Stop if a less-indented item
or a heading is reached."
  (let ((found nil)
        (item-re "^\\([ \t]*\\)\\([-+]\\|[0-9]+[.)]\\|[a-zA-Z][.)]\\) "))
    (save-excursion
      (while (and (not found)
                  (re-search-backward item-re limit t))
        (let ((candidate-indent-len (dm/org--indent-length (match-string 1))))
          (cond
           ((= candidate-indent-len indent-len) (setq found (point)))
           ((< candidate-indent-len indent-len) (goto-char limit))))))
    found))

(defun dm/org--prev-sibling-has-nested (prev-item-pos item-bol indent-len)
  "Check if the list item at PREV-ITEM-POS has nested content before ITEM-BOL.
INDENT-LEN is the visual indent of both sibling items."
  (save-excursion
    (goto-char prev-item-pos)
    (let ((prev-eol (line-end-position))
          (has-nested nil))
      (goto-char prev-eol)
      (while (and (not has-nested)
                  (< (point) item-bol)
                  (zerop (forward-line 1))
                  (< (point) item-bol))
        (when (not (looking-at-p "^[ \t]*$"))
          (let* ((line-indent (if (looking-at "^\\([ \t]*\\)")
                                  (match-string 1) ""))
                 (line-indent-len (dm/org--indent-length line-indent)))
            (when (> line-indent-len indent-len)
              (setq has-nested t)))))
      has-nested)))

(defun dm/org-normalize-blank-lines ()
  "Normalize blank lines in org buffers.
Insert a blank line before a heading or list item only if the
previous sibling at the same level had nested content underneath it.
Remove blank lines between consecutive simple siblings.
Two-phase: collect edits first, apply bottom-to-top so positions stay valid."
  (interactive)
  (save-excursion
    ;; Phase 0: collapse runs of 3+ newlines to exactly 2
    (goto-char (point-min))
    (while (re-search-forward "\n\\{3,\\}" nil t)
      (replace-match "\n\n"))

    ;; Phase 1: collect all edit actions
    (let ((actions nil)
          (item-re "^\\([ \t]*\\)\\([-+]\\|[0-9]+[.)]\\|[a-zA-Z][.)]\\) "))

      ;; Headings
      (goto-char (point-min))
      (while (re-search-forward "^\\(\\*+\\) " nil t)
        (let* ((level (length (match-string 1)))
               (heading-bol (line-beginning-position))
               ;; Count blank lines before this heading
               (blanks 0)
               (pos heading-bol))
          (save-excursion
            (goto-char pos)
            (while (and (> pos (point-min))
                        (progn (forward-line -1)
                               (looking-at-p "^$")))
              (setq blanks (1+ blanks)
                    pos (point))))
          ;; Check what the previous non-blank line is
          (save-excursion
            (goto-char pos)
            (when (> pos (point-min))
              (forward-line -1)
              (cond
               ;; Previous non-blank line is a heading — no blank line wanted
               ((looking-at-p "^\\*+ ")
                (when (> blanks 0)
                  (push (list 'delete pos heading-bol blanks) actions)))
               ;; Otherwise check for same-level sibling with content
               (t
                (goto-char heading-bol)
                (when (re-search-backward (format "^\\*\\{%d\\} " level) nil t)
                  (let* ((prev-end (line-end-position))
                         (region (buffer-substring-no-properties prev-end heading-bol))
                         (has-content (string-match-p
                                       "^[^\n*]"
                                       (replace-regexp-in-string "\\`\n+" "" region))))
                    (if has-content
                        (when (= blanks 0)
                          (push (list 'insert heading-bol "\n") actions))
                      (when (> blanks 0)
                        (push (list 'delete pos heading-bol blanks) actions)))))))))))

      ;; List items
      (goto-char (point-min))
      (while (re-search-forward item-re nil t)
        (let* ((indent (match-string 1))
               (indent-len (dm/org--indent-length indent))
               (item-bol (line-beginning-position))
               (boundary (save-excursion
                           (goto-char item-bol)
                           (dm/org--heading-boundary)))
               (prev-pos (save-excursion
                           (goto-char item-bol)
                           (dm/org--find-prev-sibling-item indent-len boundary))))
          (when prev-pos
            (let* ((has-nested (dm/org--prev-sibling-has-nested
                                prev-pos item-bol indent-len))
                   ;; Count existing blank lines before this item
                   (blanks 0)
                   (pos item-bol))
              (save-excursion
                (goto-char pos)
                (while (and (> pos (point-min))
                            (progn (forward-line -1)
                                   (looking-at-p "^$")))
                  (setq blanks (1+ blanks)
                        pos (point))))
              (if has-nested
                  (when (= blanks 0)
                    (push (list 'insert item-bol "\n") actions))
                (when (> blanks 0)
                  (push (list 'delete pos item-bol blanks) actions)))))))

      ;; Phase 2: apply edits bottom-to-top so positions remain valid
      (setq actions (sort actions (lambda (a b) (> (cadr a) (cadr b)))))
      (dolist (act actions)
        (pcase (car act)
          ('insert
           (goto-char (cadr act))
           (insert (caddr act)))
          ('delete
           ;; Delete `n' blank lines: each is 1 char (the newline)
           (let ((start (cadr act))
                 (n (cadddr act)))
             (goto-char start)
             (delete-region start (+ start n)))))))))

(defun dm/org-normalize-blank-lines-deferred (&rest _)
  "Run blank line normalization after a short idle delay."
  (when (derived-mode-p 'org-mode)
    (run-with-idle-timer 0.1 nil #'dm/org-normalize-blank-lines)))

(advice-add 'org-insert-heading :after #'dm/org-normalize-blank-lines-deferred)
(advice-add 'org-insert-item :after #'dm/org-normalize-blank-lines-deferred)
(advice-add 'org-shiftmetaleft :after #'dm/org-normalize-blank-lines-deferred)
(advice-add 'org-shiftmetaright :after #'dm/org-normalize-blank-lines-deferred)
(advice-add 'org-metaleft :after #'dm/org-normalize-blank-lines-deferred)
(advice-add 'org-metaright :after #'dm/org-normalize-blank-lines-deferred)
(advice-add 'org-metareturn :after #'dm/org-normalize-blank-lines-deferred)
(advice-add 'org-promote-subtree :after #'dm/org-normalize-blank-lines-deferred)
(advice-add 'org-demote-subtree :after #'dm/org-normalize-blank-lines-deferred)
(advice-add 'org-promote :after #'dm/org-normalize-blank-lines-deferred)
(advice-add 'org-demote :after #'dm/org-normalize-blank-lines-deferred)

(add-hook 'before-save-hook
          (lambda ()
            (when (derived-mode-p 'org-mode)
              (dm/org-normalize-blank-lines))))

(after! org
  ;; (dolist (face '((org-level-1 . 1.2)
  ;;                 (org-level-2 . 1.1)
  ;;                 (org-level-3 . 1.05)
  ;;                 (org-level-4 . 1.0)
  ;;                 (org-level-5 . 1.1)
  ;;                 (org-level-6 . 1.1)
  ;;                 (org-level-7 . 1.1)
  ;;                 (org-level-8 . 1.1)))
  ;;   (set-face-attribute (car face) nil :font "Iosevka Aile" :weight 'bold :height (cdr face)))

  ;; ;; Make the document title a bit bigger
  ;; (set-face-attribute 'org-document-title nil :font "Iosevka Aile" :weight 'bold :height 1.8)

  ;; (require 'org-indent)
  ;; (set-face-attribute 'org-indent nil :inherit '(org-hide fixed-pitch))

  ;; (set-face-attribute 'org-block nil            :foreground nil :inherit
  ;;                     'fixed-pitch :height 0.85)
  ;; (set-face-attribute 'org-code nil             :inherit '(shadow fixed-pitch) :height 0.85)
  ;; (set-face-attribute 'org-indent nil           :inherit '(org-hide fixed-pitch) :height 0.85)
  ;; (set-face-attribute 'org-verbatim nil         :inherit '(shadow fixed-pitch) :height 0.85)
  ;; (set-face-attribute 'org-special-keyword nil  :inherit '(font-lock-comment-face fixed-pitch))
  ;; (set-face-attribute 'org-meta-line nil        :inherit '(font-lock-comment-face fixed-pitch))
  ;; (set-face-attribute 'org-checkbox nil         :inherit 'fixed-pitch)

  ;; (add-hook! 'org-mode-hook #'variable-pitch-mode)

  (setq org-ellipsis " ... "))
        ;; org-edit-src-content-indentation 0
        ;; org-tags-column -80))

(after! org
  (setq org-startup-with-inline-images t
        ;; org-image-actual-width 400
        imagemagick-enabled-types t)
  (imagemagick-register-types)
  (add-to-list 'image-file-name-extensions "eps"))

(after! org
  (defun org--create-inline-image-advice (img)
    (nconc img (list :background "#fafafa")))
  (advice-add 'org--create-inline-image
              :filter-return #'org--create-inline-image-advice))

(after! org
  (setq org-babel-default-header-args:jupyter-python '((:async . "yes")
                                                       (:session . "py")))
  (org-babel-do-load-languages 'org-babel-load-languages '((emacs-lisp)
                                                           (bash . t)
                                                           (julia . t)
                                                           (python . t))))

(map! :map org-mode-map
      :after org
      :localleader
      :prefix ("j"" . "jupyter)
      :desc "Execute and next block" "b" #'jupyter-org-execute-and-next-block
      :desc "Clone block" "c" #'jupyter-org-clone-block
      :desc "Copy block and results" "C" #'jupyter-org-copy-block-and-results
      :desc "Go to error" "e" #'jupyter-org-goto-error
      :desc "Edit header" "h" #'jupyter-org-edit-header
      :desc "Interrupt kernel" "i" #'jupyter-org-interrupt-kernel
      :desc "Jump to block" "j" #'jupyter-org-jump-to-block
      :desc "Move block" "m" #'jupyter-org-move-src-block
      :desc "Merge blocks" "M" #'jupyter-org-merge-blocks
      :desc "Next busy block" "n" #'jupyter-org-next-busy-src-block
      :desc "Previous busy block" "N" #'jupyter-org-previous-busy-src-block
      :desc "Execute to point" "p" #'jupyter-org-execute-to-point
      :desc "Restart to point" "r" #'jupyter-org-restart-kernel-and-execute-to-point
      :desc "Restart execute buffer" "R" #'jupyter-org-restart-kernel-execute-buffer
      :desc "Split block" "s" #'jupyter-org-split-src-block)

(after! org
  (add-to-list 'warning-suppress-types '(org-element org-element-parser)))

(after! org
  (setq org-startup-with-latex-preview t)
  (add-hook! 'org-mode-hook #'turn-on-org-cdlatex)

  (defadvice! org-edit-latex-emv-after-insert ()
    :after #' org-cdlatex-environment-indent
    (org-edit-latex-environment)))

(use-package! engrave-faces-latex
  :after ox-latex
  :config
  (setq org-latex-listings 'engraved
        org-latex-engraved-theme 'doom-one))

;; (org-export-update-features 'latex
;;                             (no-protrusion-in-code
;;                              :condition t
;;                              :when (microtype engraved-code)
;;                              :snippet "\\ifcsname Code\\endcsname\n  \\let\\oldcode\\Code\\renewcommand{\\Code}{\\microtypesetup{protrusion=false}\\oldcode}\n\\fi"
;;                              :after (engraved-code microtype)))

;; (defadvice! org-latex-example-block-engraved (orig-fn example-block contents info)
;;   "Like `org-latex-example-block', but supporting an engraved backend"
;;   :around #'org-latex-example-block
;;   (let ((output-block (funcall orig-fn example-block contents info)))
;;     (if (eq 'engraved (plist-get info :latex-listings))
;;         (format "\\begin{Code}[alt]\n%s\n\\end{Code}" output-block)
;;       output-block)))

(after! org
    (setq org-latex-src-block-backend 'engraved))
    ;; (setq org-latex-engraved-options))
    ;; (setq org-latex-engraved-preamble))

 ;; (setq org-latex-src-block-backend 'listings)
 ;; (require 'ox-latex)
 ;; (add-to-list 'org-latex-packages-alist '("" "listings"))
 ;; (add-to-list 'org-latex-packages-alist '("" "color")))

(after! org
  (setq org-highlight-latex-and-related '(native script entities))
  (add-to-list 'org-src-block-faces '("latex" (:inherit default :extend t))))

(after! org-beamer-mode
  (setq org-beamer-theme "[progressbar=foot]Warwick"))

(after! org
  (setq org-hide-emphasis-markers t))

(after! org
  (setq org-modern-list '((45 . "–") (43 . "➤") (42 . "•"))
        ;; org-modern-block-name '("▶ " . "▶ ")
        ;; org-modern-block-name '(" " . " ")
        org-modern-checkbox nil ;'((88 . "[x]") (45 . "[-]") . (32 . "[ ]"))
        org-modern-fold-stars '(("◉" . "◉") ("○" . "○") ("✸" . "✸") ("✿" . "✿") ("▶" . "▼") ("▷" . "▽") ("⯈" . "⯆") ("▹" . "▿") ("▸" . "▾"))
        org-modern-hide-stars nil
        org-modern-table nil
        ;; org-modern-priority (quote ((?A . "❗") (?B . "⬆") (?C . "⬇")))
        org-modern-keyword "▶ "))

;; (after! org
;;   (setq org-adapt-indentation t))

(use-package! org-modern-indent
  :after org
  :hook (org-mode . org-modern-indent-mode))

(after! org
  (setq org-pretty-entities t))

(after! org-roam
  (setq org-roam-directory "~/Documents/org/roaming/"
        org-roam-completion-everywhere t
        org-roam-db-location "~/Documents/org/roaming/org-roam.db"
        org-roam-db-autosync-mode t
        org-roam-capture-templates
        '(("d" "default" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n")
           :unnarrowed t)
          ("p" "personal" plain "%?"
           :target (file+head "personal/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n")
           :unnarrowed t)
          ("r" "research" plain "%?"
           :target (file+head "research/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n")
           :unnarrowed t)
          ("t" "tech" plain "%?"
           :target (file+head "tech/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n")
           :unnarrowed t)
          ("w" "work" plain "%?"
           :target (file+head "work/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n")
           :unnarrowed t))))

(map! :leader
      :prefix "n"
      :desc  "Extract subtree" "r x" #'org-roam-extract-subtree)

;; (after! org-roam
;;   (setq org-roam-mode-sections
;;         (list #'org-roam-backlinks-section
;;               #'org-roam-reflinks-section
;;               #'org-roam-unlinked-references-section))
;;   (add-hook 'org-roam-mode-hook #'org-roam-setup))

;; ;; Automatically open the side-window for Org-roam files
;; (add-hook 'org-roam-find-file-hook #'org-roam-buffer-toggle)

(use-package! websocket
  :after org-roam)

(use-package! org-roam-ui
  :after org-roam
  ;; normally we'd recommend hooking orui after org-roam, but since org-roam does not have
  ;; a hookable mode anymore, you're advised to pick something yourself
  ;; if you don't care about startup time, use
  ;; :hook (after-init . org-roam-ui-mode)
  ;; :init (setq org-roam-ui-browser-function #'xwidget-webkit-browse-url)
  ;; :hook (org-roam-mode . org-roam-ui-mode)
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t
        org-roam-ui-browser-function #'xwidget-webkit-browse-url))

(after! org
  (setf (alist-get "python" org-src-lang-modes nil nil #'equal) 'python-ts)
  (add-to-list 'org-src-lang-modes '("shell" . sh))
  (add-to-list 'org-src-lang-modes '("julia" . julia-ts))
  (setf (alist-get "json" org-src-lang-modes nil nil #'equal) 'js-json)
  (add-to-list 'org-src-lang-modes '("http" . restclient))

  (defun org-babel-execute:json (body _params)
    "Return the JSON body as-is (no execution)."
    body))

(map! :map org-mode-map
      :after org
      :localleader
      "'" nil
      "`" #'org-edit-special)

(after! org
  (setq org-log-done 'time)
  (setq org-closed-keep-when-no-todo t))

(defun org-todo-if-needed (state)
  "Change header state to STATE unless the current item is in STATE already."
  (unless (string-equal (org-get-todo-state) state)
    (org-todo state)))

(defun ct/org-summary-todo-cookie (n-done n-not-done)
  "Switch header state to DONE when all subentries are DONE, to TODO when none are DONE, and to STRT otherwise"
  (let (org-log-done org-log-states)   ; turn off logging
    (org-todo-if-needed (cond ((= n-done 0)
                               "TODO")
                              ((= n-not-done 0)
                               "DONE")
                              (t
                               "STRT")))))

(add-hook 'org-after-todo-statistics-hook #'ct/org-summary-todo-cookie)

(defun ct/org-summary-checkbox-cookie ()
  "Switch header state to DONE when all checkboxes are ticked, to TODO when none are ticked, and to STRT otherwise"
  (let (beg end)
    (unless (not (org-get-todo-state))
      (save-excursion
        (org-back-to-heading t)
        (setq beg (point))
        (end-of-line)
        (setq end (point))
        (goto-char beg)
        ;; Regex group 1: %-based cookie
        ;; Regex group 2 and 3: x/y cookie
        (if (re-search-forward "\\[\\([0-9]*%\\)\\]\\|\\[\\([0-9]*\\)/\\([0-9]*\\)\\]"
                               end t)
            (if (match-end 1)
                ;; [xx%] cookie support
                (cond ((equal (match-string 1) "100%")
                       (org-todo-if-needed "DONE"))
                      ((equal (match-string 1) "0%")
                       (org-todo-if-needed "TODO"))
                      (t
                       (org-todo-if-needed "STRT")))
              ;; [x/y] cookie support
              (if (> (match-end 2) (match-beginning 2)) ; = if not empty
                  (cond ((equal (match-string 2) (match-string 3))
                         (org-todo-if-needed "DONE"))
                        ((or (equal (string-trim (match-string 2)) "")
                             (equal (match-string 2) "0"))
                         (org-todo-if-needed "TODO"))
                        (t
                         (org-todo-if-needed "STRT")))
                (org-todo-if-needed "STRT"))))))))

(add-hook 'org-checkbox-statistics-hook #'ct/org-summary-checkbox-cookie)

;; (defun custom-vterm-popup ()
;;   (if (window-dedicated-p nil)
;;       (message "yep")
;;     (message "nope")))

;; (map! :leader
;;       :desc "Custom vterm popup" "o t" #'custom-vterm-popup)

(use-package! vterm
  :after vterm
  :config
  (setq vterm-kill-buffer-on-exit t
        vterm-always-compile-module t
        vterm-ignore-blink-cursor nil))

(use-package! eshell-syntax-highlighting
  :after esh-mode
  :config
  (eshell-syntax-highlighting-global-mode t)
  (setq eshell-rc-script (concat user-emacs-directory "eshell/profile")
        eshell-aliases-file (concat user-emacs-directory "eshell/aliases")
        eshell-history-size 5000
        eshell-buffer-maximum-lines 5000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t
        eshell-destroy-buffer-when-process-dies t
        eshell-visual-commands'("fish" "htop" "ssh" "top" "zsh")))

;; (set-eshell-alias! "ls" "lsd")

(after! eshell
  (setq eshell-destroy-buffer-when-process-dies t))

;; (when (and (executable-find "fish")
;;            (require 'fish-completion nil t))
;;   (global-fish-completion-mode))

;; (defun with-face (str &rest face-plist)
;;    (propertize str 'face face-plist))

;;  (defun shk-eshell-prompt ()
;;    (let ((header-bg "#fff"))
;;      (concat
;;       (with-face (concat (eshell/pwd) " ") :background header-bg)
;;       (with-face (format-time-string "(%Y-%m-%d %H:%M) " (current-time)) :background header-bg :foreground "#888")
;;       (with-face
;;        (or (ignore-errors (format "(%s)" (vc-responsible-backend default-directory))) "")
;;        :background header-bg)
;;       (with-face "\n" :background header-bg)
;;       (with-face user-login-name :foreground "blue")
;;       "@"
;;       (with-face "localhost" :foreground "green")
;;       (if (= (user-uid) 0)
;;           (with-face " #" :foreground "red")
;;         " $")
;;       " ")))
;;  (setq eshell-prompt-function 'shk-eshell-prompt)
;;  (setq eshell-highlight-prompt nil)
