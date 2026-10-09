function uploadToS3(file) {
  return { success: true, file, location: 's3://bucket/path' };
}

module.exports = { uploadToS3 };
