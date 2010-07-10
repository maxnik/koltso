# Code that follows is written after 'Adding a new method' section of
# http://www.redmine.org/wiki/redmine/Plugin_Internals

require_dependency 'account_controller'

module AccountControllerPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do 
      before_filter :load_territories_themes, :only => :register
    end
  end

  module InstanceMethods

    private

    def load_territories_themes
      params[:user][:taxon_ids] ||= [] unless params[:user].nil? # if all checkboxes are unchecked

      @territories, @themes = TaxonFamily.load_territories_themes
    end
  end
end

AccountController.send(:include, AccountControllerPatch)
