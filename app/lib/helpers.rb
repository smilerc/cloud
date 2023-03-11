require 'open-uri'
require 'net/http'

module TSX
  module Helpers

    Array.class_eval do
      def paginate(page = 1, per_page = 15)
        WillPaginate::Collection.create(page, per_page, size) do |pager|
          pager.replace self[pager.offset, pager.per_page].to_a
        end
      end
    end

    def cnt_bold(c)
      "#{c}"
    end

    def kladov(cnt)
      "#{cnt_bold(cnt)} #{Russian.p(cnt, "клад", "клада", "кладов")}"
    end

    def botov(cnt)
      "#{cnt_bold(cnt)} #{Russian.p(cnt, "бот", "бота", "ботов")}"
    end

    def shopov(cnt)
      "#{cnt_bold(cnt)} #{Russian.p(cnt, "шоп", "шопа", "шопов")}"
    end

    def ludey(cnt)
      "#{cnt_bold(cnt)} #{Russian.p(cnt, "человек", "человека", "людей")}"
    end

    def otzivov(cnt)
      "#{cnt_bold(cnt)} #{Russian.p(cnt, "отзыв", "отзыва", "отзывов")}"
    end

    def postov(cnt)
      "#{cnt_bold(cnt)} #{Russian.p(cnt, "пост", "поста", "постов")}"
    end

    def dney(cnt)
      "#{cnt_bold(cnt)} #{Russian.p(cnt, "день", "дня", "дней")}"
    end

    def stranic(cnt)
      "#{cnt_bold(cnt)} #{Russian.p(cnt, "страница", "страницы", "страниц")}"
    end


    def zaprosov(cnt)
      "#{cnt_bold(cnt)} #{Russian.p(cnt, "запрос", "запроса", "запросов")}"
    end

    def klientov(cnt)
      "#{cnt_bold(cnt)} #{Russian.p(cnt, "клиент", "клиента", "клиентов")}"
    end

    def magazinov(cnt)
      "#{cnt_bold(cnt)} #{Russian.p(cnt, "магазин", "магазина", "магазинов")}"
    end

    def chasov(cnt)
      "#{cnt_bold(cnt)} #{Russian.p(cnt, "час", "часа", "часов")}"
    end

    def minut(cnt)
      "#{cnt_bold(cnt)} #{Russian.p(cnt, "минута", "минуты", "минут", "минут")}"
    end

    def prodazh(cnt)
      "#{cnt_bold(cnt)} #{Russian.p(cnt, "продажа", "продажи", "продаж", "продаж")}"
    end

    def gorodov(cnt)
      "#{cnt_bold(cnt)} #{Russian.p(cnt, "город", "города", "городов", "городов")}"
    end

    def prodazh_bold(cnt)
      "<b class='slab'>#{cnt_bold(cnt)}</b> #{Russian.p(cnt, "продажа", "продажи", "продаж", "продаж")}"
    end

    def pagina(collection)
      options = {
          #renderer: BootstrapPagination::Sinatra,
          class: 'pagination',
          inner_window: 4,
          outer_window: 2,
          page_links: false,
          previous_label: icn('arrow_left'),
          next_label: icn('arrow_right'),
          param_name: :p,
          container: true
      }
      will_paginate collection, options
    end

    def icn(code, big = "emoji")
      Twemoji.parse(":#{code}:", class_name: big)
    end

    def icon(code, text = '')
      unic = Twemoji.find_by_text(":#{code}:")
      if unic
        "#{Twemoji.render_unicode(unic)} #{text}"
      else
        icon('white_small_square', text)
      end
    end

    def icon_unicode(code)
      ccc = Twemoji.find_by(code: code)
      Twemoji.render_unicode ccc
    end


    def docs(chapter, limit = 5)
      str = ""
      begin
        contents = YAML.load_file("#{ROOT}/app/views/docs/#{chapter}.yml")
        str << "<div class=\"container-fluid p-0 pt-5\"><div class=\"row justify-content-center\"><div class=\"col\"><div class=\"accordion\" id=\"accordionQuestions\">"
        contents.each do |link|
          puts "#{link.inspect}"
          str << "<div class=\"accordion-item bg-white rounded-3 shadow mb-2\"><h3 class=\"accordion-header\" id=\"heading#{link[0]}\"><button aria-controls=\"collapse#{link[0]}\" aria-expanded=\"false\" class=\"accordion-button fs-4 fw-bold collapsed\" data-bs-target=\"#collapse#{link[0]}\" data-bs-toggle=\"collapse\" type=\"button\">"
          str << link[1]['title']
          str << "<i aria-hidden=\"true\" class=\"fas fa-chevron-down\"></i></button></h3>"
          str << "<div aria-labelledby=\"heading#{link[0]}\" class=\"accordion-collapse collapse\" data-bs-parent=\"#accordionQuestions\" id=\"collapse#{link[0]}\" style=""><div class=\"accordion-body\"><ul class=\"mb-0\">"
          str << link[1]['text']
          str << "</ul></div></div></div>"
        end
      rescue Errno::ENOENT
        str = "Такого раздела документации не существует"
      end
      puts str
      str
    end

    def photo?(url)
      return true
      begin
        res = Faraday.get(url)
        # warn "RESP STATUS"
        # warn res.response.inspect
        res.status == 200
      rescue
        false
      end
    end

    def location(url)
      "location.href='#{url(url)}'"
    end

    def current_locale
      I18n.locale
    end

    def human_date(d)
      d.nil? ? 'n/a' : d.to_time.strftime("%b %d, %Y")
    end

    def human_date_short(d)
      d.nil? ? 'n/a' : d.to_time.strftime("%b %d")
    end

    def human_time(d)
      d.nil? ? 'n/a' : d.to_time.strftime("%H:%M")
    end

    def calc_commission(amount, comm)
      (amount * (comm.to_f/100)).round
    end

    def t(key, options = nil)
      I18n.translate(key, options)
    end

    def webrec(action, params = '')
      rec('web', hb_operator, hb_bot, action, params)
    end

    def botrec(action, params = '')
      rec('bot', hb_client, @tsx_bot, action, params)
    end

    def client_rec(client, action, params = '')
      rec('bot', client, @tsx_bot, action, params)
    end

    def rec(init = 'unknown', cl, b, action, params)
      Rec.create(
          initiator: init.to_s,
          client: cl.nil? ? '' : cl.id,
          bot: b.nil? ? '' : b.id,
          action: action,
          params: params,
          logged: Time.now
      )
    end

    def ago(dat)
      distance_of_time_in_words(Time.now, dat)
    end

    def lg (text)
      puts text.colorize(:light_white)
    end

    def blue(text)
      puts text.colorize(:blue)
    end

    def cy(text)
      puts text.colorize(:cyan)
    end

    def warn(text)
      puts text.colorize(:red)
    end

    def deb(text)
      puts text.colorize(:light_white)
    end

    def tem(text)
      puts text.colorize(:green)
    end

    def hb_client
      session['tsx_logged_id'].nil? ? nil : session['tsx_logged_id']
    end

    def hb_client_login
      session['tsx_logged_login'].nil? ? nil : session['tsx_logged_login']
    end


    def usd(cents)
      "$#{(cents.to_f/100).round(2)}"
    end

    def usd_number(cents)
      "#{(cents.to_f/100).round(2)}"
    end

    def usd_color(cents)
      if cents < 0
        "<span class='red'>$#{(cents.to_f/100).round(2)}</span>"
      else
        usd(cents)
      end
    end

    def location(url)
      "location.href='#{url}'"
    end

    def next_filter
      puts gsess('ds_filter').inspect.cyan
      if gsess('ds_filter').instance_of?(Country)
        return 'City'
      end
      if gsess('ds_filter').instance_of?(City)
        return 'Product'
      end
      if gsess('ds_filter').instance_of?(Product)
        return 'District'
      end
      if gsess('ds_filter').instance_of?(District)
        return 'show'
      end
    end

    def gsess(key)
      session["#{key}"]
    end

    def ssess(key, value)
      session["#{key}"] = value
    end

    def hb_currency
      session["TSX_CURRENCY"]
    end

    def hb_currency_label
      session["TSX_CURRENCY_LABEL"]
    end

    def hb_btc_system
      session["TSX_BTC_SYSTEM"] || 'не установлено'
    end

    def hb_btc
      session["TSX_BTC"] || 'не установлено'
    end

    def get_domain_from_url(url)
      uri = URI.parse(url)
      domain = PublicSuffix.parse(uri.host)
      domain.domain
    end

    def hb_bot
      if defined?(env)
        if env['rack.session']['_bot'].instance_of?(Bot)
          env['rack.session']['_bot']
        else
          Bot[env['rack.session']['_bot']] || false
        end
      else
        false
      end
    end

    def hb_bene
      if defined?(env)
        if env['rack.session']['_beneficiary'].instance_of?(Client)
         env['rack.session']['_beneficiary']
        else
          Client[env['rack.session']['_beneficiary']] || false
        end
      else
        false
      end
    end

    def hb_operator
      env['rack.session']['_operator'] || false
    end

    def hb_layout
      :"web/layouts/face"
    end

    def hb_tbr_layout
      !hb_bot ? :"layouts/tbr_not_logged" : :"layouts/tbr_logged"
    end

    def register(role = Client::HB_ROLE_USER)
      bot = Bot::escrow
      pin = Time.now.to_i.to_s
      new_client = Client.create(bot: bot.id, tele: pin, username: pin, role: role)
      hashids = Hashids.new(TOKEN_SALT, 40, TOKEN_ALPHABET)
      @hash = hashids.encode(bot.id, pin.to_i, new_client.id, Client::HB_ROLE_USER)
      Team.create(bot: bot.id, client: new_client.id, role: Client::HB_ROLE_USER, password: pin, token: @hash)
      new_client
    end

    def show_flash
      if flash.count > 0
        lines = "<span class='flash'>"
        lines << "#{flash.first.last}"
        lines << "</span>"
      end
    end

    def login!(client)
      bot = Bot[client.bot]
      bene = bot.beneficiary
      case client.role
        when Client::HB_ROLE_USER
          env['rack.session']['_role'] = 'user'
        when Client::HB_ROLE_OPERATOR
          env['rack.session']['_role'] = 'operator'
        when Client::HB_ROLE_ADMIN
          env['rack.session']['_role'] = 'admin'
        when Client::HB_ROLE_API
          env['rack.session']['_role'] = 'api'
        when Client::HB_ROLE_KLADMAN
          env['rack.session']['_role'] = 'kladman'
        when Client::HB_ROLE_KLADMAN
          env['rack.session']['_role'] = 'support'
      end
      env['rack.session']['_beneficiary'] = bene
      env['rack.session']['_bot'] = bot.id
      env['rack.session']['_operator'] = client
      rec('web', client, bot, 'Успешная авторизация', "#{client.inspect}")
    end


  end
end