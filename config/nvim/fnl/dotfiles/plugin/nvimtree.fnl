(module dotfiles.plugin.nvimtree
  {autoload {nvim aniseed.nvim}})

(set nvim.g.nvim_tree_show_icons
     {:git 1
      :folders 0
      :file 0
      :folder_arrows 0})

(set nvim.g.nvim_tree_quit_on_open 1)

(let [nvim-tree (require :nvim-tree)]
  (nvim-tree.setup
    {:disable_netrw false
     :hijack_netrw false
     ;:auto_close true
     ;:open_on_setup true
     :update_to_buf_dir {:enable true}}))

