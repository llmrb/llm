# frozen_string_literal: true

##
# @private
class LLM::Mime
  ##
  # Lookup a mime type
  # @return [String, nil]
  def self.[](key)
    key = key.respond_to?(:path) ? File.extname(key.path) : key
    types[key] || "application/octet-stream"
  end

  ##
  # Returns a Hash of mime types
  # @return [Hash]
  def self.types
    @types ||= {
      # Images
      ".png" => "image/png",
      ".jpg" => "image/jpeg",
      ".jpeg" => "image/jpeg",
      ".webp" => "image/webp",
      ".gif"  => "image/gif",
      ".bmp"  => "image/bmp",
      ".tif"  => "image/tiff",
      ".tiff" => "image/tiff",
      ".svg"  => "image/svg+xml",
      ".ico"  => "image/x-icon",
      ".apng" => "image/apng",
      ".jfif" => "image/jpeg",
      ".heic" => "image/heic",

      # Videos
      ".flv" => "video/x-flv",
      ".mov" => "video/quicktime",
      ".mpeg" => "video/mpeg",
      ".mpg" => "video/mpeg",
      ".mp4" => "video/mp4",
      ".webm" => "video/webm",
      ".wmv" => "video/x-ms-wmv",
      ".3gp" => "video/3gpp",
      ".avi"  => "video/x-msvideo",
      ".mkv"  => "video/x-matroska",
      ".ogv"  => "video/ogg",
      ".m4v"  => "video/x-m4v",
      ".m2ts" => "video/mp2t",
      ".mts"  => "video/mp2t",

      # Audio
      ".aac" => "audio/aac",
      ".flac" => "audio/flac",
      ".mp3" => "audio/mpeg",
      ".m4a" => "audio/mp4",
      ".mpga" => "audio/mpeg",
      ".opus" => "audio/opus",
      ".pcm" => "audio/L16",
      ".wav" => "audio/wav",
      ".weba" => "audio/webm",
      ".oga"  => "audio/ogg",
      ".ogg"  => "audio/ogg",
      ".mid"  => "audio/midi",
      ".midi" => "audio/midi",
      ".aiff" => "audio/aiff",
      ".aif"  => "audio/aiff",
      ".amr"  => "audio/amr",
      ".mka"  => "audio/x-matroska",
      ".caf"  => "audio/x-caf",

      # Documents
      ".pdf" => "application/pdf",
      ".txt" => "text/plain",
      ".md" => "text/markdown",
      ".markdown" => "text/markdown",
      ".mkd" => "text/markdown",
      ".doc"  => "application/msword",
      ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      ".xls"  => "application/vnd.ms-excel",
      ".xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      ".ppt"  => "application/vnd.ms-powerpoint",
      ".pptx" => "application/vnd.openxmlformats-officedocument.presentationml.presentation",
      ".csv"  => "text/csv",
      ".json" => "application/json",
      ".xml"  => "application/xml",
      ".html" => "text/html",
      ".htm"  => "text/html",
      ".odt" => "application/vnd.oasis.opendocument.text",
      ".odp" => "application/vnd.oasis.opendocument.presentation",
      ".ods" => "application/vnd.oasis.opendocument.spreadsheet",
      ".rtf" => "application/rtf",
      ".epub" => "application/epub+zip",

      # Code
      ".js"   => "application/javascript",
      ".jsx"  => "text/jsx",
      ".ts"   => "application/typescript",
      ".tsx"  => "text/tsx",
      ".css"  => "text/css",
      ".c"    => "text/x-c",
      ".cpp"  => "text/x-c++",
      ".h"    => "text/x-c",
      ".rb"   => "text/x-ruby",
      ".py"   => "text/x-python",
      ".java" => "text/x-java-source",
      ".sh"   => "application/x-sh",
      ".php"  => "application/x-httpd-php",
      ".yml"  => "text/yaml",
      ".yaml" => "text/yaml",
      ".go"   => "text/x-go",
      ".rs"   => "text/rust",

      # Fonts
      ".woff"  => "font/woff",
      ".woff2" => "font/woff2",
      ".ttf"   => "font/ttf",
      ".otf"   => "font/otf",

      # Archives
      ".zip"  => "application/zip",
      ".tar"  => "application/x-tar",
      ".gz"   => "application/gzip",
      ".bz2"  => "application/x-bzip2",
      ".xz"   => "application/x-xz",
      ".rar"  => "application/vnd.rar",
      ".7z"   => "application/x-7z-compressed",
      ".tar.gz" => "application/gzip",
      ".tar.bz2" => "application/x-bzip2",
      ".apk"  => "application/vnd.android.package-archive",
      ".exe"  => "application/x-msdownload",

      # Others
      ".ics" => "text/calendar",
      ".vcf" => "text/vcard"
    }
  end
end
