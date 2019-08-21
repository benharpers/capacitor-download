declare module "@capacitor/core" {
  interface PluginRegistry {
    Download: DownloadPlugin;
  }
}

export interface DownloadPlugin {

  get(options: DownloadOptions): Promise<DownloadResult>;

  delete(options: DownloadDeleteOptions): Promise<DownloadDeleteResult>;
}

export enum DownloadDirectory {
  /**
   * The Application directory
   */
  Application = 'APPLICATION',
  /**
   * The Documents directory
   */
  Documents = 'DOCUMENTS',
  /**
   * The Data directory
   */
  Data = 'DATA',
  /**
   * The Cache directory
   */
  Cache = 'CACHE',
  /**
   * The external directory (Android only)
   */
  External = 'EXTERNAL',
  /**
   * The external storage directory (Android only)
   */
  ExternalStorage = 'EXTERNAL_STORAGE'
}

export interface DownloadOptions {
  /**
   * the filename to write
   */
  path: string;
  /**
   * The url to download
   */
  url: string;
  /**
   * The url to download
   */
  replace?: boolean;
  /**
   * The FilesystemDirectory to store the file in
   */
  directory?: DownloadDirectory;
}

export interface DownloadDeleteOptions {
  /**
   * the filename to write
   */
  path: string;
  /**
   * The FilesystemDirectory to store the file in
   */
  directory?: DownloadDirectory;
}

export interface DownloadResult {
  /**
   * The uri of download
   */
  uri: string;
}

export interface DownloadDeleteResult {
}
