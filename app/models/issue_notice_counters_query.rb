class IssueNoticeCountersQuery < Query

  self.queried_class = IssueNoticeCounters

  def initialize_available_filters
    add_available_filter 'name', name: IssueNoticeCounters.human_attribute_name(:name), type: :string
    add_available_filter 'query_id', name: IssueNoticeCounters.human_attribute_name(:query_id), type: :integer
    add_available_filter 'enabled', name: IssueNoticeCounters.human_attribute_name(:enabled), type: :boolean
    add_available_filter 'position', name: IssueNoticeCounters.human_attribute_name(:position), type: :integer
    add_available_filter 'created_at', name: IssueNoticeCounters.human_attribute_name(:created_at), type: :date
    add_available_filter 'updated_at', name: IssueNoticeCounters.human_attribute_name(:updated_at), type: :date

  end

  def available_columns
    return @available_columns if @available_columns
    @available_columns = []
    group = l("label_filter_group_#{self.class.name.underscore}")

    @available_columns << QueryColumn.new(:name, caption: IssueNoticeCounters.human_attribute_name(:name), title: IssueNoticeCounters.human_attribute_name(:name), group: group)
    @available_columns << QueryColumn.new(:query_id, caption: IssueNoticeCounters.human_attribute_name(:query_id), title: IssueNoticeCounters.human_attribute_name(:query_id), group: group)
    @available_columns << QueryColumn.new(:enabled, caption: IssueNoticeCounters.human_attribute_name(:enabled), title: IssueNoticeCounters.human_attribute_name(:enabled), group: group)
    @available_columns << QueryColumn.new(:position, caption: IssueNoticeCounters.human_attribute_name(:position), title: IssueNoticeCounters.human_attribute_name(:position), group: group)
    @available_columns << QueryColumn.new(:created_at, caption: IssueNoticeCounters.human_attribute_name(:created_at), title: IssueNoticeCounters.human_attribute_name(:created_at), group: group)
    @available_columns << QueryColumn.new(:updated_at, caption: IssueNoticeCounters.human_attribute_name(:updated_at), title: IssueNoticeCounters.human_attribute_name(:updated_at), group: group)

    @available_columns
  end

  def initialize(attributes=nil, *args)
    super attributes
    self.filters ||= { "name" => {:operator => "*", :values => []} }
  end

  def default_columns_names
    super.presence || ["name", "query_id", "enabled", "position"].flat_map{|c| [c.to_s, c.to_sym]}
  end

  def issue_notice_counters(options={})
    order_option = [group_by_sort_order, (options[:order] || sort_clause)].flatten.reject(&:blank?)

    scope = IssueNoticeCounters.visible.
        where(statement).
        includes(((options[:include] || [])).uniq).
        where(options[:conditions]).
        order(order_option).
        joins(joins_for_order_statement(order_option.join(','))).
        limit(options[:limit]).
        offset(options[:offset])

    if has_custom_field_column?
      scope = scope.preload(:custom_values)
    end

    issue_notice_counters = scope.to_a

    issue_notice_counters
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end
end
