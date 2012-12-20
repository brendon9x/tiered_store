require 'active_support/cache/tiered_store'

module ActiveSupport
  module Cache
    describe TieredStore do
      describe :initialize do

        it "can take a symbol" do
          store = ActiveSupport::Cache.lookup_store :tiered_store, :caches => :memory_store
          store.caches.first.should be_a ActiveSupport::Cache::MemoryStore
        end

        it "can take many symbols" do
          store = ActiveSupport::Cache.lookup_store :tiered_store, :caches => [:memory_store, :memory_store]
          store.caches[0].should be_a ActiveSupport::Cache::MemoryStore
          store.caches[1].should be_a ActiveSupport::Cache::MemoryStore
        end

        it "can take stores that take arguments" do
          store = ActiveSupport::Cache.lookup_store :tiered_store, :caches => [
            [:memory_store, size: 64.megabytes]
          ]
          store.caches.first.should be_a ActiveSupport::Cache::MemoryStore
        end

        it "can take a mix of arguments" do
          store = ActiveSupport::Cache.lookup_store :tiered_store, :caches => [
            [:memory_store, size: 12.megabytes],
            :memory_store
          ]
          store.caches.first.should be_a ActiveSupport::Cache::MemoryStore
          store.caches[1].should be_a ActiveSupport::Cache::MemoryStore
        end
      end

      describe :caching do
        before :each do
          @a = ActiveSupport::Cache::MemoryStore.new({})
          @b = ActiveSupport::Cache::MemoryStore.new({})
          @store = ActiveSupport::Cache::TieredStore.new(:caches => [@a, @b])
        end

        it "should delegate reads" do
          @a.write(:key, "foo")
          @store.read(:key).should == "foo"
        end

        it "should delegate reads and keep going if first cache misses" do
          @b.write(:key, "foo")
          @store.read(:key).should == "foo"
        end

        it "should return nil if no delegate caches hit" do
          @store.read(:key).should be_nil
        end

        it "should delegate writes" do
          @store.write(:key, "value")
          @a.read(:key).should == "value"
          @b.read(:key).should == "value"
        end

        it "should delegate deletes" do
          @a.write(:key, "value")
          @store.delete(:key)
          @a.read(:key).should be_nil
        end

        it "should delegate clear" do
          @a.write(:key, "value")
          @store.clear
          @a.read(:key).should be_nil
        end

      end
    end
  end
end