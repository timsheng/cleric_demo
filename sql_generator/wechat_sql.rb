require 'cleric'
module WechatSQL
  include Cleric

  row :lead, :table => 'lead'
  row :session, :table => 'session'
  row :account_binding, :table => 'account_binding'

end
