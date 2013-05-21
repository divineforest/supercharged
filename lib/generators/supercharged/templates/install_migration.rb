class InstallSupercharged < ActiveRecord::Migration
  def change
    create_table "gateway_notifications", :force => true do |t|
      t.text     "params"
      t.string   "status"
      t.string   "external_transaction_id"
      t.integer  "charge_id"
      t.datetime "created_at",              :null => false
      t.datetime "updated_at",              :null => false
      t.string   "gateway"
    end

    add_index "gateway_notifications", ["charge_id"], :name => "index_gateway_input_notifications_on_charge_id"

    create_table "charges_state_transitions", :force => true do |t|
      t.integer  "charges_id"
      t.string   "charges_type"
      t.string   "event"
      t.string   "from"
      t.string   "to"
      t.datetime "created_at"
    end

    add_index "charges_state_transitions", ["charges_id"], :name => "index_charges_state_transitions_on_charges_id"

    create_table "charges", :force => true do |t|
      t.integer  "amount",                                     :null => false
      t.integer  "user_id",                                    :null => false
      t.string   "external_transaction_id"
      t.text     "params"
      t.string   "state",                   :default => "new", :null => false
      t.datetime "created_at",                                 :null => false
      t.datetime "updated_at",                                 :null => false
      t.string   "error"
      t.integer  "approved_by"
      t.text     "reject_reason"
      t.decimal  "real_amount"
    end

    add_index "charges", ["approved_by"], :name => "index_charges_on_approved_by"
    add_index "charges", ["state"], :name => "index_charges_on_state"
    add_index "charges", ["user_id"], :name => "index_charges_on_user_id"
  end
end
