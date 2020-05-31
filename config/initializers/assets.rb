# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += %w( home.js lucene.js lucene.css)


Rails.application.config.assets.precompile += %w( 
  ztree-custom.css
  ztree/ztree.min.css
  ztree/ztree.min.js
  home.css

  dashboards.css
  dashboards.js

  data_centers.css
  data_centers.js

  bootstrap-datepicker/bootstrap-datepicker3.standalone.css
  bootstrap-datepicker/bootstrap-datepicker.min.js
  bootstrap-datepicker-init.js

  echarts/echarts.min.js
)
