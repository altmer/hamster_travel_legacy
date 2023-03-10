# frozen_string_literal: true
class CreateTripInvites < ActiveRecord::Migration[5.0]
  def change
    create_table :trip_invites do |t|
      t.belongs_to :inviting_user, index: true
      t.belongs_to :invited_user, index: true
      t.belongs_to :trip, index: true
    end
  end
end
