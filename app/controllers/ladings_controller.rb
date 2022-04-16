class LadingsController < ApplicationController
  before_filter :login_required
  before_filter :ensure_customer_access, except: :requests

  grid association: 'current_customer.pending_ladings', class_name: 'PendingLading',
       finder: { include: [:contract, :commodity, :shipper_customer],
       select: [:id, :draft, :lading_num, :lading_date, :load_tick_num, :o_cont, :comm, :orig, { shipper_customer: [:id, :cust_id] }],
                    conditions: "HM.PendingLading.Deleted = 0" }

  def new
    @lading = PendingLading.default(current_customer)
  end

  def create
    @lading = PendingLading.default(current_customer)
    @lading.attributes = params[:lading]

    if @lading.save
      save_flash_and_redirect(@lading, current_customer)
    else
      flash[:error] = "Can't save Lading"
      render action: 'new'
    end
  end

  def edit
    @lading = current_customer.pending_ladings.find(params[:id])
  end

  def update
    @lading = current_customer.pending_ladings.find(params[:id])

    if @lading.update_attributes(params[:lading])
      save_flash_and_redirect(@lading, current_customer)
    else
      flash[:error] = "Can't save Lading"
      render action: 'edit'
    end
  end

  def destroy
    # user can remove only draft objects
    @lading = current_customer.pending_ladings.find_by_id_and_draft(params[:id], true)
    if @lading
      @lading.deleted = true
      @lading.save
    end
    render nothing: true
  end

  def print
    request.format = :pdf
    @lading = current_customer.pending_ladings.find_by_id_and_draft(params[:id], false)
    prawnto filename: "lading_#{@lading.lading_num}.pdf"
  end

  def requests
    current_customer = current_user.customers.find_by_cust_id(params[:customer_id])
    if request.post?
      LadingMailer.requests_email(params[:amount], params[:address]).deliver
      flash[:notice] = "Email was successfully sent"
      redirect_to customers_url
    end
  end

  private
  def ensure_customer_access
    redirect_to(home_url) unless current_customer.can_view_ladings?
  end

  def save_flash_and_redirect(lading, customer)
    if lading.draft?
      flash[:notice] = "Lading was successfully saved."
    else
      flash[:notice] = "Your lading has successfully been submitted for review. Thanks!"
      flash[:lading_to_print] = lading.id
    end

    redirect_to customer_ladings_url(customer)
  end
end
