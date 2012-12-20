require 'active_support'

module ActiveSupport
  module Cache
    class TieredStore < Store
      VERSION = "0.0.2"

      attr_reader :caches

      # Returns a tiered cache store.  Create caches in order of speed and in reverse order of size.  For example, you
      # create first a memory_cache, then a larger mem_cache store.  Cache will write through all caches and reads will
      # fall back in order of definition.
      #
      # e.g.
      #
      # config.cache_store = :tiered_store, [
      #   :memory,
      #   [:mem_cache, "localhost:11011"]
      # ]
      def initialize(options)
        super
        raise ArgumentError, "requires options to contain[:caches]" unless options && options[:caches]
        @caches = Array(options[:caches]).map do |descriptor|
          ActiveSupport::Cache.lookup_store(descriptor)
        end
      end

      # Inserts the value into the cache collection or updates the existing value.
      def write(key, value, options=nil)
        @caches.each { |c| c.write(key, value, options) }
      end

      # Reads the value from the cache collection.
      def read(key, options=nil)
        @caches.each { |c| if (found = c.read(key, options)) then return found end } and return nil
      end

      # Takes the specified value out of the collection.
      def delete(key, options=nil)
        @caches.each { |c| c.delete(key, options) }
      end

      # Takes the value matching the pattern out of the collection.
      def delete_matched(key, options=nil)
        @caches.each { |c| c.delete_matched(key, options) }
      end

      # Wipes the whole cache.
      def clear
        @caches.each { |c| c.clear if c.respond_to? :clear }
      end
    end
  end
end