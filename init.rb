
# check to see if cache_fu is loaded
puts "=> cached_resource requires cache_fu! >> http://svn.latimesdev.com/repos/shared/ruby/plugins/cache_fu/" unless Object.const_defined?(:ActsAsCached)

ActiveResource::Base.send :include, CachedResource
