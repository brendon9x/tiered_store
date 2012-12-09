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
            [:file_store, File.expand_path(File.dirname(__FILE__) + "/../../../tmp")]
          ]
          store.caches.first.should be_a ActiveSupport::Cache::FileStore
        end

        it "can take stores that take arguments" do
          store = ActiveSupport::Cache.lookup_store :tiered_store, :caches => [
            [:file_store, File.expand_path(File.dirname(__FILE__) + "/../../../tmp")],
            :memory_store
          ]
          store.caches.first.should be_a ActiveSupport::Cache::FileStore
          store.caches[1].should be_a ActiveSupport::Cache::MemoryStore
        end
      end

      describe :caching do
        before :each do
          @underlying = double()
          @store = ActiveSupport::Cache::TieredStore.new(:caches => @underlying)
        end

        it "should delegate reads" do
          @underlying.should_receive(:read).with(:key, :opts).and_return("foo")
          @store.read(:key, :opts).should == "foo"
        end

        it "should return nil if no delegate caches hit" do
          @underlying.should_receive(:read).with(:key, :opts).and_return(nil)
          @store.read(:key, :opts).should be_nil
        end

        it "should delegate writes" do
          @underlying.should_receive(:write).with(:key, :value, :opts)
          @store.write(:key, :value, :opts)
        end

        it "should delegate deletes" do
          @underlying.should_receive(:delete).with(:key, :opts)
          @store.delete(:key, :opts)
        end

        it "should delegate delete_matched" do
          @underlying.should_receive(:delete_matched).with(:key, :opts)
          @store.delete_matched(:key, :opts)
        end

        it "should delegate clear" do
          @underlying.should_receive(:clear)
          @store.clear
        end

        it "should not delegate clear to caches without clear" do
          @underlying.should_receive(:respond_to?).with(:clear).and_return(false)
          @underlying.should_not_receive(:clear)
          @store.clear
        end
      end
    end
  end
end