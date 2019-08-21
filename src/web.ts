import { WebPlugin } from '@capacitor/core';
import {
  DownloadPlugin,
  DownloadOptions,
  DownloadResult,
  DownloadDeleteOptions,
  DownloadDeleteResult
} from './definitions';

export class DownloadWeb extends WebPlugin implements DownloadPlugin {

  constructor() {
    super({
      name: 'Download',
      platforms: ['web']
    });
  }

  get(options: DownloadOptions): Promise<DownloadResult> {

    return Promise.resolve(options.url);
  }

  delete(options: DownloadDeleteOptions): Promise<DownloadDeleteResult> {

    return Promise.resolve(true);
  }
}

const Download = new DownloadWeb();

export { Download };

import { registerWebPlugin } from '@capacitor/core';
registerWebPlugin(Download);
