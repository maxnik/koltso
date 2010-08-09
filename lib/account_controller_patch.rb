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
      if params[:user]
        params[:user][:unsaved_taxon_ids] ||= [] # if all checkboxes are unchecked
        @unsaved_taxon_ids = params[:user][:unsaved_taxon_ids].inject(Hash.new(false)) do |ids, id|
          ids[id.to_i] = true
          ids
        end
      else
        @unsaved_taxon_ids = Hash.new(false)
      end

      @territories, @themes = TaxonFamily.load_territories_themes
    end
  end
end

AccountController.send(:include, AccountControllerPatch)
