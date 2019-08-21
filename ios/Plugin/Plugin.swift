import Foundation
import Capacitor

@objc(Download)
public class Download: CAPPlugin {

  let DEFAULT_DIRECTORY = "DOCUMENTS"

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

    guard let path = call.get("path", String.self) else {
      handleError(call, "path must be provided and must be a string.")
      return
    }

    let directoryOption = call.get("directory", String.self, DEFAULT_DIRECTORY)!
    guard let fileUrl = getFileUrl(path, directoryOption) else {
      handleError(call, "Invalid path")
      return
    }

    if FileManager.default.fileExists(atPath: fileUrl.path) {

      if (replace == true) {

        do {

          try FileManager.default.removeItem(atPath: fileUrl.path)

        } catch {}

      } else {

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
   * Delete a file.
   */
  @objc func delete(_ call: CAPPluginCall) {

    guard let file = call.get("path", String.self) else {
      handleError(call, "path must be provided and must be a string.")
      return
    }

    let directoryOption = call.get("directory", String.self) ?? DEFAULT_DIRECTORY
    guard let fileUrl = getFileUrl(file, directoryOption) else {
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
