module TaxonsValidation
  def validate_with_taxons
    validate_without_taxons
    taxon_family_names = Taxon.find(:all,
                                    :select => 'DISTINCT taxon_families.name AS name',
                                    :joins => :taxon_family,
                                    :conditions => {:id => self.unsaved_taxon_ids})
    taxon_family_names.map! {|tf| tf.name }
    unless taxon_family_names.include?('Темы') && taxon_family_names.include?('Территории')
      errors.add_to_base(I18n.t(:no_theme_or_territory))
    end
  end
end
