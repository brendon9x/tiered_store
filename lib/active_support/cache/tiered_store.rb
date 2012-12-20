require 'active_support'

module ActiveSupport
  module Cache
    class TieredStore < Store

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

      def silence!
        @caches.each &:silence!
        self
      end

      def fetch(name, options = nil)
        (read(name, options) || (yield if block_given?)).tap do |result|
          @caches.each { |c| c.write(name, result, options) } if result
        end
      end

      def read(name, options = nil)
        @caches.detect do |c|
          result = c.read(name, options)
          return result if result
        end
      end

      def read_multi(*names)
        @caches.detect do |c|
          result = c.read_multi(*names)
          return result if result
        end
      end

      def write(name, value, options = nil)
        @caches.map { |c| c.write(name, value, options) }.last
      end

      def delete(name, options = nil)
        @caches.map { |c| c.delete(name, options) }.last
      end

      def exist?(name, options = nil)
        @caches.any? { |c| c.exist?(name, options) }.present?
      end

      def delete_matched(matcher, options = nil)
        @caches.map { |c| c.delete_matched(matcher, options) }.last
      end

      def increment(name, amount = 1, options = nil)
        @caches.map { |c| c.increment(name, amount, options) }.last
      end

      def decrement(name, amount = 1, options = nil)
        @caches.map { |c| c.decrement(name, amount, options) }.last
      end

      def cleanup(options = nil)
        @caches.map { |c| c.cleanup(options) }.last
      end

      def clear(options = nil)
        @caches.map { |c| c.clear(options) }.last
      end

    end
  end
end