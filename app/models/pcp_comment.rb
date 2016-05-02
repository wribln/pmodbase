class PcpComment < ActiveRecord::Base
  belongs_to :pcp_item
  belongs_to :pcp_step
end
