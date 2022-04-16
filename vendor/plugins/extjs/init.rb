# Check for installed asset_packager plugin and use it for JS including if installed
::ASSET_PACKAGER_INSTALLED = (!!(defined?(Synthesis::AssetPackageHelper))).freeze

require 'acts_as_grid'
require 'grid_helper'
require 'grid'

require 'form_builder'
require 'form_helper'

ActiveRecord::Base.send     :include, Acts::ExtJS::Grid
ActionView::Base.send       :include, ExtJS::GridHelper
ActionController::Base.send :include, ExtJS::Grid
