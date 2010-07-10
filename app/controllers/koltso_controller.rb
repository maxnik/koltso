class KoltsoController < ApplicationController
  unloadable

  def lenta
    @territories, @themes = TaxonFamily.load_territories_themes

    @user = User.current
    if @user.anonymous?
      # unregistered user
    else
      # registered user
    end

    render :layout => 'koltso'
  end

  def user_profile
    @user = User.active.find(params[:id])
    @custom_values = @user.custom_values

    territories_family, themes_family = TaxonFamily.find_territories_themes
    @user_territories = @user.taxons.select {|t| t.taxon_family_id == territories_family.id }
    @user_themes = @user.taxons.select {|t| t.taxon_family_id == themes_family.id }
    
    # show only public projects and private projects that the logged in user is also a member of
    @memberships = @user.memberships.select do |membership|
      membership.project.is_public? || (User.current.member_of?(membership.project))
    end
    
    events = Redmine::Activity::Fetcher.new(User.current, :author => @user).events(nil, nil, :limit => 10)
    @events_by_day = events.group_by(&:event_date)
    
    render :template => '/users/show', :layout => 'base'

  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
