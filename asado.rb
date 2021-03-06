require 'sinatra'#1.4.8
require 'data_mapper'

DataMapper.setup(:default, 'sqlite:db/development.db')
DataMapper::Logger.new($stdout, :debug)

class Evento
  include DataMapper::Resource
  property :id, Serial
  property :fecha, Date
  property :nombre, String
  property :total, Float #% p/persona

  has n, :personas 
  has n, :gastos
end

class Persona
  include DataMapper::Resource
  property :id, Serial
  property :nombre, String
  
  belongs_to :evento
  has n, :gastos
end

class Producto 
  include DataMapper::Resource
  property :id, Serial
  property :nombre, String

  belongs_to :gasto
end

class Gasto
  include DataMapper::Resource
  property :id, Serial
  property :monto, Integer #total de lo gastado
  property :observacion, String

  has 1, :producto
  belongs_to :persona
  belongs_to :evento
end

Evento.auto_upgrade!
Persona.auto_upgrade!
Producto.auto_upgrade!
Gasto.auto_upgrade!

DataMapper.finalize

get '/' do
  haml :index
end

get '/productos' do
  @productos = Producto.all
  haml :productos
end

get '/eventos' do
  @eventos = Evento.all
  haml :evento
end

get '/personas' do
  haml :personas
end


get '/calculo/:id_evento' do
  @el_evento = Evento.get(params[:id_evento])
  @integrantes = Persona.all('evento.id' => params[:id_evento])
  p @integrantes
  haml :calculo
end


#create

post '/evento/create' do
  evento = Evento.new
  evento.fecha = params[:fecha]
  evento.nombre = params[:nombre]
  evento.save
  redirect "/calculo/#{evento.id}"
end

post '/persona/create/:id_evento' do
  evento = Evento.get(params[:id_evento])
  persona = Persona.new
  persona.nombre = params[:nombre]
  evento.personas << persona
  #persona.save
  evento.save
  redirect "/calculo/#{evento.id}"
end

post '/producto/create' do
  producto = Producto.new
  producto.nombre = params[:nombre]
  p producto
  if (producto.save)
    redirect "/productos"
  else
    p 'algo salio mal'
  end
end

post '/gasto/create/:id_evento/:id_persona/:id_producto' do
  producto = Producto.get(params[:id_producto])
  persona = Persona.get(params[:id_persona])
  evento = Evento.get(params[:id_evento])
  gasto = Gasto.new
  gasto.monto = params[:monto]
  gasto.observacion = params[:observacion]
  producto.gasto << gasto
  producto.save
  persona.gastos << gasto
  persona.save
  evento.gastos << gasto
  evento.save
  redirect "/"
end

#update

get '/evento/update/:id_evento' do 
  @evento_update = Evento.get(params[:id_evento])
  haml :'evento/update'
end 
post '/evento/update/:id_evento' do
  @evento_update = Evento.get(params[:id_evento])
  @evento_update.fecha = params[:fecha]
  @evento_update.nombre = params [:nombre]
  @evento_update.total = params [:total]
  @evento_update.save
  redirect "/"
end

get '/persona/update/:id_persona' do 
  @persona_update = Persona.get(params[:id_persona])
  haml :'persona/update'
end 
post '/persona/update/:id_persona' do
  @persona_update = Persona.get(params[:id_persona])
  @persona_update.nombre = params[:nombre]
  @persona_update.save
end

get '/producto/update/:id_producto' do 
  @producto_update = Producto.get(params[:id_producto])
  haml :'producto/update'
end 

post '/producto/update/:id_producto' do
  @producto_update = Producto.get(params[:id_producto])
  @producto_update.nombre = params[:nombre]
  @producto_update.save
  redirect '/'
end

#delete

get '/evento/delete/:id_evento' do
  Evento.get(params[:id_evento]).destroy
  redirect "/eventos"
end

get '/persona/delete/:id_persona' do
  @persona = Persona.get(params[:id_persona])
  p @persona 
  Persona.get(params[:id_persona]).destroy
  redirect "/calculo/#{@persona.evento_id}"
end

get '/producto/delete/:id_producto' do
  Producto.get(params[:id_producto]).destroy
  redirect "/"
end

get '/gasto/delete/:id_gasto' do
  Gasto.get(params[:id_gasto]).destroy
  redirect "/"
end

#list

get '/evento/detail/:id_evento' do
  @un_evento = Evento.get(params[:id_evento])
  haml :'evento/detail' 
end

get '/persona_detail/:id_persona' do
  @una_persona = Persona.get(params[:id_persona])
  haml :'persona/detail'
end

