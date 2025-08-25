class Website < ApplicationRecord
	# Associations
	has_many :documents, dependent: :destroy

	# Validations
	validates :url, presence: true, uniqueness: true
end
