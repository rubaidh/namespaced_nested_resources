module Rubaidh
  module NamespacedNestedResources
    # Make sure that the singleton resource is consistently singularized
    # and pluralized in the right places by still storing the plural
    # separately and explicitly overriding path to use the singular.
    module SingletonResource
      def self.included(base)
        base.send :include, InstanceMethods
      end
      
      module InstanceMethods
        def initialize(entity, options)
          @singular = entity
          @plural   = singular.to_s.pluralize

          options[:controller] ||= plural
          super
        end
        
        def path
          @path ||= "#{path_prefix}/#{singular}"
        end
      end
    end
    
    module Resources
      def self.included(base)
        base.send :include, InstanceMethods
      end
      
      # FIXME: Find a better way of overriding +map_resource+ and 
      # +map_singleton_resource+ than just copy and paste.  Perhaps calling
      # and the block it yields overriding some of the options?  I dunno.
      module InstanceMethods
        private
        def map_resource(entities, options = {}, &block)
          resource = ActionController::Resources::Resource.new(entities, options)

          with_options :controller => resource.controller do |map|
            map_collection_actions(map, resource)
            map_default_collection_actions(map, resource)
            map_new_actions(map, resource)
            map_member_actions(map, resource)

            map_associations(resource, options)

            if block_given?
              with_options(:path_prefix => resource.nesting_path_prefix, :name_prefix => resource.nesting_name_prefix, :namespace => "#{options[:namespace]}#{resource.plural}/", &block)
            end
          end
        end

        def map_singleton_resource(entities, options = {}, &block)
          resource = ActionController::Resources::SingletonResource.new(entities, options)

          with_options :controller => resource.controller do |map|
            map_collection_actions(map, resource)
            map_default_singleton_actions(map, resource)
            map_new_actions(map, resource)
            map_member_actions(map, resource)

            map_associations(resource, options)

            if block_given?
              with_options(:path_prefix => resource.nesting_path_prefix, :name_prefix => resource.nesting_name_prefix, :namespace => "#{options[:namespace]}#{resource.plural}/", &block)
            end
          end
        end

        def map_associations(resource, options)
          path_prefix = "#{options.delete(:path_prefix)}#{resource.nesting_path_prefix}"
          name_prefix = "#{options.delete(:name_prefix)}#{resource.nesting_name_prefix}"

          Array(options[:has_many]).each do |association|
            resources(association, :path_prefix => path_prefix, :name_prefix => name_prefix, :namespace => "#{options[:namespace]}#{resource.plural}/")
          end

          Array(options[:has_one]).each do |association|
            resource(association, :path_prefix => path_prefix, :name_prefix => name_prefix, :namespace => "#{options[:namespace]}#{resource.plural}/")
          end
        end
      end
    end
  end
end