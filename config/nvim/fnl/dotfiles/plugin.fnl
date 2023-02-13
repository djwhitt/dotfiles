(module dotfiles.plugin
  {autoload {nvim aniseed.nvim
             a aniseed.core
             util dotfiles.util
             packer packer}})

(defn safe-require-plugin-config [name]
  (let [(ok? val-or-err) (pcall require (.. :dotfiles.plugin. name))]
    (when (not ok?)
      (print (.. "dotfiles error: " val-or-err)))))

(defn- use [...]
  "Iterates through the arguments as pairs and calls packer's use function for
  each of them. Works around Fennel not liking mixed associative and sequential
  tables as well."
  (let [pkgs [...]]
    (packer.startup
      (fn [use]
        (for [i 1 (a.count pkgs) 2]
          (let [name (. pkgs i)
                opts (. pkgs (+ i 1))]
            (-?> (. opts :mod) (safe-require-plugin-config))
            (use (a.assoc opts 1 name))))))
    nil))

;; Plugins to be managed by packer.
(use
  ; "~/repos/Olical/conjure" {:mod :conjure}
  ; "~/repos/Olical/aniseed" {}
  ; "~/repos/Olical/nvim-local-fennel" {}

  :LnL7/vim-nix {}
  :Olical/AnsiEsc {}
  :Olical/aniseed {}
  :Olical/conjure {}
  ; :Olical/nvim-local-fennel {}
  ; :Olical/vim-enmasse {}
  ; :PeterRincker/vim-argumentative {}
  :PaterJason/cmp-conjure {}
  :airblade/vim-rooter {}
  :clojure-vim/clojure.vim {:mod :clojure}
  :clojure-vim/vim-jack-in {}
  :dag/vim-fish {}
  :editorconfig/editorconfig-vim {:mod :editorconfig}
  :ggandor/leap.nvim {:mod :leap}
  :github/copilot.vim {:mod :copilot}
  ; :glepnir/lspsaga.nvim {:mod :lspsaga}
  :google/vim-jsonnet {}
  :guns/vim-sexp {:mod :sexp}
  :hashivim/vim-terraform {}
  :hoob3rt/lualine.nvim {:mod :lualine}
  :hrsh7th/nvim-cmp {:mod :cmp
                     :requires
                     [[:hrsh7th/cmp-buffer]
                      [:hrsh7th/cmp-cmdline]
                      [:hrsh7th/cmp-nvim-lsp]
                      [:hrsh7th/cmp-path]
                      [:ray-x/cmp-treesitter]]}
  :jackMort/ChatGPT.nvim {:mod :chatgpt
                          :requires
                          [[:MunifTanjim/nui.nvim]
                           [:nvim-lua/plenary.nvim]
                           [:nvim-telescope/telescope.nvim]]}
  :jose-elias-alvarez/null-ls.nvim {:mod :null-ls}
  :jose-elias-alvarez/nvim-lsp-ts-utils {}
  ; :jiangmiao/auto-pairs {:mod :auto-pairs}
  :jparise/vim-graphql {}
  ; :kyazdani42/nvim-tree.lua {:mod :nvimtree}
  :kchmck/vim-coffee-script {}
  ; :lambdalisue/suda.vim {}
  :lewis6991/gitsigns.nvim {:mod :gitsigns}
  ; :liuchengxu/vim-better-default {:mod :better-default}
  :marko-cerovac/material.nvim {:mod :material :commit "901dae9cc3a0afafb6b86fabd2a10235d5865f2f"}
  :mhinz/vim-startify {}
  ; :mbbill/undotree {:mod :undotree}
  :neovim/nvim-lspconfig {:mod :lspconfig}
  ; :norcalli/nvim-colorizer.lua {:mod :colorizer}
  :nvim-telescope/telescope.nvim {:requires
                                  [[:nvim-lua/popup.nvim]
                                   [:nvim-lua/plenary.nvim]
                                   [:nvim-telescope/telescope-project.nvim]
                                   [:nvim-telescope/telescope-file-browser.nvim]]
                                  :mod :telescope}
  :nvim-treesitter/nvim-treesitter {:run ":TSUpdate" :mod :treesitter}
  :pangloss/vim-javascript {}
  :prettier/vim-prettier {:ft :javascript}
  :radenling/vim-dispatch-neovim {}
  :ray-x/go.nvim {}
  ; :tpope/vim-abolish {}
  :tpope/vim-commentary {}
  ; :tpope/vim-dadbod {}
  :tpope/vim-dispatch {}
  ; :tpope/vim-eunuch {}
  :tpope/vim-fugitive {:mod :fugitive}
  :tpope/vim-projectionist {}
  ; :tpope/vim-repeat {}
  :tpope/vim-sexp-mappings-for-regular-people {}
  :tpope/vim-sleuth {}
  ; :tpope/vim-surround {}
  ; :tpope/vim-unimpaired {}
  :tpope/vim-vinegar {}
  ; :tweekmonster/startuptime.vim {}
  :wakatime/vim-wakatime {}
  :wbthomason/packer.nvim {})
