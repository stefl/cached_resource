module CachedResource

  def self.included(receiver)
    receiver.extend(ClassMethods)
  end

  module ClassMethods

    def cached_resource(options = {})

      acts_as_cached(options)

      class << self

        def find_with_cache(*arguments)
          scope = arguments[0]
          case scope
          when :all   then cached_find_every(arguments)
          when :first then cached_find_every(arguments).first
          # TODO should this actually cache something?
          # when :one   then cached_find_one(options)
          when :one   then find_without_cache(*arguments)
          else             cached_find_single(arguments)
          end
        end

        def cached_find_every(arguments)
          options = arguments[1] || {}
          prefix_options, query_options = split_options(options[:params])
          # TODO: handle :from with Symbols
          path_as_key = options[:from].nil? ?
                          collection_path(prefix_options, query_options) :
                          "#{options[:from]}#{query_string(options[:params])}"
          response_elements = nil
          cached_id_array = get_cache(path_as_key) do
            response_elements = find_without_cache(*arguments)
            response_elements.collect do |cached_element|
              set_cache(cached_element.id, cached_element, self.cache_config[:ttl]) 
              cached_element.id
            end  
          end

          response_elements || cached_id_array.map { |key| cached_find_single(key) }
        end

        def cached_find_single(arguments)
          scope = arguments[0]
          get_cache(scope) do
            self.find_without_cache(*arguments)
          end
        end

        alias_method_chain :find, :cache

      end
    end
  end
end
