require "active_record"

class DgiiRnc < ActiveRecord::Base
  set_table_name "dgii_rnc"
  set_primary_key "dni_numtrans"
end

class DebtFilesbr < ActiveRecord::Base
  set_table_name "debt_filesbr"
  set_primary_key "id"
end
