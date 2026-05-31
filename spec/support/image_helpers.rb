module ImageHelpers
  def valid_image
    Rack::Test::UploadedFile.new(
      Rails.root.join("spec/fixtures/files/test.jpg"),
      "image/jpeg"
    )
  end

  def invalid_file
    Rack::Test::UploadedFile.new(
      Rails.root.join("spec/fixtures/files/test.pdf"),
      "application/pdf"
    )
  end

  def oversized_file
    Rack::Test::UploadedFile.new(
      Rails.root.join("spec/fixtures/files/oversized.jpg"),
      "image/jpeg"
    )
  end
end
