class TaxonFamily < ActiveRecord::Base
  has_many :taxons

  def self.find_territories_themes
    @taxon_families ||= TaxonFamily.find(:all)
    @territories ||= @taxon_families.detect {|tf| tf.name == 'Территории'}
    @themes ||= @taxon_families.detect {|tf| tf.name == 'Темы'}
    return @territories, @themes
  end

  def self.load_territories_themes
    @taxon_families ||= TaxonFamily.find(:all)
    unless @territories
      territories_family = @taxon_families.detect {|tf| tf.name == 'Территории'}
      @territories = territories_family.taxons unless territories_family.nil?
    end
    unless @themes
      themes_family = @taxon_families.detect {|tf| tf.name == 'Темы'}
      @themes = themes_family.taxons unless themes_family.nil?
    end
    return @territories, @themes
  end
end
