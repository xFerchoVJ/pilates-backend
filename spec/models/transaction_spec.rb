require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      transaction = build(:transaction)
      expect(transaction).to be_valid
    end

    it 'is not valid without a transaction type' do
      transaction = build(:transaction, transaction_type: nil)
      expect(transaction).not_to be_valid
    end

    it 'is not valid with an amount less than or equal to 0' do
      transaction = build(:transaction, amount: 0)
      expect(transaction).not_to be_valid
    end

    it 'requires a status' do
      transaction = build(:transaction, status: nil)
      expect(transaction).not_to be_valid
    end

    it 'allows multiple transactions with the same reference_id' do
      reference_id = 5
      create(:transaction, reference_id:)
      duplicate = build(:transaction, reference_id:)
      expect(duplicate).to be_valid
    end
  end

  describe 'enums' do
    it 'has the defined statuses correctly' do
      expect(Transaction.statuses.keys).to contain_exactly('pending', 'succeeded', 'failed', 'refunded')
    end
  end
end
