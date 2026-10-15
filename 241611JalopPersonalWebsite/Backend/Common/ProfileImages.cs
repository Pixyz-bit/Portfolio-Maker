using System;
using System.IO;
using System.Web;
using System.Windows.Media.Imaging;

namespace _241611JalopPersonalWebsite.Backend.Common
{
    public static class ProfileImages
    {
        public static string Save(HttpPostedFile file, int userId, string uploadDirectory)
        {
            return Save(file.InputStream, file.FileName, file.ContentLength, userId, uploadDirectory);
        }

        public static string Save(Stream content, string fileName, long contentLength, int userId, string uploadDirectory)
        {
            string extension = Path.GetExtension(fileName).ToLowerInvariant();
            if (extension != ".jpg" && extension != ".jpeg" && extension != ".png" && extension != ".webp")
                throw new ArgumentException("Upload a JPEG, PNG, or WebP image.");
            if (contentLength <= 0 || contentLength > 2 * 1024 * 1024)
                throw new ArgumentException("Profile picture must be a nonempty image no larger than 2 MB.");
            string savedFile = null;
            try
            {
                using (var input = new MemoryStream())
                {
                    content.CopyTo(input);
                    input.Position = 0;
                    // WIC decodes the bytes; the uploaded extension is not evidence of image content.
                    var decoder = BitmapDecoder.Create(input, BitmapCreateOptions.PreservePixelFormat, BitmapCacheOption.OnDemand);
                    string extensions = decoder.CodecInfo.FileExtensions.ToLowerInvariant();
                    if (!(decoder is JpegBitmapDecoder) && !(decoder is PngBitmapDecoder) && !extensions.Contains(".webp"))
                        throw new ArgumentException("Only JPEG, PNG, and WebP image content is supported.");
                    if (decoder.Frames.Count != 1) throw new ArgumentException("Upload a single, nonanimated profile picture.");
                    var frame = decoder.Frames[0];
                    if (frame.PixelWidth < 1 || frame.PixelHeight < 1 || frame.PixelWidth > 4096 || frame.PixelHeight > 4096)
                        throw new ArgumentException("Profile pictures must be at most 4096 × 4096 pixels.");
                    // Re-encode to PNG, stripping uploaded metadata, extra chunks and appended payloads.
                    var encoder = new PngBitmapEncoder();
                    encoder.Frames.Add(BitmapFrame.Create(frame));
                    Directory.CreateDirectory(uploadDirectory);
                    string name = "user_" + userId + "_" + Guid.NewGuid().ToString("N") + ".png";
                    savedFile = Path.Combine(uploadDirectory, name);
                    using (var output = File.Create(savedFile)) encoder.Save(output);
                    return "~/Uploads/Profiles/" + name;
                }
            }
            catch (ArgumentException) { if (savedFile != null) DeleteFile(savedFile); throw; }
            catch (Exception ex)
            {
                if (savedFile != null) DeleteFile(savedFile);
                System.Diagnostics.Trace.TraceWarning("Image decoding failed: {0}", ex);
                throw new ArgumentException("The image could not be decoded. Try a valid JPEG or PNG image.");
            }
        }

        public static void Delete(string storedPath, string uploadDirectory)
        {
            if (string.IsNullOrEmpty(InputSafety.SafeImageUrl(storedPath))) return;
            string root = Path.GetFullPath(uploadDirectory).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            string target = Path.GetFullPath(Path.Combine(root, Path.GetFileName(storedPath)));
            if (target.StartsWith(root, StringComparison.OrdinalIgnoreCase)) DeleteFile(target);
        }

        private static void DeleteFile(string file)
        {
            try { if (File.Exists(file)) File.Delete(file); }
            catch (Exception ex) { System.Diagnostics.Trace.TraceWarning("Unused image cleanup failed: {0}", ex); }
        }
    }
}
