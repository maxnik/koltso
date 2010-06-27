class TaxonFamily < ActiveRecord::Base
  has_many :taxons

  def self.find_territories_themes
    @taxon_families ||= TaxonFamily.find(:all)
    @territories ||= @taxon_families.detect {|tf| tf.name == 'Территории'}
    @themes ||= @taxon_families.detect {|tf| tf.name == 'Темы'}
    return @territories, @themes
  end
end
