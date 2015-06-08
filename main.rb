require "rubygems"
require "active_record"
require 'nokogiri'
require 'open-uri'
require 'net/http'
require "bundler/setup"
Bundler.require
require "sinatra"

require File.expand_path('../db.rb', __FILE__)
require File.expand_path('../oi_models.rb', __FILE__)


#class UpdateRnc < Sinatra::Application #Only apply to production deployment as a rackup app, for dev purposes is a direct app not a class

get "/" do
  "<h2>THIS IS AN INTERNAL WS</h2>"
end

get "/updaternc" do
  {"params" => params}.to_json
  rnc = params[:rnc].to_s.strip
  updaternc(rnc)
end


def updaternc(rnc_toupdate)

  #Opening DB connection
  db = Dbutils.new
  db.connect


  rnc_length = rnc_toupdate.to_s.length
  rnc = rnc_toupdate.to_s.strip

  baseurl = "http://www.camarasantodomingo.do/"

  if rnc_length == 9
    str_rnc = rnc
    str_rnc = str_rnc.to_s.insert(1,"-").insert(4,"-").insert(10,"-")

    url = URI(baseurl+"red-empresarial/busqueda?st=rnc&ss="+str_rnc)

    response = Net::HTTP.get(url)

    dom = Nokogiri::HTML(response)
    link = dom.css('.re_resultados h3 > a')
    if link.empty?
      #puts "NO RECORD FOUND for #{rnc}"
    else
      urldetail = link[0]["href"].to_s.strip
      urldetail = URI(baseurl+urldetail)

      detail = Net::HTTP.get(urldetail)
      domdetail = Nokogiri::HTML(detail)

      company = company_date = company_phone = company_address = company_address1 = company_city = company_activity = company_sector = ""

      company = domdetail.css('div#red_profile_right_subcolumn h2')
      company = company.text
      linkdetail  = domdetail.css('div#red_profile p')
      for i  in 0..linkdetail.count

        if !linkdetail[i].nil?
          value = linkdetail[i].text.to_s.strip

          pos = value.index("Formaliza")
          if !pos.nil?
            company_date = linkdetail[i + 1].text.to_s.strip
          end
          pos = value.index("fono Primario")
          if !pos.nil?
            company_phone = linkdetail[i + 1].text.to_s.strip
          end
          pos = value.index("Direcci")
          if !pos.nil?
            company_address = linkdetail[i + 1].text.to_s.strip
            company_address = company_address.gsub(/"<br>"/,"\n")
            company_address = company_address.split(/\n/)
            company_address1 = company_address[0]
            company_city = company_address[1].to_s.strip
          end
          pos = value.index("Productos y Servicios")
          if !pos.nil?
            company_activity = linkdetail[i + 1].text.to_s.strip
          end

          pos = value.index("<strong>Sector</strong>")
          if !pos.nil?
            company_sector = linkdetail[i + 1].text.to_s.strip
          end

        end


      end

=begin
      puts company + "\n"
      puts company_date + "\n"
      puts company_phone + "\n"
      puts company_address1 + "\n"
      puts company_city + "\n"
      puts company_activity + "\n"
      puts company_sector + "\n"
=end

      #Check is exist in dgii_rnc table
      dgii_rnc = DgiiRnc.find(:first, :conditions => {:rnc_cedula => rnc_toupdate.to_s.strip})
      if !dgii_rnc.nil?
        rec_id = dgii_rnc.dni_numtrans.to_s
        DgiiRnc.update(rec_id,:nombrecomercial => company, :actividadeconomica => company_activity, :direccion => company_address1,
        :urbanizacion => company_sector, :telefono => company_phone, :fechaconstitucion => company_date, :ciudad => company_city)
      else
        dgii_new = DgiiRnc.new
        dgii_new.rnc_cedula = rnc_toupdate.to_s.strip
        dgii_new.nombre_razonsocial = company
        dgii_new.nombrecomercial = company
        dgii_new.actividadeconomica = company_activity
        dgii_new.direccion = company_address1
        dgii_new.urbanizacion = company_sector
        dgii_new.telefono = company_phone
        dgii_new.fechaconstitucion = company_date
        dgii_new.estatus = "N/D"
        dgii_new.ciudad = company_city
        dgii_new.save
      end


    end


  end


end

#end


