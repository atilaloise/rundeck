# Rundeck Docker Image
Baseado na imagem [jordan/rundeck](https://hub.docker.com/r/jordan/rundeck) 

Projeto original by [jjethwa/rundeck](https://github.com/jjethwa/rundeck)

extended with ansible

Rundeck docker image extended with ansible
==============

Por ter se tornado uma imagem customizada para fins pessoais e profissionais, este projeto NÃO é um fork.

# Detalhes da imagem

1. Baseada na debian:stretch
2. Supervisor e rundeck
3. SSH pra acessar conteiner? Nem pensar! Use docker exec!
5. Informe o EXTERNAL_SERVER_URL ou será setado para  https://0.0.0.0:4443
6. Use por sua conta e risco!

# Automated build

```
docker pull atilaloise/rundeck
```

# Usage
Inicie um container e exponha a porta 4440

```
sudo docker run -p 4440:4440 -e EXTERNAL_SERVER_URL=http://MY.HOSTNAME.COM:4440 --name rundeck -t atilaloise/rundeck:latest
```

# SSL

Inicie um container com a porta 4443 exposta e habilite o ssh através da variavel de ambiente.

Atenção: Coloque seus certificados em `/etc/rundeck/ssl/keystore` e `/etc/rundeck/ssl/` para sistemas em produção. Por padrão serão gerados certificados autoassinados.

```
sudo docker run -p 4443:4443 -e EXTERNAL_SERVER_URL=https://MY.HOSTNAME.COM:4443 -e RUNDECK_WITH_SSL=true --name rundeck -t atilaloise/rundeck:latest
```

# Rundeck plugins

Para adicionar plugins externos, adicione os arquivos "jar" em /opt/rundeck-plugins. Os plugins serão instalados na inicialização do container.

# Docker secrets
Reference: https://docs.docker.com/engine/swarm/secrets/
São suportados nas variáveis de ambiente `RUNDECK_ADMIN_PASSWORD, RUNDECK_PASSWORD, DATABASE_ADMIN_PASSWORD, KEYSTORE_PASS e TRUSTSTORE_PASS`.  

# Environment variables

```
EXTERNAL_SERVER_URL - Url por onde o rundeck será acessado. Se o rundeck for acessado através de um load balancer, vip ou proxy reverso, informe o endereço que o usuário utilizará no navegador com a respectiva porta.

RDECK_JVM_SETTINGS - Parametros adicionais da configuração da JVM(ex: -Xmx1024m -Xms256m -XX:MaxMetaspaceSize=256m -server -Dfile.encoding=UTF-8 -Dserver.web.context=/rundeck)

DATABASE_DRIVER - Informe o driver a ser utilizado para conexão jdbc com o banco de dados.(ex: org.mariadb.jdbc.Driver)

DATABASE_URL - Url do banco de dados (ex: jdbc:mysql://<HOSTNAME>:<PORT>/rundeck)

RUNDECK_WITH_SSL - Habilita SSL

RUNDECK_USER - Usuário de acesso a base MySQL do rundeck

RUNDECK_PASSWORD - senha de acesso a base MySQL do rundeck

RUNDECK_ADMIN_PASSWORD - Senha de administração na Interface de usuário do rundeck

RUNDECK_STORAGE_PROVIDER - As opções são, file (default) ou db.  Detalhes em: http://rundeck.org/docs/plugins-user-guide/configuring.html#storage-plugins

RUNDECK_PROJECT_STORAGE_TYPE -  As opções são, file (default) ou db.  Detalhes em: http://rundeck.org/docs/administration/setting-up-an-rdb-datasource.html

RUNDECK_THREAD_COUNT = Numero de trheads par execução concorrente de jobs. Detalhes em: http://www.quartz-scheduler.org/documentation/quartz-2.x/configuration/ConfigThreadPool.html

SMTP_HOST - Configuração para notificações por e-mail.

SMTP_PORT - Configuração para notificações por e-mail

SMTP_USERNAME - Configuração para notificações por e-mail

SMTP_PASSWORD - Configuração para notificações por e-mail

SMTP_DEFAULT_FROM - Configuração para notificações por e-mail

SKIP_DATABASE_SETUP - Setar para false caso queira que o conteiner provisione o banco de dados e dê as permissões para o usuário configurado em "RUNDECK_USER"
```

# Volumes

```
/tmp/rundeck/ssh - Caso deseje configurar chaves ssh ou arquivos de configuração durante a inicialização do conteiner, coloque-os nesse volume. 

/tmp/rundeck/ACLS - Caso queira sobrescrever ou copiar qualquer arquivo para /etc/rundeck durante a inicialização do conteiner, coloque-os nesse volume.

/etc/rundeck - Persistencia de Arquivos de configuração do rundeck.

/etc/locale.gen - Arquivo com locales que deve ser gerados na inicialização do conteiner.

/var/lib/rundeck - Não recomendado para uso em volumes, pois contém o webapp. Para persistir as chaves ssh monte o volume: /var/lib/rundeck/.ssh

/var/log/rundeck - Logs, Logs, Logs.

/opt/rundeck-plugins - Para adicionar plugins externos durante a inicialização do conteiner

/var/lib/rundeck/logs - Mais logs.

/var/lib/rundeck/var/storage - Caso utilize o modo "file" para project storage, serão persistidos aqui. Monte esse volume caso for usar o plugin de SCM pois os arquivos ".git" ficam nesse diretório.

```