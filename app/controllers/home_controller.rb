class HomeController < ActionController::Base
  protect_from_forgery
  
  def index   
		# este código es para adquirir el token. Los valores del token se adquieren desde la aplicación
		# sin necesidad de estar autenticado.  
		# session[:oauth] es un objeto OAuth al que le pasamos los datos de nuestra aplicación Facebook
		# el último parametro especifica la url donde se redireccionará al usuario una vez autenticados. 
		# Esta función no autentica al usuario ni conecta con facebook, solo inicializa variables. 
		session[:oauth] = Koala::Facebook::OAuth.new(APP_ID, APP_SECRET, SITE_URL + '/home/callback')
		puts "Session: "
		puts "******************************************************************"
		puts session.to_s	
		puts "******************************************************************"

		# @auth_url es la URL donde iremos al hacer clic en el botón de index.html.erb
		# Una vez accedamos a esta URL, si no estamos loggeados, facebook nos lo pedirá. 
		# Le daremos los permisos que se especifican en los params de url_for_oauth_code
		# Ya autenticados, Facebook nos redireccionará a la URL especificada al crear el objeto session[:oauth].
		@auth_url =  session[:oauth].url_for_oauth_code(:permissions=>"read_stream, publish_stream") 	
		puts @auth_url
		puts "******************************************************************"

  	respond_to do |format|
			 format.html {  }
		end
	
   end

	def callback
		# la variable params creo que es una variable global de rails. Tiene los siguientes valores:
		# code: un extraño código
		# controller: "home" es el nombre del controlador
		# action: "callback" es el nombre de este método del controlador HomeController
		puts params.to_s
		puts "******************************************************************"
	
 	if params[:code]
  		# acknowledge code and get access token from FB
			# AQUÍ es donde realmente empieza nuestra app a trabajar con facebook
			# recogemos nuestro token y ya estamos listos para pedirle a facebook lo que necesitemos
		  session[:access_token] = session[:oauth].get_access_token(params[:code])
		end		

		 # auth established, now do a graph call:
		@graph = Koala::Facebook::API.new(session[:access_token])

		puts "empieza lento...."
		begin
			@graph_data = @graph.get_object("/me/statuses", "fields"=>"message")
			@profile = @graph.graph_call("cocacola", {}, "get")
			puts @profile
		rescue Exception=>ex
			puts ex.message
		end



=begin
		begin
			@api.put_wall_post("RubyonRails(put_wall_post): probando, probando!")	
		rescue Exception=>ops
			puts ops.message
		end
=end


=begin
		begin
			my_fql_query = "SELECT uid2 from friend where uid1=me()"
			fql = @graph.fql_query(my_fql_query)
		#@api.put_wall_post(process_result(fql))
			puts fql.inspect
		rescue Exception=>ops
			puts ops.message
		end

 		respond_to do |format|
		 format.html {   }			 
		end
=end		
	
	end
end

