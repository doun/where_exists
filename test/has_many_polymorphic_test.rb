require 'test_helper'

ActiveRecord::Migration.create_table :relevant_polymorphic_entities, :force => true do |t|
  t.string :name
end

ActiveRecord::Migration.create_table :irrelevant_polymorphic_entities, :force => true do |t|
  t.string :name
end

ActiveRecord::Migration.create_table :has_many_polymorphic_children, :force => true do |t|
  t.integer :polymorphic_thing_id
  t.string :polymorphic_thing_type
  t.string :name
end

class HasManyPolymorphicChild < ActiveRecord::Base
  belongs_to :polymorphic_thing, polymorphic: true
end

class RelevantPolymorphicEntity < ActiveRecord::Base
  has_many :children, as: :polymorphic_thing, class_name: HasManyPolymorphicChild
end

class IrrelevantPolymorphicEntity < ActiveRecord::Base
  has_many :children, as: :polymorphic_thing, class_name: HasManyPolymorphicChild
end

class HasManyPolymorphicTest < Minitest::Test
  def setup
    ActiveRecord::Base.descendants.each(&:delete_all)
  end

  def test_polymorphic
    child = HasManyPolymorphicChild.create!

    irrelevant_entity = IrrelevantPolymorphicEntity.create!(children: [child])
    _relevant_entity = RelevantPolymorphicEntity.create!(id: irrelevant_entity.id)

    result = RelevantPolymorphicEntity.where_exists(:children)

    assert_equal 0, result.length
  end
end
