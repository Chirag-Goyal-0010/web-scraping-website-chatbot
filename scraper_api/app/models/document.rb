class Document < ApplicationRecord
	# Associations
	belongs_to :website

	# Validations
	validates :content, presence: true
end
