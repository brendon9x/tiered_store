# TieredStore

TieredStore is an ActiveSupport Rails cache store which creates multiple cache stores, the intention being
that faster, smaller memory caches can be layered on top of slow more persistent caches.  Currently, Rails 2.x
only.

## Installation

Add this line to your application's Gemfile:

    gem 'tiered_store'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tiered_store

## Usage

For example, to create a memory cache on top a mem_cache store, add this to your environment.rb:

    config.cache_store = :tiered_store, [
      :memory,
      [:mem_cache, "localhost:11011"]
    ]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
