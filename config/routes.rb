
  resources :projects do 
    resources :issue_notice_counters
  end

  resources :issue_notice_counters do
    collection do 
      get 'autocomplete'
      get 'bulk_edit'
      post 'bulk_update'
      get 'context_menu'
    end
  end
