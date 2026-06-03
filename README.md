# ListaDella App 📱

O **ListaDella** é um aplicativo mobile desenvolvido em Flutter focado no gerenciamento inteligente e seguro de listas de compras personalizadas. O aplicativo permite que os usuários criem listas, gerenciem produtos por categorias e acompanhem o estado de cada item (comprado ou não), oferecendo uma experiência fluida com sincronização em nuvem e um sistema robusto de autenticação e segurança local.

## 🚀 Tecnologias Utilizadas

O projeto foi construído utilizando as melhores práticas do ecossistema Flutter/Dart, destacando-se as seguintes bibliotecas e ferramentas:

* **[Flutter](https://flutter.dev/) & [Dart](https://dart.dev/):** Framework e linguagem base para o desenvolvimento multiplataforma nativo.
* **[Dio](https://pub.dev/packages/dio):** Cliente HTTP robusto para Dart, utilizado para realizar todas as requisições à API, configurado com interceptores customizados para manipulação proativa e retroativa de tokens de autenticação.
* **[flutter_dotenv](https://pub.dev/packages/flutter_dotenv):** Gerenciador de variáveis de ambiente, utilizado para proteger credenciais sensíveis e chaves de API, impedindo que dados críticos sejam expostos no repositório público.
* **[flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage):** Armazenamento local criptografado (Keychain para iOS e AES-criptografia para Android) para guardar de forma segura os tokens JWT, datas de expiração e credenciais de login do usuário.

## 🛠️ Arquitetura de Segurança Implementada

O aplicativo conta com uma camada avançada de segurança de rede:
- Antes de cada chamada à API, o app verifica a validade do token JWT armazenado no cofre seguro. Caso o token expire nos próximos 15 segundos, uma renovação proativa (*Refresh Token*) é disparada automaticamente antes de enviar a requisição original.
- Caso ocorra uma revogação inesperada do token pelo servidor (erros 401 ou 403), o interceptor captura a falha, renova o token em segundo plano e repete a requisição de forma transparente para o usuário.
- Nenhuma credencial de usuário ou token de acesso é salvo em texto limpo ou no `SharedPreferences` comum. Tudo reside no armazenamento criptografado do dispositivo.

---

## 💻 Passo a Passo para Rodar o Frontend Localmente

Siga as instruções abaixo para configurar o ambiente e executar o aplicativo na sua máquina local:

### 1. Pré-requisitos
Certifique-se de ter as seguintes ferramentas instaladas e configuradas no seu ambiente de desenvolvimento:
* **Flutter SDK** (versão estável mais recente)
* **Dart SDK**
* **Android Studio** / **VS Code** com as extensões do Flutter e Dart instaladas.
* Um emulador Android, simulador iOS ou dispositivo físico configurado com o modo de depuração USB ativado.

### 2. Clonar o Repositório
No seu terminal, clone o projeto para o seu diretório local:

```bash
git clone <URL_DO_SEU_REPOSITORIO>
cd listadella-app
flutter pub get
```

4. Configurar as Variáveis de Ambiente (.env)

Por questões de segurança, as chaves de acesso e a URL de produção não estão presentes no código-fonte. Você precisa criar o arquivo de configuração manualmente.

    Na raiz do projeto (no mesmo nível da pasta lib e do arquivo pubspec.yaml), crie um arquivo chamado exatamente .env.

    Abra o arquivo .env em seu editor e adicione as seguintes variáveis com suas respectivas chaves:

```bash
# URL base da API do servidor
API_BASE_URL=[https://lista***]

# Chave do cliente para autenticação OAuth2 (Password Grant)
CLIENT_ID=ts4l43***

# Usuário e senha para acesso do Bearer Token
USERNAME=caio_***
PASSWORD=99114***

```

5. Verificar a Declaração de Assets

Verifique se o arquivo .env está devidamente mapeado na seção de recursos do seu pubspec.yaml:

```bash
flutter:
  uses-material-design: true
  assets:
    - .env
```

6. Executar o Aplicativo

Com o emulador aberto ou o dispositivo físico conectado, execute o seguinte comando no terminal para iniciar o app:
```bash
flutter run
```