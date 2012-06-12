require "tiered_store/version"

module ActiveSupport
  module Cache
    autoload :TieredStore, 'active_support/cache/tiered_store'
  end
end
