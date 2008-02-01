$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')

ENV['RAILS_ENV'] = 'test'

require 'test/unit'

require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))

module ActsAsCached
  module ClassMethods
    def get_cache
      yield if block_given?
    end
    def set_cache
    end
  end
end

class TestClass < ActiveResource::Base
  cached_resource
end

class CachedResourceTest < Test::Unit::TestCase

  def test_load
    assert TestClass.respond_to?(:cached_resource, "should respond to cached_resource")
    assert TestClass.respond_to?(:find_with_cache, "should respond to find_with_cache")
    assert TestClass.respond_to?(:find_without_cache, "should respond to find_without_cache")
  end

end
