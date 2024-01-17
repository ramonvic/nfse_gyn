# NFSeGyn

NFSeGyn é uma gem que visa a integração com o webservice SOAP da prefeitura de Goiânia para Gerar NFS-e (Nota Fiscal de Serviços Eletrônica)

### Operações Suportadas:
* *GerarNfse*
* *ConsultarNfseRps*

## Instalação

Adicione essa linha na Gemfile da sua aplicação:

```ruby
  gem 'nfse_gyn'
```
E então execute:

```bash
  bundle
```

Ou instale você mesmo, conforme abaixo:

```bash
  gem install nfse_gyn
```

## Como usar?

### Gerando os certificados necessários

```bash
# exportar o certificado apartir de *.pfx
$ openssl pkcs12 -in expired_certificate.pfx -clcerts -nokeys -out cert.crt

# converte o certificado .cer para o formato .pem
$ openssl x509 -in cert.crt -out cert.pem -outform PEM

 # exportar a chave privada apartir de *.pfx
$ openssl pkcs12 -in expired_certificate.pfx -nocerts -out cert_key.key
```

### Configurando os certificados

Crie um arquivo `config/initializers/nfse_gyn.rb` e adicione:

```ruby
NfseGyn.configure do |nfse|
  nfse.test_mode = true
  nfse.test_mode = true
  nfse.log_level = :none
  nfse.cnpj = '000000000000000'
  nfse.inscricao_municipal = '0000000'
  nfse.codigo_tributacao_municipio = '00000000'
  nfse.valor_aliquota    = 0
  nfse.cert_path         = '/path/to/certificate.pem'
  nfse.cert_key_path     = '/path/to/key.pem'
  nfse.cert_key_password = 'certificate_key_password'
end
```

### Criando uma NFS-e

```ruby
# valores a serem usados na NFSeGyn a ser gerada
nota_fiscal_info = {
  identification_number: '3033',
  description: 'Teste de RPS',
  data_emissao: '2024-01-11T23:33:22',
  total: 100.10,
  customer: {
    document_type: 'Cnpj',
    document_number: '98924674000187',
    name: 'XPTO Tecnologia Ltda',
    address: {
      street: 'Rua das Rosas',
      number: '111',
      complement: 'Sobre Loja',
      neighborhood: 'Centro',
      city_ibge_code: '0025300',
      state_code: 'GO',
      zipcode: '74672680'
    }
  }
}

# Operação GerarNfse
service = NfseGyn::GerarNfse.new(nota_fiscal_info)

# Operação ConsultarNfseRps
service = NfseGyn::ConsultarNfse.new(14, 'TESTE', 1)

response = service.execute!
```

## Testes

Para rodar os testes, execute:

```bash
  bundle exec rspec
```

## Contribuindo

1. Faça um Fork
2. Crie um branch para a nova funcionalidade (`git checkout -b minha-nova-funcionalidade`)
3. Faça o commit de suas alterações  (`git commit -am 'Adicionada nova funcionalidade'`)
4. Faça um push da sua nova funconalidade (`git push origin minha-nova-funcionalidade`)
5. Submeta uma nova Pull Request

## Creditos

Essa gem é baseada na gem [nfse-carioca](https://rubygems.org/gems/nfse-carioca)