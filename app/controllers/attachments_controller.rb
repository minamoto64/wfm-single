class AttachmentsController < ApplicationController
  ATTACHABLES = {
    "Interaction" => Interaction,
    "Task" => Task,
    "Notice" => Notice
  }.freeze

  # ActiveStorage の既定ルートはアプリの認可を通らないため、
  # 添付が属するレコードを readable で引き直したうえでバイト列を直接返す。
  # URL を発行しないので署名付き URL も残らない。
  def show
    attachment = ActiveStorage::Attachment.where(name: "images").find(params[:id])
    klass = ATTACHABLES[attachment.record_type]

    raise ActiveRecord::RecordNotFound unless klass

    # 到達できないレコードの添付は 404。認可はレコード側の readable が唯一の判断基準。
    klass.readable.find(attachment.record_id)

    variant = attachment.variant(resize_to_limit: [ 800, 800 ]).processed

    # 認可を通した個人向けレスポンスなので共有キャッシュには載せない。
    expires_in 1.hour, public: false

    send_data variant.download, type: variant.content_type, disposition: :inline
  end
end
