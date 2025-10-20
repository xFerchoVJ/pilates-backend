Rswag::Api.configure do |c|
  # Define la ruta base donde se guardan tus specs Swagger
  c.swagger_root = Rails.root.join("swagger").to_s

  # Configura las rutas de tus documentos Swagger
  c.swagger_filter = lambda { |swagger, env| swagger["host"] = env["HTTP_HOST"] }
end
