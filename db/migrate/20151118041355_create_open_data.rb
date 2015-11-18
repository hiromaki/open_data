class CreateOpenData < ActiveRecord::Migration
  def change
    create_table :open_data do |t|
      t.string :x
      t.string :y
      t.string :shisetsu_name
      t.string :shisetsu_name_kana
      t.string :shisetsu_name_all
      t.string :syozaichi
      t.string :chiku_name
      t.string :tel
      t.string :fax
      t.string :syosai_info
      t.string :kaikan_jikan
      t.string :url
      t.string :barrier_free_info
      t.string :tyurinjyo_pc
      t.string :tyurinjyo_kei
      t.string :dai_bunrui
      t.string :syo_bunrui
      t.string :category
      t.string :icon_no
      t.string :shisetsu_id
      t.string :latlng

      t.timestamps null: false
    end
  end
end
