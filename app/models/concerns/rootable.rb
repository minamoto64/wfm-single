module Rootable
  extend ActiveSupport::Concern

  included do
    before_validation :assign_root
    after_create :assign_self_as_root

    belongs_to :parent, class_name: name, optional: true
    belongs_to :root, class_name: name, optional: true
  end

  class_methods do
    def rootable(order_column:)
      has_many :children,
               -> { order(order_column => :desc) },
               class_name: name,
               foreign_key: "parent_id"

      has_many :"rooted_#{model_name.plural}", class_name: name, foreign_key: :root_id, dependent: :nullify

      define_method(:"related_#{model_name.plural}") do
        rooted_all = root.public_send(:"rooted_#{model_name.plural}")
        rooted_all.reject { |record| record.id == id }.sort_by(&order_column)
      end
    end
  end

  private

  def assign_root
    return unless parent

    self.root = parent.root || parent
  end

  def assign_self_as_root
    update_column(:root_id, id) if root_id.nil?
  end
end
