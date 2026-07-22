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
    tempfile = Tempfile.new([ "oversized", ".jpg" ], binmode: true)
    tempfile.write(SecureRandom.random_bytes(11.megabytes))
    tempfile.rewind

    Rack::Test::UploadedFile.new(tempfile.path, "image/jpeg")
  end
end
