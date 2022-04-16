class ProofOfYieldReport
  attr_accessor :cust_id, :comm_name, :start_date, :end_date

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def start_date
    @start_date ||= Time.now.beginning_of_year.to_date
  end

  def start_date=(date)
    @start_date = date.is_a?(String) ? date.to_date : date
  end

  def end_date
    @end_date ||= Date.today
  end

  def end_date=(date)
    @end_date = date.is_a?(String) ? date.to_date : date
  end

  def commodity
    @commodity ||= Commodity.find_by_comm_name(self.comm_name)
  end

  def data_grouped_by_ticket
    @data_grouped_by_ticket ||= TicketApp.connection.select_all(grouped_by_ticket_sql)
  end

  def data_grouped_by_customer
    @data_grouped_by_customer ||= TicketApp.connection.select_all(grouped_by_customer_sql)
  end

  def first_names
    @first_names ||= data_grouped_by_customer.map { |row| row['company'].split(' ').first }
  end

  def last_names
    @last_names ||= data_grouped_by_customer.map { |row| row['company'].split(' ').last }
  end

  def tickets
    @tickets ||= Ticket.select(:remarks).includes(discounts: :disc_type).where(id: data_grouped_by_ticket.map { |row| row['ticket_id'] }).inject({}) do |result, ticket|
      result[ticket.tick_num] = ticket
      result
    end
  end

  private
  def common_select
    'SUM(GrainDiscDollars) AS grain_disc, SUM(Storage) AS storage, SUM(GrossNTU) AS sum_gross, SUM(GrossNTU - NetNTU) AS sum_gross_net, SUM(NetNTU) AS sum_net, SUM(NetNTU - NetStorNTU) AS sum_net_netstor, SUM(NetStorNTU) AS sum_netstor'
  end

  def from_and_conditions
    "FROM HM.TicketApp WHERE Deleted <> 1 AND TickType = 'P' AND Ticket->Orig->CustId = #{TicketApp.connection.quote(self.cust_id)} AND Ticket->Comm->CommId = #{TicketApp.connection.quote(self.commodity.comm_id)} AND Ticket->DlvDate BETWEEN #{TicketApp.connection.quote(self.start_date)} AND #{TicketApp.connection.quote(self.end_date)}"
  end

  def grouped_by_ticket_sql
    "SELECT Ticket->TickNum AS ticket_num, Ticket->%Id AS ticket_id, Ticket->DlvDate AS dlv_date, #{common_select} #{from_and_conditions} GROUP BY Ticket ORDER BY Ticket->DlvDate, Ticket->TickNum"
  end

  def grouped_by_customer_sql
    "SELECT Customer->CustId AS cust_id, Customer->Company AS company, #{common_select} #{from_and_conditions} GROUP BY Customer ORDER BY Customer->CustId"
  end
end
