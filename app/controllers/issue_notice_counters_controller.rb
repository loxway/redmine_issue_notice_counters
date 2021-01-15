class IssueNoticeCountersController < ApplicationController

  menu_item :issue_notice_counters

  before_action :authorize_global
  before_action :find_issue_notice_counters, only: [:show, :edit, :update]
  before_action :find_issue_notice_counters, only: [:context_menu, :bulk_edit, :bulk_update, :destroy]
  before_action :find_project

  helper :issue_notice_counters
  helper :custom_fields, :context_menus, :attachments, :issues
  include_query_helpers

  accept_api_auth :index, :show, :create, :update, :destroy

  def index

    retrieve_query(IssueNoticeCountersQuery)
    @entity_count = @query.issue_notice_counters.count
    @entity_pages = Paginator.new @entity_count, per_page_option, params['page']
    @entities = @query.issue_notice_counters(offset: @entity_pages.offset, limit: @entity_pages.per_page)

  end

  def show
    respond_to do |format|
      format.html
      format.api
      format.js
    end
  end

  def new
    @issue_notice_counters = IssueNoticeCounters.new
    @issue_notice_counters.project = @project
    @issue_notice_counters.safe_attributes = params[:issue_notice_counters]

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @issue_notice_counters = IssueNoticeCounters.new author: User.current
    @issue_notice_counters.project = @project
    @issue_notice_counters.safe_attributes = params[:issue_notice_counters]

    respond_to do |format|
      if @issue_notice_counters.save
        format.html do
          flash[:notice] = l(:notice_successful_create)
          redirect_back_or_default issue_notice_counters_path(@issue_notice_counters)
        end
        format.api { render action: 'show', status: :created, location: issue_notice_counters_url(@issue_notice_counters) }
        format.js { render template: 'common/close_modal' }
      else
        format.html { render action: 'new' }
        format.api { render_validation_errors(@issue_notice_counters) }
        format.js { render action: 'new' }
      end
    end
  end

  def edit
    @issue_notice_counters.safe_attributes = params[:issue_notice_counters]

    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    @issue_notice_counters.safe_attributes = params[:issue_notice_counters]

    respond_to do |format|
      if @issue_notice_counters.save
        format.html do
          flash[:notice] = l(:notice_successful_update)
          redirect_back_or_default issue_notice_counters_path(@issue_notice_counters)
        end
        format.api { render_api_ok }
        format.js { render template: 'common/close_modal' }
      else
        format.html { render action: 'edit' }
        format.api { render_validation_errors(@issue_notice_counters) }
        format.js { render action: 'edit' }
      end
    end
  end

  def destroy
    @issue_notice_counters.each(&:destroy)

    respond_to do |format|
      format.html do
        flash[:notice] = l(:notice_successful_delete)
        redirect_back_or_default issue_notice_counters_path
      end
      format.api { render_api_ok }
    end
  end

  def bulk_edit
  end

  def bulk_update
    unsaved, saved = [], []
    attributes = parse_params_for_bulk_update(params[:issue_notice_counters])
    @issue_notice_counters.each do |entity|
      entity.init_journal(User.current) if entity.respond_to? :init_journal
      entity.safe_attributes = attributes
      if entity.save
        saved << entity
      else
        unsaved << entity
      end
    end
    respond_to do |format|
      format.html do
        if unsaved.blank?
          flash[:notice] = l(:notice_successful_update)
        else
          flash[:error] = unsaved.map{|i| i.errors.full_messages}.flatten.uniq.join(",\n")
        end
        redirect_back_or_default :index
      end
    end
  end

  def context_menu
    if @issue_notice_counters.size == 1
      @issue_notice_counters = @issue_notice_counters.first
    end

    can_edit = @issue_notice_counters.detect{|c| !c.editable?}.nil?
    can_delete = @issue_notice_counters.detect{|c| !c.deletable?}.nil?
    @can = {edit: can_edit, delete: can_delete}
    @back = back_url

    @issue_notice_counters_ids, @safe_attributes, @selected = [], [], {}
    @issue_notice_counters.each do |e|
      @issue_notice_counters_ids << e.id
      @safe_attributes.concat e.safe_attribute_names
      attributes = e.safe_attribute_names - (%w(custom_field_values custom_fields))
      attributes.each do |c|
        column_name = c.to_sym
        if @selected.key? column_name
          @selected[column_name] = nil if @selected[column_name] != e.send(column_name)
        else
          @selected[column_name] = e.send(column_name)
        end
      end
    end

    @safe_attributes.uniq!

    render layout: false
  end

  def autocomplete
  end

  private

  def find_issue_notice_counters
    @issue_notice_counters = IssueNoticeCounters.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_issue_notice_counters
    @issue_notice_counters = IssueNoticeCounters.visible.where(id: (params[:id] || params[:ids])).to_a
    @issue_notice_counters = @issue_notice_counters.first if @issue_notice_counters.count == 1
    raise ActiveRecord::RecordNotFound if @issue_notice_counters.empty?
    raise Unauthorized unless @issue_notice_counters.all?(&:visible?)

    @projects = @issue_notice_counters.collect(&:project).compact.uniq
    @project = @projects.first if @projects.size == 1
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_project
    @project ||= @issue_notice_counters.project if @issue_notice_counters
    @project ||= Project.find(params[:project_id]) if params[:project_id].present?
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
