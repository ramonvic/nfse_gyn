module NfseGyn
  class MockGerarNfseResponse < NfseGyn::GerarNfse::Response
    def initialize(request)
      super(nil)
      @request = request
    end

    def content
      {
        'ListaNfse' => {
          'CompNfse' => {
            'Nfse' => {
              'InfNfse' => {
                'Numero' => '370',
                'CodigoVerificacao' => 'MB94-C3ZA',
                'DataEmissao' => @request[:data_emissao],
                'OutrasInformacoes' => 'OUTRAS INFORMACOES SOBRE O SERVICO.',
                'ValoresNfse' => {
                  'BaseCalculo' => '0',
                  'Aliquota' => '5',
                  'ValorIss' => '0'
                }, 'DeclaracaoPrestacaoServico' => {
                  'IdentificacaoRps' => {
                    'Numero' => '14',
                    'Serie' => 'UNICA',
                    'Tipo' => '1'
                  },
                  'DataEmissao' => @request[:data_emissao],
                  'Competencia' => @request[:data_emissao],
                  'Servico' => {
                    'Valores' => {
                      'ValorServicos' => @request[:total],
                      'ValorDeducoes' => '0',
                      'ValorPis' => '0.00',
                      'ValorCofins' => '0.00',
                      'ValorInss' => '0.00',
                      'ValorIr' => '0.00',
                      'ValorCsll' => '0.00',
                      'ValorIss' => '0',
                      'Aliquota' => '5',
                      'DescontoIncondicionado' => '0.00'
                    },
                    'IssRetido' => '2',
                    'CodigoTributacaoMunicipio' => '791120000',
                    'Discriminacao' => @request[:description],
                    'CodigoMunicipio' => '0025300',
                    'ExigibilidadeISS' => '1',
                    'MunicipioIncidencia' => '0025300'
                  }, 'Prestador' => {
                    'IdentificacaoPrestador' => {
                      'CpfCnpj' => {
                        'Cnpj' => NfseGyn.configuration.cnpj
                      }, 'InscricaoMunicipal' => NfseGyn.configuration.inscricao_municipal
                    }
                  }, 'Tomador' => {
                    'IdentificacaoTomador' => {
                      'CpfCnpj' => {
                        (@request[:customer][:document_type]).to_s => (@request[:customer][:document_number]).to_s
                      }
                    },
                    'RazaoSocial' => @request[:customer][:name],
                    'Endereco' => {
                      'Endereco' => 'RUA DAS AMENDOEIRAS',
                      'Numero' => '30',
                      'Complemento' => 'LOTE 4',
                      'Bairro' => 'CENTRO',
                      'CodigoMunicipio' => '0025300',
                      'Uf' => 'GO',
                      'Cep' => '74823350'
                    }
                  }, 'OptanteSimplesNacional' => '2'
                }
              }
            }
          }
        }, 'ListaMensagemRetorno' => {
          'MensagemRetorno' => {
            'Codigo' => 'L000',
            'Mensagem' => 'NORMAL'
          }
        }
      }
    end
  end
end
