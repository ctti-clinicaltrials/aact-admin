class UseCase < ActiveRecord::Base
  has_many :use_case_attachments, :dependent => :destroy
  has_many :use_case_publications, :dependent => :destroy
  has_many :use_case_datasets, :dependent => :destroy
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |uc|
        csv << uc.attributes.values_at(*column_names)
      end
    end
  end

  def initialize(params = {})
    if params
      file = params.delete(:file)
      image_file = params.delete(:image_file)
    end
    super
    self.attachments << UseCaseAttachment.create_from(file) if file and attachment.nil?
    self.attachments << UseCaseAttachment.create_from(image_file,'image') if image_file and image.nil?
    self
  end

  def update(params = {})
    file = params.delete(:file)
    image_file = params.delete('image_file')
    self.use_case_attachments = []
    self.attachments << UseCaseAttachment.create_from(file) if file
    self.attachments << UseCaseAttachment.create_from(image_file,'image') if image_file
    super
    self
  end

  def current_image_file_name
    image.try(:file_name)
  end

  def current_attachment_file_name
    attachment.try(:file_name)
  end

  def file
    attachment.try(:file_name)
  end

  def linkable_url
    return nil if self.url.blank?
    if self.url.match(/^http:\/\//) or self.url.match(/^https:\/\//)
      self.url
    else
      "http://#{self.url}"
    end
  end

  def attachments
    use_case_attachments
  end

  def attachment
    attachments.select{|uca|!uca.is_image}.first
  end

  def image
    attachments.select{|uca|uca.is_image}.first
  end

end
