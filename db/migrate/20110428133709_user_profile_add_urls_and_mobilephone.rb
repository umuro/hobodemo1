class UserProfileAddUrlsAndMobilephone < ActiveRecord::Migration
  def self.up
    add_column :user_profiles, :twitter, :string
    add_column :user_profiles, :facebook, :string
    add_column :user_profiles, :homepage, :string
    add_column :user_profiles, :mobile_phone, :string
  end

  def self.down
    remove_column :user_profiles, :twitter
    remove_column :user_profiles, :facebook
    remove_column :user_profiles, :homepage
    remove_column :user_profiles, :mobile_phone
  end
end
