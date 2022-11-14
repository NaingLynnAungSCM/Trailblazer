module Post::Contract
  class Update < Reform::Form
    include Sync::SkipUnchanged
    property :title
    property :description
    property :privacy
    property :user_id
    property :image, virtual: true
    property :public_schedule
    property :private_schedule

    validates :image, allow_blank: true, file_size: {less_than: 2.megabytes},
                                    file_content_type: {allow: ['image/jpeg', 'image/png', 'image/webp']}
    validates :title, presence: true, length: { maximum: 30 }
    validates :description, presence: true
    validates :privacy, presence: true
    validate :image_limit
    validate :ban_keyword

    def image_limit
      if image.present?
        errors.add(:image, "can't accept more than 4 images") if image.length > 4
      end
    end

    def ban_keyword
      ban_title = Keyword.where(name: title.split)
      ban_char = []
      ban_title.each do |char|
        ban_char.append(char.name)
      end
      errors.add(:title, "can't be use this keyword. This #{ban_char.join(", ").upcase} keywords had banned in our services.") if ban_title.present?
      ban_desc = Keyword.where(name: description.split)
      ban_desc_char = []
      ban_desc.each do |char|
        ban_desc_char.append(char.name)
      end
      errors.add(:description, "can't be use this keyword. This #{ban_desc_char.join(", ").upcase} keywords had banned in our services.") if ban_desc.present?
    end
  end
end
