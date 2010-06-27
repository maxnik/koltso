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
  end
end
