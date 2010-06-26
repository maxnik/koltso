class Taxonomy < ActiveRecord::Migration
  def self.up
    create_table :taxon_families do |t|
      t.string :name, :null => false
      t.boolean :can_have_only_one, :default => false
      t.boolean :for_issues, :default => false
      t.boolean :for_users, :default => false
      t.boolean :for_blogs, :default => false
      t.boolean :for_news, :default => false
    end

    create_table :taxons do |t|
      t.string :name, :null => false
      t.integer :taxon_family_id, :null => false
      t.integer :position, :default => 1
    end

    create_table :taxonomies do |t|
      t.integer :taxon_id, :null => false
      t.string :resource_type, :null => false
      t.integer :resource_id, :null => false
    end

    {'Темы' => ['Благотворительность, волонтерство, альтруизм', 'Творчество, искусство, культура',
                'Развитие, самопознание, духовность', 'Тело, здоровье, физическая культура',
                'Мир, общество, глобальные процессы', 'Неформальные культуры', 'Права человека', 'Экология и зоозащита',
                'Поселения, жизнь на природе', 'Велосипеды, походы, путешествия', 'Дети и педагогика',
                'Бизнес с человеческим лицом', 'Наука и научное сообщество', 'Техника, компьютеры, технологии',
                'Журналистика и информационная деятельность'],
      'Территории' => ['Весь центральный округ', 'Москва и область', 'Весь Северо-Западный округ',
                       'Санкт-Петербург и область', 'Весь Южный округ', 'Ростов-на-Дону и область',
                       'Весь Приволжский округ', 'Нижний Новгород и область', 'Весь Северо-Кавказский округ',
                       'Вся Уральская область', 'Весь Сибирский округ', 'Весь Дальневосточный округ',
                       'Все округа России', 'Украина', 'Белоруссия', 'Молдавия', 'Все страны СНГ',
                       'Весь мир']}.each do |taxon_family_name, taxon_names|
      taxon_family = TaxonFamily.create!(:name => taxon_family_name)
      taxon_names.each_with_index do |taxon_name, index|
        Taxon.create!(:name => taxon_name, :taxon_family_id => taxon_family.id, :position => index + 1)
      end
    end
  end

  def self.down
    drop_table :taxon_families
    drop_table :taxons
    drop_table :taxonomies
  end
end
