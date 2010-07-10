ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'koltso', :action => 'lenta'
  map.user_profile 'users/:id', :controller => 'koltso', :action => 'user_profile'
end
