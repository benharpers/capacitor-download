declare module "@capacitor/core" {
  interface PluginRegistry {
    Download: DownloadPlugin;
  }
}

export interface DownloadPlugin {
  echo(options: { value: string }): Promise<{value: string}>;
}
