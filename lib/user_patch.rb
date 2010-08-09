# Code that follows is written after 'Adding a new method' section of
# http://www.redmine.org/wiki/redmine/Plugin_Internals

require 'user'

module UserPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.send(:include, TaxonsValidation)
    # User class already has 'validate' method http://www.redmine.org/boards/3/topics/12401
    base.alias_method_chain :validate, :taxons


    base.class_eval do
      acts_as_event :type => 'new-user',
                    :title => 'title',
                    :description => 'description',
                    :url => Proc.new {|o| {:controller => 'users', :action => 'show', :id => o}},
                    :author => nil
      acts_as_activity_provider :type => 'users', :author_key => nil
      activity_provider_options["users"].delete(:permission)

      has_many :taxonomies, :as => :resource
      has_many :taxons, :through => :taxonomies

      attr_accessor :unsaved_taxon_ids
    end
  end

  module InstanceMethods
    def after_save
      self.taxon_ids = self.unsaved_taxon_ids
    end
    
    def project
      nil # for acts_as_event and acts_as_activity_provider
    end
  end
end

User.send(:include, UserPatch)
