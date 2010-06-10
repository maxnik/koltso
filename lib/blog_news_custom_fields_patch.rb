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
      custom_fields_tabs_without_blog_tab << {:name => 'BlogCustomField', :partial => 'custom_fields/index', :label => :label_blog_plural}
    end
  end
end

CustomFieldsHelper.send(:include, BlogNewsCustomFieldsPatch)
