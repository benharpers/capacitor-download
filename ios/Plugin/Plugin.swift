import Foundation
import Capacitor

@objc(Download)
public class Download: CAPPlugin {

  var DEFAULT_DIRECTORY = "DOCUMENTS"

  var DEFAULT_PREFIX = "download-"

  var DEFAULT_DAYS = 1

  /**
   * Get the SearchPathDirectory corresponding to the JS string
   */
  func getDirectory(directory: String) -> FileManager.SearchPathDirectory {
    switch directory {
    case "DOCUMENTS":
      return .documentDirectory
    case "APPLICATION":
      return .applicationDirectory
    case "CACHE":
      return .cachesDirectory
    default:
      return .documentDirectory
    }
  }

  /**
   * Get the URL for this file, supporting file:// paths and
   * files with directory mappings.
   */
  func getFileUrl(_ path: String, _ directoryOption: String) -> URL? {
    if path.starts(with: "file://") {
      return URL(string: path)
    }

    let directory = getDirectory(directory: directoryOption)

    guard let dir = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
      return nil
    }

    return dir.appendingPathComponent(path)
  }

  /**
   * Helper for handling errors
   */
  func handleError(_ call: CAPPluginCall, _ message: String, _ error: Error? = nil) {
    call.error(message, error)
  }

  @objc func get(_ call: CAPPluginCall) {

    guard let replace = call.get("replace", Bool.self, false) else {
      handleError(call, "replace must be provided and must be a string.")
      return
    }

    let prefix = call.get("prefix", String.self, DEFAULT_PREFIX)!

    guard let path = call.get("path", String.self) else {
      handleError(call, "path must be provided and must be a string.")
      return
    }

    let directoryOption = call.get("directory", String.self, DEFAULT_DIRECTORY)!
    guard var fileUrl = getFileUrl(prefix + path, directoryOption) else {
      handleError(call, "Invalid path")
      return
    }

    self.run_gc();

    if FileManager.default.fileExists(atPath: fileUrl.path) {

      if (replace == true) {

        do {

          try FileManager.default.removeItem(atPath: fileUrl.path)

        } catch {}

      } else {

        var resourceValues: URLResourceValues = URLResourceValues.init()

        resourceValues.contentAccessDate = Date()

        do {

          try fileUrl.setResourceValues(resourceValues)

        } catch {

          print("Couldn't touch date of \(fileUrl.path)")
        }

        call.success([
          "uri": fileUrl.absoluteString
        ])

        return
      }
    }

    guard let url_str = call.get("url", String.self) else {
      handleError(call, "url must be provided and must be a string.")
      return
    }

    let url = URL(string: url_str)

    URLSession.shared.downloadTask(with: url!) { location, response, error in

      if let location = location {

        do {
          try FileManager.default.moveItem(at: location, to: fileUrl)

          call.success([
            "uri": fileUrl.absoluteString
          ])

        } catch {

          call.success([
            "uri": url_str
          ])
        }
      } else {

        call.success([
          "uri": url_str
        ])
      }

      return
    }.resume()
  }

  /**
   * Set defaults.
   */
  @objc func defaults(_ call: CAPPluginCall) {

    DEFAULT_PREFIX = call.get("prefix", String.self, DEFAULT_PREFIX)!

    DEFAULT_DIRECTORY = call.get("directory", String.self, DEFAULT_DIRECTORY)!

    DEFAULT_DAYS = call.get("days", Int.self, DEFAULT_DAYS)!
  }

  /**
   * Garbage collect old files.
   */
  @objc func gc(_ call: CAPPluginCall) {

    run_gc()

    call.success()
  }

  var busy = false

  /**
   * Garbage collect old files.
   */
  func run_gc() {

    if (busy) { return }
    busy = true

    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {

      let fileUrl = self.getFileUrl("", self.DEFAULT_DIRECTORY)!

      do {
        let directoryContents = try FileManager.default.contentsOfDirectory(at: fileUrl, includingPropertiesForKeys: [.contentAccessDateKey], options: [])

        let downloads = directoryContents.filter {
          $0.lastPathComponent.range(of: "^\(self.DEFAULT_PREFIX)", options: [.regularExpression, .caseInsensitive, .diacriticInsensitive]) != nil
        }

        for file in downloads
        {
          let adate = try file.resourceValues(forKeys: [.contentAccessDateKey]).contentAccessDate!

          let days = Calendar.current.dateComponents([.day], from: adate, to: Date()).day!

          if (days > self.DEFAULT_DAYS) {

            try FileManager.default.removeItem(atPath: file.path)

            print("Removed old download at \(file.path) last accessed \(days) days ago")
          }
        }
      } catch { }

      self.busy = false
    }
  }

  /**
   * Delete a download.
   */
  @objc func delete(_ call: CAPPluginCall) {

    let prefix = call.get("prefix", String.self, DEFAULT_PREFIX)!

    guard let path = call.get("path", String.self) else {
      handleError(call, "path must be provided and must be a string.")
      return
    }

    let directoryOption = call.get("directory", String.self, DEFAULT_DIRECTORY)!
    guard let fileUrl = getFileUrl(prefix + path, directoryOption) else {
      handleError(call, "Invalid path")
      return
    }

    do {

      if FileManager.default.fileExists(atPath: fileUrl.path) {
        try FileManager.default.removeItem(atPath: fileUrl.path)
      }
      call.success()
    } catch let error as NSError {
      handleError(call, error.localizedDescription, error)
    }
  }
}
