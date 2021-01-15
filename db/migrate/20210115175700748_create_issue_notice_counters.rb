class CreateIssueNoticeCounters < ActiveRecord::Migration[4.2.8]
  def change
    create_table :issue_notice_counters do |t|


      t.string :name, null: true
      t.integer :query_id, null: true
      t.boolean :enabled, null: true
      t.integer :position, null: true
      t.integer :project_id, null: false
      t.integer :author_id, null: false
      t.belongs_to :author
      t.belongs_to :project

      t.timestamps
    end
  end
end
