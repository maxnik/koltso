# Code that follows is written after 'Adding a new method' section of
# http://www.redmine.org/wiki/redmine/Plugin_Internals

require_dependency 'users_controller'

module UsersControllerPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do 
      before_filter :load_territories_themes, :only => :show
    end
  end

  module InstanceMethods

    private
    
    def load_territories_themes
      user_taxons = Taxon.find(:all, :joins => :taxonomies,
                               :conditions => {'taxonomies.resource_type' => 'Principal',
                                               'taxonomies.resource_id' => params[:id]})

      territories_family, themes_family = TaxonFamily.find_territories_themes

      unless territories_family.nil?
        @user_territories = user_taxons.select {|t| t.taxon_family_id == territories_family.id }
      end
      unless themes_family.nil?
        @user_themes = user_taxons.select {|t| t.taxon_family_id == themes_family.id }
      end
    end
  end
end

UsersController.send(:include, UsersControllerPatch)
