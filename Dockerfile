# image name com versao especifica. POde ser consultado em hub.docker.com
FROM python:3.9-alpine3.13
LABEL maintainer="Ana Cândida Quadros"

#nao armazena o buffer do python em memoria. Utilizado para nao armazenar em memoria e sim em disco
ENV PYTHONUNBUFFERED 1
#espelha essa pasta para dentro do container. Copia o arquivo requirements.txt para dentro do container
COPY ./requirements.txt /requirements.txt
COPY ./requirements.dev.txt /requirements.dev.txt

COPY ./app /app
#define o diretorio de trabalho, da onde os comandos serao executados quando forem executados dentro do container. Home do container
WORKDIR /app
#expoe a porta 8000 do container para a maquina local
EXPOSE 8000

ARG DEV= False
#um bloco de comandos run cria apenas 1 camada de image. se eu rodar eles separados, cria uma camada para cada comando.
#cria um ambiente virtual python dentro do container. Adicional para nao dar conflito com pacotes da imagem e do app
#remove a pasta temp, para deixar a imagem mais leve
#adiciona um usuario 'django-user'.nao permite que o usuario tenha senha e nem cria uma home. evita usar o root como usuario dentro do container por seguranca
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --upgrade --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
    build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /requirements.txt && \
    if [ "$DEV" = "True" ] ; then /py/bin/pip install -r /requirements.dev.txt; fi && \
    rm -rf /temp && \
    apk del .tmp-build-deps && \
    adduser \
    --disabled-password \
    --no-create-home \
    django-user
#define o path do python dentro do container da variavel de ambiente PATH
ENV PATH="/py/bin:$PATH"

#define o usuario que vai executar os comandos dentro do container. antes era o root, agora é o django-user.
USER django-user