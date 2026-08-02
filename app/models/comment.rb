class Comment < ApplicationRecord
  include DemoScoped

  belongs_to :user
  belongs_to :commentable, polymorphic: true

  # 閲覧スコープを持たないのは書き忘れではない。
  # 閲覧スコープは「id で直接引く経路を持つモデル」だけが持つ約束にしている。
  # Comment を id で引く経路は存在せず（comments#create が引くのは commentable の方）、
  # 取得は常に親の閲覧スコープを通した commentable.comments 経由になるため、
  # 閲覧境界（demo 境界と公開範囲）は親が保証する。
  #
  # commentable は polymorphic のため、TaskAssignment のように joins + merge で
  # 親の境界を合成することもできない。demo 境界だけのスコープを置くと、
  # 名前が保証しない範囲まで保証しているように読まれる。

  validates :content, presence: true, length: { maximum: 200 }
end
