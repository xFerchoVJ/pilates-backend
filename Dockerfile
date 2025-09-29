FROM ruby:3.1.4-slim

# Instalar dependencias del sistema
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    postgresql-client \
    git \
    curl \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*


# Establecer directorio de trabajo
WORKDIR /app

# Copiar Gemfile y Gemfile.lock primero (aprovechando cache de Docker)
COPY Gemfile Gemfile.lock ./

# Configuración bundler para cachear gems
RUN bundle config set --local path '/usr/local/bundle' \
    && bundle config set --local without ''  \
    && bundle config set --local build.nokogiri --use-system-libraries

# Instalar gems
RUN bundle install --jobs 4 --retry 3

# Copiar el resto del código de la app
COPY . .

# Crear directorios necesarios
RUN mkdir -p tmp/pids tmp/sockets log storage

# Dar permisos al entrypoint
RUN chmod +x bin/docker-entrypoint

# Exponer puerto
EXPOSE 3000

# Comando por defecto
CMD ["bin/docker-entrypoint"]
