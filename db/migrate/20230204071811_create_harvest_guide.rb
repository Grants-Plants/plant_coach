class CreateHarvestGuide < ActiveRecord::Migration[5.2]
  def change
    create_table :harvest_guides do |t|
      t.string :plant_type
      t.integer :when
      t.string :how
      t.string :harvest_time
      t.references :plant_coach_guide, foreign_key: true

      t.timestamps
    end
  end
end
