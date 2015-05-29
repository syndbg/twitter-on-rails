class Micropost < ActiveRecord::Base
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }

  has_attached_file :picture, styles: { medium: '300x300', small: '150x150' }
  validates_attachment_file_name :picture, matches: /.+/
  validates_attachment_content_type :picture,
                                    content_type: ['image/jpeg',
                                                   'image/gif',
                                                   'image/png']
  validates_attachment_size :picture, attributes: :picture,
                                      less_than: 5.megabytes
end
