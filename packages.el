;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; To install a package with Doom you must declare them here and run 'doom sync'
;; on the command line, then restart Emacs for the changes to take effect -- or
;; use 'M-x doom/reload'.


;; To install SOME-PACKAGE from MELPA, ELPA or emacsmirror:
;; (package! some-package)

;; To install a package directly from a remote git repo, you must specify a
;; `:recipe'. You'll find documentation on what `:recipe' accepts here:
;; https://github.com/radian-software/straight.el#the-recipe-format
;; (package! another-package
;;   :recipe (:host github :repo "username/repo"))

;; If the package you are trying to install does not contain a PACKAGENAME.el
;; file, or is located in a subdirectory of the repo, you'll need to specify
;; `:files' in the `:recipe':
;; (package! this-package
;;   :recipe (:host github :repo "username/repo"
;;            :files ("some-file.el" "src/lisp/*.el")))

;; If you'd like to disable a package included with Doom, you can do so here
;; with the `:disable' property:
;; (package! builtin-package :disable t)

;; You can override the recipe of a built in package without having to specify
;; all the properties for `:recipe'. These will inherit the rest of its recipe
;; from Doom or MELPA/ELPA/Emacsmirror:
;; (package! builtin-package :recipe (:nonrecursive t))
;; (package! builtin-package-2 :recipe (:repo "myfork/package"))

;; Specify a `:branch' to install a package from a particular branch or tag.
;; This is required for some packages whose default branch isn't 'master' (which
;; our package manager can't deal with; see radian-software/straight.el#279)
;; (package! builtin-package :recipe (:branch "develop"))

;; Use `:pin' to specify a particular commit to install.
;; (package! builtin-package :pin "1a2b3c4d5e")


;; Doom's packages are pinned to a specific commit and updated from release to
;; release. The `unpin!' macro allows you to unpin single packages...
;; (unpin! pinned-package)
;; ...or multiple packages
;; (unpin! pinned-package another-pinned-package)
;; ...Or *all* packages (NOT RECOMMENDED; will likely break things)
;; (unpin! t)

(package! atomic-chrome)
(package! auctex)
(package! catppuccin-theme)
;; (package! chatgpt-shell
;;   :recipe (:host github :repo "xenodium/chatgpt-shell" :files ("chatgpt-shell*.el")))
(package! circadian
  :recipe (:host github :repo "guidoschmidt/circadian.el"))
;; (package! company-org-block)
(package! copilot
  :recipe (:host github :repo "copilot-emacs/copilot.el" :files ("*.el")))
(package! copilot-chat
  :recipe (:host github :repo "chep/copilot-chat.el" :files ("*.el")))
;; (package! emacsql :pin "491105a")
;; (package! eat)
(package! engrave-faces)
;; (package! flycheck-languagetool)
;; (package! fortpy)
(package! impatient-mode)
(package! indent-bars)
(package! jinx)
;; (package! julia-formatter
;;   :recipe (:host codeberg :repo "FelipeLema/julia-formatter.el"
;;            :files ( "julia-formatter.el" ;; main script executed by Emacs
;;                     "toml-respects-json.el" ;; script to parse format config toml files
;;                     "formatter_service.jl" ;; script executed by Julia
;;                     "Manifest.toml" "Project.toml"))) ;; project files
(package! languagetool)
(package! live-py-mode)
;; (package! lsp-ltex-plus
;;   :recipe (:host github :repo "emacs-languagetool/lsp-ltex-plus"))
;; (package! lsp-ltex
;;   :recipe (:host github :repo "emacs-languagetool/lsp-ltex"))
;; (package! lsp-julia)
;; (package! moom)
(package! nov)
(package! no-xwidget
  :recipe (:host github :repo "chenyanming/nov-xwidget"))
(package! numpydoc)
(package! obsidian)
(package! org-ai)
(package! org-cite-csl-activate
  :recipe (:host github :repo "andras-simonyi/org-cite-csl-activate"))
;; (package! org-edit-latex)
(package! org-fragtog)
(package! org-modern-indent
  :recipe (:host github :repo "jdtsmith/org-modern-indent"))
(package! orgnote
  :recipe (:host github :repo "artawower/orgnote.el"))
(package! org-pandoc-import
  :recipe (:host github
           :repo "tecosaur/org-pandoc-import"
           :files ("*.el" "filters" "preprocessors")))
(package! org-present)
(unpin! org-roam)
(package! org-roam-ui)
(package! org-special-block-extras)
(package! org-super-agenda)
(package! ox-gfm)
(package! ox-pluto
  :recipe (:host github
           :repo "tecosaur/ox-pluto"))
(package! poetry)
(package! pov-mode)
(package! rainbow-delimiters)
(package! screenshot
  :recipe (:host github
           :repo "tecosaur/screenshot"))
(package! shell-maker
  :recipe (:host github :repo "xenodium/shell-maker" :files ("shell-maker*.el")))
(package! synosaurus)
(package! systemd)
(package! uv-mode
  :recipe (:host github :repo "z80dev/uv-mode" :files ("*.el")))
(package! vterm-toggle)
(package! zotra)
