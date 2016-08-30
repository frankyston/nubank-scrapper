require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'

class Titulo
  attr_accessor :data, :descricao, :valor
end

class NubankHelper
  include Capybara::DSL
  def initialize(user,password)
    Capybara.default_driver = :poltergeist
    Capybara.javascript_driver = :poltergeist
    Capybara.run_server = false
    Capybara.app_host = 'http://www.google.com'
    visit_login_page
    login(user,password)
  end

  def pega_cobrancas
    visit_faturas

    cobrancas = page.all('#content_tab_005 > div > div.charges.medium-8.column > div.charges-list.ng-scope.ng-isolate-scope > div')
    titulos = Array.new

    cobrancas.each do |cob|
      titulo = Titulo.new
      titulo.data       = cob.find(:css,'div.time > div > span').text
      begin
        titulo.descricao  = cob.find(:css,'div.charge-data > div.description.ng-binding').text
        titulo.valor      = cob.find(:css,'div.charge-data > div.amount.ng-binding').text
      rescue
        titulo.descricao  = cob.find(:css,'div.charge-data.credit > div.description.ng-binding').text
        titulo.valor      = cob.find(:css,'div.charge-data.credit > div.amount.ng-binding').text
      end
      titulos << titulo
    end

    return titulos
  end

  private

  def visit_login_page
    visit "https://www.nubank.com.br"
    click_link('Login')
  end

  def login(user,password)
    # Usuario
    fill_in('username',with: user)
    # Senha
    fill_in('input_001',with: password)
    btn = find("button", text: /\Aentrar\z/)
    btn.click
  end

  def visit_faturas
    link = page.find_link('Faturas')
    link.click
  end
end
