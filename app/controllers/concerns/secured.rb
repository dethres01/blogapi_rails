module Secured
  def authenticate_user!
    #Bearer xxxxx
    token_regex = /Bearer (\w+)/
    #leer auth_header
    headers = request.headers
    #verificar que sea valido
    if headers['Authorization'].present? && headers['Authorization'].match(token_regex)
      token = headers['Authorization'].match(token_regex)[1]
      if(Current.user = User.find_by_auth_token(token))
        return 
      end
    end
    render json: {error: 'Unauthorized'}, status: :unauthorized
    #verificar que el token que extraemos corresponda a un usuario
  end
end