# Hook in the code.

ActionController::Resources::SingletonResource.send :include, Rubaidh::NamespacedNestedResources::SingletonResource
ActionController::Routing::RouteSet::Mapper.send :include, Rubaidh::NamespacedNestedResources::Resources