class IssueNoticeCounters < ActiveRecord::Base
  include Redmine::SafeAttributes

  belongs_to :project
  belongs_to :author, class_name: 'User'

  scope :visible, ->(*args) { where(IssueNoticeCounters.visible_condition(args.shift || User.current, *args)).joins(:project) }
  
  scope :sorted, -> { order("#{table_name}.name ASC") }
  


  validates :project_id, presence: true
  validates :author_id, presence: true
  validates :name, presence: true

  safe_attributes *%w[name query_id enabled position]
  safe_attributes 'project_id', if: ->(issue_notice_counters, _user) { issue_notice_counters.new_record? }


  def self.visible_condition(user, options = {})
    Project.allowed_to_condition(user, :view_issue_notice_counters, options)
  end

  def self.css_icon
    'icon icon-user'
  end

  def editable_by?(user)
    editable?(user)
  end


  def visible?(user = nil)
    user ||= User.current
    user.allowed_to?(:view_issue_notice_counters, project, global: true)
  end

  def editable?(user = nil)
    user ||= User.current
    user.allowed_to?(:manage_issue_notice_counters, project, global: true)
  end

  def deletable?(user = nil)
    user ||= User.current
    user.allowed_to?(:manage_issue_notice_counters, project, global: true)
  end

  def attachments_visible?(user = nil)
    visible?(user)
  end

  def attachments_editable?(user = nil)
    editable?(user)
  end

  def attachments_deletable?(user = nil)
    deletable?(user)
  end

  def to_s
    name.to_s
  end

  alias_attribute :created_on, :created_at
  alias_attribute :updated_on, :updated_at


end
