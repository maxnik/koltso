#require 'tag'
class BlogsController < ApplicationController
  unloadable

  helper :custom_fields
  helper :attachments
  include AttachmentsHelper

  before_filter :find_blog, :except => [:new, :index, :preview, :show_by_tag, :get_tag_list]
  #before_filter :find_project, :only => [:new, :preview]
  #before_filter :authorize, :except => [:index, :preview]
  before_filter :find_user, :only => [:index]
  before_filter :find_optional_project, :except => [:index, :preview, :show_by_tag, :get_tag_list]
  accept_key_auth :index

  before_filter :load_territories_themes, :only => [:index, :show_by_tag, :show, :new, :edit]
  before_filter :find_territories_themes_family_ids, :only => [:index, :show_by_tag, :show]

  def index
    @blogs_pages, @blogs = paginate :blogs,
      :per_page => 10,
      :conditions => (@user ? ["author_id = ?", @user.id] : nil),
      :include => [:author],
      :order => "#{Blog.table_name}.created_on DESC"
    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.atom { render_feed(@blogs, :title => "#{Setting.app_title}: Blogs") }
      format.rss  { render_feed(@blogs, :title => "#{Setting.app_title}: Blogs", :format => 'rss' ) }
    end
  end

  def show_by_tag
    @blogs_pages, @blogs = paginate :blogs,
      :per_page => 10,
      :conditions => ["#{Tag.table_name}.name = ?", params[:id]],
      :include => [:author,:tags],
      :order => "#{Blog.table_name}.created_on DESC"
    respond_to do |format|
      format.html { render :action => 'index', :layout => !request.xhr? }
      format.atom { render_feed(@blogs, :title => "#{Setting.app_title}: Blogs") }
    end
    #@blogs_by_tag = Blog.find_tagged_with(param[:id])
  end

  def show
    @comments = @blog.comments
    @comments.reverse! if User.current.wants_comments_in_reverse_order?
  end

  def new
    @blog = Blog.new(:author => User.current)
    if request.post?
      @blog.attributes = params[:blog]
      if @blog.save
        attach_files(@blog, params[:attachments])
        flash[:notice] = l(:notice_successful_create)
        # Mailer.deliver_blog_added(@blog) if Setting.notified_events.include?('blog_added')
        redirect_to :controller => 'blogs', :action => 'index'
      end
    end
  end

  def edit
    render_403 if User.current != @blog.author
    if request.post? and @blog.update_attributes(params[:blog])
      attachments = attach_files(@blog, params[:attachments])
      flash[:notice] = l(:notice_successful_update)
    end
    redirect_to :action => 'show', :id => @blog
  end

  def add_comment
    @comment = Comment.new(params[:comment])
    @comment.author = User.current
    if @blog.comments << @comment
      flash[:notice] = l(:label_comment_added)
      redirect_to :action => 'show', :id => @blog
    else
      render :action => 'show'
    end
  end

  def destroy_comment
    @blog.comments.find(params[:comment_id]).destroy
    redirect_to :action => 'show', :id => @blog
  end

  def destroy
    render_403 if User.current != @blog.author
    @blog.destroy
    redirect_to :action => 'index'
  end

  def preview
    @text = (params[:blog] ? params[:blog][:description] : nil)
    @blog = Blog.find(params[:id]) if params[:id]
    @attachements = @blog.attachments if @blog
    render :partial => 'common/preview'
  end

  def get_tag_list
    #params[:data] |= ''
    render :text => Tag.find(:all) * ","
    #, :conditions => ["#{Tag.table_name}.name LIKE ?", params[:data]]
    return
  end

private
  def find_blog
    @blog = Blog.find(params[:id])
    #@project = @blog.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_user
    @user = User.find(params[:id]) if params[:id]
    #@blog = Blog.find_by_user(@user)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_optional_project
    #return true unless params[:project_id]
    @project = Project.find(params[:project_id]) unless params[:project_id].blank?
    allowed = User.current.allowed_to?({:controller => params[:controller], :action => params[:action]}, @project, :global => true)
    allowed ? true : deny_access

    #@project = Project.find(params[:project_id])
    #authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def load_territories_themes
    @territories, @themes = TaxonFamily.load_territories_themes
  end

  def find_territories_themes_family_ids
    @territories_family_id = @territories[0].taxon_family_id unless @territories.blank?
    @themes_family_id = @themes[0].taxon_family_id unless @themes.blank?
  end
end
