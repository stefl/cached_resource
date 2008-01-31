module CachedResource

  def self.included(receiver)
    receiver.extend(ClassMethods)
  end

  module ClassMethods

    def cached_resource(options = {})

      acts_as_cached(options)

      class << self

        def find_with_cache(*arguments)
          scope = arguments.slice!(0)
          options = arguments.slice!(0) || {}
          case scope
          when :all   then cached_find_every(options)
          when :first then cached_find_every(options).first
          # TODO should this actually cache something?
          # when :one   then cached_find_one(options)
          when :one   then find_without_cache(arguments)
          else             cached_find_single(scope)
          end
        end

        def cached_find_every(options)
          prefix_options, query_options = split_options(options[:params])
          path_as_key = collection_path(prefix_options, query_options)
          response_elements = nil
          cached_id_array = get_cache(path_as_key) do
            response_elements = find_without_cache(:all,:params=>query_options)
            response_elements.collect do |cached_element|
              #logger.debug "====================================================="
              #logger.debug "This cached by cached_resource plugin"
              #logger.debug "key    : #{cached_element.id}"
              #logger.debug "value  : #{cached_element}"
              #logger.debug "====================================================="
              set_cache(cached_element.id,cached_element,self.cache_config[:ttl]) 
              cached_element.id
            end  
          end
          #logger.debug "====================================================="
          #logger.debug "This cached by cached_resource plugin"
          #logger.debug "key    : #{path_as_key}"
          #logger.debug "value  : [#{cached_id_array.join(',')}]"
          #logger.debug "====================================================="
          response_elements || get_cache(cached_id_array).values
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
