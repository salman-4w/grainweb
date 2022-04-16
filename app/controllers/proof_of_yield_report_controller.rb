class ProofOfYieldReportController < ApplicationController
  before_filter :login_required

  layout nil

  def show
    @report = ProofOfYieldReport.new
    respond_to do |format|
      format.js
    end
  end

  def create
    @report  = ProofOfYieldReport.new(params[:report])
    filename = "proof_of_yield-#{params[:report][:cust_id]}.pdf"
    # hack around IE problem with pdfs and SSL
    # see: http://stackoverflow.com/questions/1574108/rails-pdf-generation-with-prawn-in-ie7
    response.headers["Content-Disposition"]       = "attachment;filename=\"#{filename}.pdf\""
    response.headers["Content-Description"]       = "File Transfer"
    response.headers["Content-Transfer-Encoding"] = "binary"
    response.headers["Expires"]                   = "0"
    response.headers["Pragma"]                    = "public"
    # see: https://groups.google.com/d/msg/prawn-ruby/VSAtRfPcSw0/ljk2N790bjUJ
    response.headers["Cache-Control"]             = "private, max-age=0, must-revalidate"
    prawnto prawn: { page_layout: :landscape }, filename: filename
  end
end
