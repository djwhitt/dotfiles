(module dotfiles.plugin.material
  {autoload {nvim aniseed.nvim
             material material}})

(material.setup
  {:borders true
   :text_contrast {:darker true}
   :plugin ["lspsaga" "nvim-cmp" "telescope"]})

(set nvim.g.material_style :darker)
(nvim.ex.colorscheme :material)
