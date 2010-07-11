ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'koltso', :action => 'lenta'
  map.user_profile 'users/:id', :controller => 'koltso', :action => 'user_profile', :requirements => {:id => /\d+/}
  map.blog 'blogs/:id', :controller => 'blogs', :action => 'show', :requirements => {:id => /\d+/}
end
