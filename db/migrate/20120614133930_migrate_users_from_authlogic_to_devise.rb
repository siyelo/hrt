class MigrateUsersFromAuthlogicToDevise < ActiveRecord::Migration

  def up
    rename_column :users, :crypted_password, :encrypted_password

    add_column :users, :confirmation_token, :string, :limit => 255
    add_column :users, :confirmed_at, :timestamp
    add_column :users, :confirmation_sent_at, :timestamp
    execute "UPDATE users SET confirmed_at = created_at, confirmation_sent_at = created_at"
    add_column :users, :reset_password_token, :string, :limit => 255
    add_column :users, :reset_password_sent_at, :timestamp

    rename_column :users, :current_login_at, :current_sign_in_at
    rename_column :users, :last_login_at, :last_sign_in_at
    add_column :users, :remember_token, :string, :limit => 255
    add_column :users, :remember_created_at, :timestamp
    add_column :users, :sign_in_count, :integer, :default => 0
    add_column :users, :current_sign_in_ip, :string
    add_column :users, :last_sign_in_ip, :string

    remove_column :users, :persistence_token
    remove_column :users, :perishable_token

    # add_index :users, :email,                :unique => true
    add_index :users, :confirmation_token,   :unique => true
    add_index :users, :reset_password_token, :unique => true
  end

  def down
    rename_column :users, :encrypted_password, :crypted_password

    # remove_index :users, :email
    remove_index :users, :confirmation_token
    remove_index :users, :reset_password_token

    add_column :users, :persistence_token, :string
    add_column :users, :perishable_token, :string

    remove_column :users, :remember_token
    remove_column :users, :remember_created_at
    rename_column :users, :sign_in_count, :login_count
    rename_column :users, :current_sign_in_at, :current_login_at
    rename_column :users, :last_sign_in_at, :last_login_at
    rename_column :users, :current_sign_in_ip, :current_login_ip
    rename_column :users, :last_sign_in_ip, :last_login_ip


    remove_column :users, :confirmation_token
    remove_column :users, :confirmed_at
    remove_column :users, :confirmation_sent_at
    remove_column :users, :reset_password_token
    remove_column :users, :reset_password_sent_at
  end
end
