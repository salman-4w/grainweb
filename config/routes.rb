Hmcustomers::Application.routes.draw do
  resources :contracts do
    get :search, on: :member

    %w(pricings bookings tickets amendments).each do |nested|
      resources nested, controller: "contract/#{nested}", only: :index do
        get :list, on: :collection
      end
    end
  end

  resources :deferred_contracts

  resources :invoices, controller: "customer_invoices" do
    member do
      get :print
    end
  end

  resources :ladings do
    get :requests, on: :collection
    get :print, on: :member, format: :pdf
  end

  resources :checks, controller: "customer_checks" do
    get :print, on: :member
  end

  resources :holdings, controller: "customer_holdings"


  resources :driver_licenses do
    get :search, on: :member
  end

  resources :reports, only: :index

  scope "/reports" do
    resource :proof_of_yield, controller: "proof_of_yield_report", only: [:show, :create]
  end

  resource :profile
  resource :uistate, controller: "ui_state"
  resource :contact, controller: "contact"

  %w(pricing amendment confirmation ticket_applications ticket_dollars).each do |report|
    match "/contracts/:contract_id/#{report}.pdf" => "contract/reports##{report}", as: "contract_#{report}_report", format: :pdf
  end

  match "/logout" => "sessions#destroy", as: :logout
  resource :session

  resource :login
  resource :password

  root to: "home#index", as: "home"
end
