Redmine::Plugin.register :redmine_issue_notice_counters do
  name 'Redmine Issue Notice Counters'
  author ''
  author_url ''
  description ''
  version '2021'

  #into easy_settings goes available setting as a symbol key, default value as a value
  settings easy_settings: {  }
  
end


unless Redmine::Plugin.registered_plugins[:easy_extensions]
  require_relative 'after_init'
end


