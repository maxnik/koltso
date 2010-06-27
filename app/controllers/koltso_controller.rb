class KoltsoController < ApplicationController
  unloadable

  def lenta
    territories, themes = TaxonFamily.find_territories_themes
    @territories = territories.taxons unless territories.nil?
    @themes = themes.taxons unless themes.nil?

    @user = User.current
    if @user.anonymous?
      # unregistered user
    else
      # registered user
    end
  end
end
