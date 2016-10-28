require 'cleric/db'
class WechatDBFactory < Cleric::DBFactory

  row :lead, :table => 'lead'
  row :session, :table => 'session'
  row :account_binding, :table => 'account_binding'

end
