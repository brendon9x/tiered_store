require "tiered_store/version"
require 'active_support'

module ActiveSupport
  module Cache
    autoload :TieredStore, 'active_support/cache/tiered_store'
  end
end
