# ActsAsCachedResource

module CachedResource
    
  def self.included(receiver)
    receiver.extend(ClassMethods)
  end

  module ClassMethods
    
    def cached_resource

      class << self
        def find_with_cache(*arguments)
          scope                         = arguments.slice!(0)
          options                       = arguments.slice!(0) || {}
          case scope
          when :all   then cached_find_every(options)
          when :first then cached_find_every(options).first
            # when :one   then cached_find_one(options)
          else             cached_find_single(scope)
          end
        end

        def cached_find_every(options)
          prefix_options, query_options = split_options(options[:params])
          path                          = collection_path(prefix_options, query_options)
          url                           = get_cache(path) do
            elements                    = find_without_cache(:all,:params=>query_options)
            output                      = []
            elements.each do |element|
              set_cache(element.id, element) unless fetch_cache(element.id)
              output << element.id
            end
            output.join(',')
          end
          url.split(',').collect{|photo| get_cache(photo)}
        end

        def cached_find_single(scope)
          get_cache(scope) do
            self.find_without_cache(scope)
          end
        end

        alias_method_chain :find, :cache

      end

    end
  end
end
