# This code is written after 'Wrapping an existing method' section of
# http://www.redmine.org/wiki/redmine/Plugin_Internals

require_dependency 'custom_fields_helper'

module BlogNewsCustomFieldsPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :custom_fields_tabs, :blog_news_tab
    end
  end

  module InstanceMethods
    def custom_fields_tabs_with_blog_news_tab
      custom_fields_tabs_without_blog_tab << {:name => 'BlogCustomField', :partial => 'custom_fields/index', :label => :label_blog_plural} << {:name => 'NewsCustomField', :partial => 'custom_fields/index', :label => :label_news_plural}
    end
  end
end

CustomFieldsHelper.send(:include, BlogNewsCustomFieldsPatch)

# Code that follows is written after 'Adding a new method' section of
# http://www.redmine.org/wiki/redmine/Plugin_Internals

require_dependency 'news'

module NewsPatch
  def self.included(base)
    # base.extend(ClassMethods)
    # base.send(:include, InstanceMethods)

    base.class_eval do
      acts_as_customizable
    end
  end
end

News.send(:include, NewsPatch)

require_dependency 'news_controller'

module NewsControllerPatch
  def self.included(base)
    base.class_eval do
      helper :custom_fields
    end
  end
end

NewsController.send(:include, NewsControllerPatch)
