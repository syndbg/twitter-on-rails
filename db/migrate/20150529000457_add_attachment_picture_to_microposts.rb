class AddAttachmentPictureToMicroposts < ActiveRecord::Migration
  def self.up
    change_table :microposts do |t|
      t.attachment :picture
    end
  end

  def self.down
    remove_attachment :microposts, :picture
  end
end
