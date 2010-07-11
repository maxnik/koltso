class KoltsoController < ApplicationController
  unloadable

  def lenta
    @territories, @themes = TaxonFamily.load_territories_themes

    blogs_conditions = users_conditions = ''

    @user = User.current
    if params[:taxon_ids] || ! @user.anonymous?
      if params[:taxon_ids]
        taxons = Taxon.find(:all, :select => 'taxons.id, taxons.taxon_family_id',
                            :conditions => {:id => params[:taxon_ids]})
      else
        taxons = @user.taxons.find(:all, :select => 'taxons.id, taxons.taxon_family_id')
      end
      @taxon_ids = taxons.map {|t| t.id} # for checkboxes
      taxon_ids = taxons.inject({}) {|t_ids, t| (t_ids[t.taxon_family_id] ||= []) << t.id; t_ids}
      #  {1=>[3, 9, 14], 2=>[17, 23]}
      taxon_ids = taxon_ids.values.map {|t_ids| t_ids.join(',') }
      # ["3,9,14", "17,23"]
      blogs_conditions = "WHERE " << taxon_ids.map do |t_ids| 
        "blogs.id IN (SELECT DISTINCT resource_id FROM taxonomies " << 
          "WHERE resource_type = 'Blog' AND taxon_id IN (#{t_ids}))"
      end.join(' AND ')
      users_conditions = "WHERE " << taxon_ids.map do |t_ids| 
        "id IN (SELECT DISTINCT resource_id FROM taxonomies " << 
          "WHERE resource_type = 'Principal' AND taxon_id IN (#{t_ids}))"
      end.join(' AND ')
      # (taxons OR from OR one OR taxon_family) AND (taxons OR from OR another OR taxon_family)
    end
    blogs_query = "(SELECT blogs.id, blogs.created_on, blogs.title, blogs.description, " <<
                  "'blogs' AS table_name, 'Blog' AS resource_type, " <<
                  "users.id AS user_id, users.firstname AS user_firstname, users.lastname AS user_lastname " <<
                  "FROM blogs " <<
                  "INNER JOIN users ON users.id = blogs.author_id #{blogs_conditions})"
    users_query = "(SELECT id, created_on, '', '', " <<
                  "'users' AS table_name, 'Principal' AS resource_type, " <<
                  "0, firstname AS user_firstname, lastname AS user_lastname " <<
                  "FROM users #{users_conditions})"
    @resources = Blog.find_by_sql([blogs_query, users_query].join(' UNION ') << " ORDER BY created_on DESC")

    conditions = @resources.map do |r|
      "(resource_type = '#{r.resource_type}' AND resource_id = #{r.id})"
    end.join(' OR ')
    taxons = Taxon.find(:all,
                        :select => 'taxons.name, taxons.taxon_family_id, taxonomies.resource_type, taxonomies.resource_id',
                        :joins => :taxonomies,
                        :conditions => conditions)
    @taxons = taxons.inject({}) {|tt, t| (tt["#{t.resource_type}#{t.resource_id}"] ||= []) << t; tt}
    @territories_family_id = @territories[0].taxon_family_id unless @territories.blank?
    @themes_family_id = @themes[0].taxon_family_id unless @themes.blank?

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
