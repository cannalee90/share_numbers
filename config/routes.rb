Rails.application.routes.draw do
  get 'sharing/index'
  get 'sharing/sendsms/:id' => 'sharing#sendsms', as: 'send_sms'
  post 'sharing/confirm_id' => 'sharing#confirm_id'

    

  get 'sharing/selection'
  get 'sharing/selection2/:id' => 'sharing#selection2'
  get 'sharing/selection3/:id' => 'sharing#selection3'
  
  
  get 'sharing/reassure/:id' => 'sharing#reassure'
  get 'sharing/confirm_sms/:id' => 'sharing#confirm_sms'
  get 'sharing/reject_sms/:id' => 'sharing#reject_sms'
  

  get 'sharing/mymessages'
  get 'sharing/logout'
  
  root 'sharing#index'
  
end