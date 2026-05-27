class NoticeTask < ApplicationRecord
  belongs_to :notice
  belongs_to :task
end
