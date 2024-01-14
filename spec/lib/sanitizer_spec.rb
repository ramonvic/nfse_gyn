require 'spec_helper'

RSpec.describe NfseGyn::Sanitizer do
  describe '#clear' do
    {
      'Descrição do Servico com vários caracteres especiais.' => 'Descricao do Servico com varios caracteres especiais',
      'Parque Amazônia,79 / Sala 313' => 'Parque Amazonia79  Sala 313'
    }.each do |dirty, clean|
      context "when #{dirty}" do
        subject { described_class.new(dirty).clear }
        it { is_expected.to eq clean }
      end
    end
  end
end
